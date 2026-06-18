import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/usecases/check_inn_usecase.dart';
import '../../domain/entities/check_inn_entity.dart';

part 'driver_type_bloc.freezed.dart';

enum DriverMainType { selfOrIp, individual }
enum DriverLegalType { selfEmployed, ip }

@freezed
class DriverTypeEvent with _$DriverTypeEvent {
  const factory DriverTypeEvent.selectMainType(DriverMainType type) = _SelectMainType;
  const factory DriverTypeEvent.selectLegalType(DriverLegalType type) = _SelectLegalType;
  const factory DriverTypeEvent.innChanged(String inn) = _InnChanged;
  const factory DriverTypeEvent.verifyInn() = _VerifyInn;
  const factory DriverTypeEvent.continuePressed() = _ContinuePressed;
}

@freezed
class DriverTypeState with _$DriverTypeState {
  const factory DriverTypeState.initial() = _Initial;
  const factory DriverTypeState.loading({
    required DriverMainType selectedMain,
    required DriverLegalType selectedLegal,
    required String inn,
  }) = _Loading;
  const factory DriverTypeState.ready({
    required DriverMainType selectedMain,
    required DriverLegalType selectedLegal,
    required String inn,
    required bool isInnValid,
    required String? innMessage,
    required bool continueEnabled,
    required double commissionPercent,
  }) = _Ready;
  const factory DriverTypeState.error({
    required String message,
    required DriverMainType selectedMain,
    required DriverLegalType selectedLegal,
    required String inn,
    required bool isInnValid,
    required double commissionPercent,
  }) = _Error;
  const factory DriverTypeState.submitting() = _Submitting;
  const factory DriverTypeState.successfulSubmission(int commissionPercent) = _SuccessfulSubmission;
}

class DriverTypeBloc extends Bloc<DriverTypeEvent, DriverTypeState> {
  final CheckInnUseCase checkInnUseCase;

  DriverTypeBloc({required this.checkInnUseCase})
      : super(
          DriverTypeState.ready(
            selectedMain: DriverMainType.selfOrIp,
            selectedLegal: DriverLegalType.selfEmployed,
            inn: '',
            isInnValid: false,
            innMessage: null,
            continueEnabled: false, // must verify INN for self/IP
            commissionPercent: 10.0,
          ),
        ) {
    on<_SelectMainType>(_onSelectMain);
    on<_SelectLegalType>(_onSelectLegal);
    on<_InnChanged>(_onInnChanged);
    on<_VerifyInn>(_onVerifyInn);
    on<_ContinuePressed>(_onContinuePressed);
  }

  void _onSelectMain(_SelectMainType event, Emitter<DriverTypeState> emit) {
    final main = event.type;
    final current = state;
    DriverLegalType legal = DriverLegalType.selfEmployed;
    String inn = '';
    bool isInnValid = false;
    String? innMessage;
    double commission;
    bool continueEnabled;

    if (current is _Ready) {
      legal = current.selectedLegal;
      inn = current.inn;
      isInnValid = current.isInnValid;
      innMessage = current.innMessage;
    }

    if (main == DriverMainType.individual) {
      commission = 17.0;
      // Individual (physical person) does not require INN verification to continue
      continueEnabled = true;
    } else {
      commission = 10.0;
      // For self-employed / IP require verified INN to continue
      continueEnabled = isInnValid;
    }

    emit(
      DriverTypeState.ready(
        selectedMain: main,
        selectedLegal: legal,
        inn: inn,
        isInnValid: isInnValid,
        innMessage: innMessage,
        continueEnabled: continueEnabled,
        commissionPercent: commission,
      ),
    );
  }

  void _onSelectLegal(_SelectLegalType event, Emitter<DriverTypeState> emit) {
    final current = state;
    DriverMainType main = DriverMainType.selfOrIp;
    String inn = '';
    bool isInnValid = false;
    String? innMessage;
    double commission;
    bool continueEnabled;

    if (current is _Ready) {
      main = current.selectedMain;
      inn = current.inn;
      isInnValid = current.isInnValid;
      innMessage = current.innMessage;
    }

    // Both selfEmployed and ip are treated as "selfOrIp" main type with 10% commission
    if (main == DriverMainType.individual) {
      // If main is individual but legal changed (unlikely), set individual rules
      commission = 17.0;
      continueEnabled = true;
    } else {
      commission = 10.0;
      // For self-employed/IP require verified INN to continue
      continueEnabled = isInnValid;
    }

    emit(
      DriverTypeState.ready(
        selectedMain: main,
        selectedLegal: event.type,
        inn: inn,
        isInnValid: isInnValid,
        innMessage: innMessage,
        continueEnabled: continueEnabled,
        commissionPercent: commission,
      ),
    );
  }

  void _onInnChanged(_InnChanged event, Emitter<DriverTypeState> emit) {
    final current = state;
    final inn = event.inn;
    if (current is _Ready) {
      // changing INN invalidates previous verification
      final isInnValid = false;
      final commission = current.selectedMain == DriverMainType.individual ? 17.0 : 10.0;
      final continueEnabled = current.selectedMain == DriverMainType.individual ? true : false;
      emit(
        current.copyWith(
          inn: inn,
          isInnValid: isInnValid,
          innMessage: null,
          continueEnabled: continueEnabled,
          commissionPercent: commission,
        ),
      );
    } else {
      // default to selfOrIp when unknown state
      final commission = DriverMainType.individual == DriverMainType.individual ? 17.0 : 10.0;
      emit(
        DriverTypeState.ready(
          selectedMain: DriverMainType.selfOrIp,
          selectedLegal: DriverLegalType.selfEmployed,
          inn: inn,
          isInnValid: false,
          innMessage: null,
          continueEnabled: false,
          commissionPercent: 10.0,
        ),
      );
    }
  }

  Future<void> _onVerifyInn(_VerifyInn event, Emitter<DriverTypeState> emit) async {
    final current = state;
    if (current is! _Ready) return;
    final inn = current.inn.trim();
    if (inn.isEmpty) {
      emit(
        DriverTypeState.error(
          message: 'Введите ИНН',
          selectedMain: current.selectedMain,
          selectedLegal: current.selectedLegal,
          inn: current.inn,
          isInnValid: false,
          commissionPercent: current.commissionPercent,
        ),
      );
      return;
    }

    emit(
      DriverTypeState.loading(
        selectedMain: current.selectedMain,
        selectedLegal: current.selectedLegal,
        inn: inn,
      ),
    );

    try {
      final CheckInnEntity resp = await checkInnUseCase(inn);
      // resp.success indicates network/processing success, resp.status indicates taxpayer status (registered)
      final bool verified = resp.success && resp.status;
      double commission = current.selectedMain == DriverMainType.individual ? 17.0 : 10.0;
      bool continueEnabled;

      if (verified) {
        // For self/IP verified allows continue; for individual continue was already allowed
        continueEnabled = true;
        emit(
          DriverTypeState.ready(
            selectedMain: current.selectedMain,
            selectedLegal: current.selectedLegal,
            inn: inn,
            isInnValid: true,
            innMessage: resp.message,
            continueEnabled: continueEnabled,
            commissionPercent: commission,
          ),
        );
      } else {
        // Verification failed or not registered
        final message = resp.message.isNotEmpty ? resp.message : 'ИНН не зарегистрирован';
        // For self/IP cannot continue without verification; for individual still can
        continueEnabled = current.selectedMain == DriverMainType.individual;
        emit(
          DriverTypeState.ready(
            selectedMain: current.selectedMain,
            selectedLegal: current.selectedLegal,
            inn: inn,
            isInnValid: false,
            innMessage: message,
            continueEnabled: continueEnabled,
            commissionPercent: commission,
          ),
        );
      }
    } catch (e) {
      emit(
        DriverTypeState.error(
          message: 'Не смогли верифицировать вас как налогоплательщика',
          selectedMain: current.selectedMain,
          selectedLegal: current.selectedLegal,
          inn: inn,
          isInnValid: false,
          commissionPercent: current.commissionPercent,
        ),
      );
    }
  }

  void _onContinuePressed(_ContinuePressed event, Emitter<DriverTypeState> emit) {
    final current = state;
    if (current is! _Ready) return;

    final canContinue = current.continueEnabled;
    if (!canContinue) {
      emit(
        DriverTypeState.error(
          message: 'Невозможно продолжить. Проверьте данные.',
          selectedMain: current.selectedMain,
          selectedLegal: current.selectedLegal,
          inn: current.inn,
          isInnValid: current.isInnValid,
          commissionPercent: current.commissionPercent,
        ),
      );
      return;
    }

    emit(const DriverTypeState.submitting());
    final commission = current.selectedMain == DriverMainType.individual ? 17.0 : 10.0;

    // In a real app we would persist the selected type and INN here.
    emit( DriverTypeState.successfulSubmission(commission.toInt()));
  }
}
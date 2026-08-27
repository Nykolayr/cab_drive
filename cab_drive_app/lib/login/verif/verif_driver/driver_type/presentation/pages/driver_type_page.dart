import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../verif_driver_model.dart';
import '../../data/datasources/check_inn_remote_data_source.dart';
import '../../data/repositories/check_inn_repository_impl.dart';
import '../../domain/usecases/check_inn_usecase.dart';
import '../bloc/driver_type_bloc.dart';
class DriverTypePage extends StatelessWidget {
  final VerifDriverModel model;
  const DriverTypePage({Key? key, required this.model}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // Provide bloc with concrete implementations wired here.
    final remote = CheckInnRemoteDataSource();
    final repo = CheckInnRepositoryImpl(remoteDataSource: remote);
    final usecase = CheckInnUseCase(repo);

    return BlocProvider(
      create: (_) => DriverTypeBloc(checkInnUseCase: usecase),
      child: DriverTypeView(model: model,),
    );
  }
}

class DriverTypeView extends StatefulWidget {
  final VerifDriverModel model;

  const DriverTypeView({Key? key, required this.model}) : super(key: key);

  @override
  State<DriverTypeView> createState() => _DriverTypeViewState();
}

class _DriverTypeViewState extends State<DriverTypeView> {
  final TextEditingController _innController = TextEditingController();

  @override
  void dispose() {
    _innController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.lightBlueAccent.shade700;
    return BlocConsumer<DriverTypeBloc, DriverTypeState>(
        listener: (context, state) {
          state.maybeWhen(
            successfulSubmission: (commission) async  {
              widget.model.commissionPercent = commission;
              await widget.model.pageViewController?.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.ease,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Данные сохранены'), backgroundColor: accent),
              );
            },
            error: (message, _, __, ___, ____, _____) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(context, state, accent),
          );
        },

    );
  }

  Widget _buildContent(BuildContext context, DriverTypeState state, Color accent) {
    DriverMainType main = DriverMainType.selfOrIp;
    DriverLegalType legal = DriverLegalType.selfEmployed;
    String inn = '';
    bool isInnValid = false;
    String? innMessage;
    bool continueEnabled = true;
    double commission = 17.0;

    state.maybeWhen(
      ready: (selectedMain, selectedLegal, sInn, sIsInnValid, sInnMessage, sContinue, sCommission) {
        main = selectedMain;
        legal = selectedLegal;
        inn = sInn;
        isInnValid = sIsInnValid;
        innMessage = sInnMessage;
        continueEnabled = sContinue;
        commission = sCommission;
      },
      loading: (selectedMain, selectedLegal, sInn) {
        main = selectedMain;
        legal = selectedLegal;
        inn = sInn;
      },
      error: (message, selectedMain, selectedLegal, sInn, sIsInnValid, sCommission) {
        main = selectedMain;
        legal = selectedLegal;
        inn = sInn;
        isInnValid = sIsInnValid;
        commission = sCommission;
      },
      orElse: () {},
    );

    _innController.text = inn;
    _innController.selection = TextSelection.fromPosition(TextPosition(offset: _innController.text.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Выберите тип аккаунта:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildRadioTile<DriverMainType>(
          context: context,
          value: DriverMainType.selfOrIp,
          groupValue: main,
          title: 'Самозанятый / ИП',
          accent: accent,
          onChanged: (v) => context.read<DriverTypeBloc>().add(DriverTypeEvent.selectMainType(v!)),
        ),
        _buildRadioTile<DriverMainType>(
          context: context,
          value: DriverMainType.individual,
          groupValue: main,
          title: 'Физическое лицо',
          accent: accent,
          onChanged: (v) => context.read<DriverTypeBloc>().add(DriverTypeEvent.selectMainType(v!)),
        ),
        if (main == DriverMainType.selfOrIp) ...[
          const SizedBox(height: 16),
          const Text('Укажите статус:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<DriverTypeBloc>().add(const DriverTypeEvent.selectLegalType(DriverLegalType.selfEmployed)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: legal == DriverLegalType.selfEmployed ? accent.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: legal == DriverLegalType.selfEmployed ? accent : Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Text('Самозанятый', style: TextStyle(color: legal == DriverLegalType.selfEmployed ? accent : Colors.black)),
                        const SizedBox(height: 6),
                        Text('Комиссия 10%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<DriverTypeBloc>().add(const DriverTypeEvent.selectLegalType(DriverLegalType.ip)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: legal == DriverLegalType.ip ? accent.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: legal == DriverLegalType.ip ? accent : Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Text('ИП', style: TextStyle(color: legal == DriverLegalType.ip ? accent : Colors.black)),
                        const SizedBox(height: 6),
                        Text('Комиссия 10%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _innController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'ИНН',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<DriverTypeBloc>().add(DriverTypeEvent.innChanged(_innController.text));
                      context.read<DriverTypeBloc>().add(const DriverTypeEvent.verifyInn());
                    },
                    child: const Text('Проверить'),
                  ),
                ],
              ),
            ),
            onChanged: (v) => context.read<DriverTypeBloc>().add(DriverTypeEvent.innChanged(v)),
          ),
          const SizedBox(height: 8),
          if (isInnValid)
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Expanded(child: Text(innMessage ?? 'ИНН зарегистрирован', style: const TextStyle(color: Colors.green))),
              ],
            )
          else if (innMessage != null && innMessage!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(child: Text(innMessage!, style: TextStyle(color: Colors.orange.shade700))),
              ],
            ),
        ] else ...[
          const SizedBox(height: 24),
          Text('Комиссия: 17% (физическое лицо)', style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
        ],
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (main == DriverMainType.selfOrIp)
                ? (isInnValid ? () => _onContinue(context) : null)
                : () => _onContinue(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Продолжить', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioTile<T>({
    required BuildContext context,
    required T value,
    required T groupValue,
    required String title,
    required Color accent,
    required ValueChanged<T?> onChanged,
  }) {
    final selected = value == groupValue;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        activeColor: accent,
      ),
    );
  }

  void _onContinue(BuildContext context) {
    context.read<DriverTypeBloc>().add(const DriverTypeEvent.continuePressed());
  }
}
// lib/features/orders/presentation/bloc/orders_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:cab_drive/app_state.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/entities.dart';
import '../../domain/usecases/get_etas.dart';
import '../../domain/usecases/get_prices.dart';

part 'orders_bloc.freezed.dart';

@freezed
class OrdersEvent with _$OrdersEvent {
  const factory OrdersEvent.getEtas({
    required LocationEntity userLocation,
    double? radiusKm,
  }) = _GetEtas;

  const factory OrdersEvent.getPrices({
    required LocationEntity userLocation,
    required LocationEntity destLocation,
    LocationEntity? intermediate,
    required int movers,
    Function(Map<String, PriceItemEntity?>?)? onSuccess
  }) = _GetPrices;
}

@freezed
class OrdersState with _$OrdersState {
  const factory OrdersState.initial() = _Initial;
  const factory OrdersState.loading() = _Loading;
  const factory OrdersState.loaded({
    required Map<String, ETAItemEntity?>? etas,
    required Map<String, PriceItemEntity?>? prices,
  }) = _Loaded;

  const factory OrdersState.error({
    required String message,
  }) = _Error;
}

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetEtasUseCase getEtasUseCase;
  final GetPricesUseCase getPricesUseCase;

  OrdersBloc({
    required this.getEtasUseCase,
    required this.getPricesUseCase,
  }) : super(const OrdersState.initial()) {
    on<_GetEtas>(_onGetEtas);
    on<_GetPrices>(_onGetPrices);
  }

  Map<String, ETAItemEntity?>? _etas;
  Map<String, PriceItemEntity?>? _prices;

  Future<void> _onGetEtas(_GetEtas event, Emitter<OrdersState> emit) async {
    emit(const OrdersState.loading());
    try {
      _etas = await getEtasUseCase(event.userLocation, radiusKm: event.radiusKm);
      print('etas $_etas');
      emit(_Loaded(etas: _etas, prices: _prices));
    } on DioException catch (e) {
      emit(OrdersState.error(message: e.toString()));
      throw e.response?.data;
    } catch (e) {
      emit(OrdersState.error(message: e.toString()));
      rethrow;
    }
  }

  Future<void> _onGetPrices(_GetPrices event, Emitter<OrdersState> emit) async {
    emit(const OrdersState.loading());
    try {
      final prices = await getPricesUseCase(
        event.userLocation,
        event.destLocation,
        event.movers,
        intermediate: event.intermediate,
      );
      add(OrdersEvent.getEtas(userLocation: event.userLocation));
      if(event.onSuccess != null) {

        event.onSuccess?.call(prices);
      } else {
        FFAppState().priceFiat = prices['fiat']!.price.toInt();
        FFAppState().priceLargus = prices['largus']!.price.toInt();
        FFAppState().priceTermo = prices['largustermo']!.price.toInt();

        // Update distance and time from price response
        final priceItem = prices['fiat'] ?? prices['largus'] ?? prices['largustermo'];
        if (priceItem != null) {
          FFAppState().distanceKm = (priceItem.distanceKm * 1000).toInt(); // Convert km to meters
          final durationMin = (priceItem.durationSec / 60).round();
          FFAppState().distanceTime = '$durationMin мин';
        }

        FFAppState().update(() {});
      }
      print(prices);

      emit(OrdersState.loaded(prices: _prices = prices, etas: _etas));
    } on DioException catch (e) {
      emit(OrdersState.error(message: e.toString()));
      throw e.response?.data;
    } catch (e) {
      emit(OrdersState.error(message: e.toString()));
      rethrow;
    }
  }
}
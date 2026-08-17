import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../domain/entities/entities.dart';
import '../presentation/bloc/orders_bloc.dart';

class MapPickerWidget extends StatefulWidget {
  const MapPickerWidget({
    super.key,
    required this.point,
    this.initialLatLng,
  });

  /// 1 = pointA (Откуда), 2 = pointB (Куда)
  final int point;
  final LatLng? initialLatLng;

  @override
  State<MapPickerWidget> createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends State<MapPickerWidget> {
  YandexMapController? _mapController;

  LatLng _center = const LatLng(55.751244, 37.618423);
  double _zoom = 17;
  String _addressLabel = '';
  bool _loadingLabel = true;
  Timer? _debounce;
  ApiCallResponse? _lastGeocode;

  @override
  void initState() {
    super.initState();
    // Префер — последний центр/зум с любой карты выбора адреса (главный экран
    // create_map_page или предыдущий запуск этого же пикера). Так юзер не
    // теряет позицию и масштаб при переходе из bottom-sheet "Карта".
    final lastCenter = FFAppState().lastPickerMapCenter;
    final lastZoom = FFAppState().lastPickerMapZoom;
    if (lastCenter != null) {
      _center = lastCenter;
    }
    if (lastZoom != null) {
      _zoom = lastZoom;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final initial = widget.initialLatLng ??
          lastCenter ??
          (widget.point == 1
              ? FFAppState().pointA.latlng
              : FFAppState().pointB.latlng) ??
          await getCurrentUserLocation(
              defaultLocation: const LatLng(55.751244, 37.618423));
      if (!mounted) return;
      setState(() {
        _center = initial;
      });
      await _moveCamera(_center, _zoom);
      await _reverseGeocode();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _moveCamera(LatLng target, double zoom) async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(latitude: target.latitude, longitude: target.longitude),
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> _reverseGeocode() async {
    setState(() {
      _loadingLabel = true;
    });
    final response = await GeocodeLatLngCall.call(
      latlng: '${_center.latitude},${_center.longitude}',
    );
    if (!mounted) return;
    final street = GeocodeLatLngCall.street(response.jsonBody) ?? '';
    final number = GeocodeLatLngCall.number(response.jsonBody) ?? '';
    final address = GeocodeLatLngCall.address(response.jsonBody) ?? '';
    final label = street.isNotEmpty
        ? (number.isNotEmpty ? '$street, $number' : street)
        : address;
    setState(() {
      _addressLabel = label.isEmpty ? 'Адрес не найден' : label;
      _lastGeocode = response;
      _loadingLabel = false;
    });
  }

  Future<void> _onCameraIdle(LatLng latLng) async {
    _center = latLng;
    FFAppState().lastPickerMapCenter = latLng;
    try {
      final c = _mapController;
      if (c != null) {
        final pos = await c.getCameraPosition();
        _zoom = pos.zoom;
        FFAppState().lastPickerMapZoom = _zoom;
      } else {
        FFAppState().lastPickerMapZoom = _zoom;
      }
    } catch (_) {
      FFAppState().lastPickerMapZoom = _zoom;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _reverseGeocode);
  }

  Future<void> _confirm() async {
    var response = _lastGeocode;
    if (response == null) {
      await _reverseGeocode();
      response = _lastGeocode;
      if (response == null) return;
    }

    final ll = LatLng(_center.latitude, _center.longitude);
    final street = GeocodeLatLngCall.street(response.jsonBody);
    final number = GeocodeLatLngCall.number(response.jsonBody);
    final fullAddress = GeocodeLatLngCall.address(response.jsonBody);
    final placeId = GeocodeLatLngCall.placeId(response.jsonBody);
    final city = GeocodeLatLngCall.areal2(response.jsonBody) ??
        GeocodeLatLngCall.city(response.jsonBody);
    final region = GeocodeLatLngCall.areal(response.jsonBody);

    final addressText = (number != null && number.isNotEmpty)
        ? '$street, $number'
        : (street != null && street.isNotEmpty
            ? street
            : (fullAddress ?? ''));

    final picked = PointStruct(
      latlng: ll,
      placeID: placeId,
      address: addressText,
      fullAddress: fullAddress,
      city: city,
      region: region,
    );

    if (widget.point == 1) {
      FFAppState().pointA = picked;
    } else {
      FFAppState().pointB = picked;
    }
    FFAppState().update(() {});

    if (!mounted) return;

    final pa = FFAppState().pointA.latlng;
    final pb = FFAppState().pointB.latlng;
    if (widget.point == 1 && pa != null) {
      context.read<OrdersBloc>().add(
            OrdersEvent.getEtas(
              userLocation: LocationEntity(
                lat: pa.latitude,
                lng: pa.longitude,
              ),
            ),
          );
    }
    if (pa != null && pb != null) {
      context.read<OrdersBloc>().add(
            OrdersEvent.getPrices(
              userLocation:
                  LocationEntity(lat: pa.latitude, lng: pa.longitude),
              destLocation:
                  LocationEntity(lat: pb.latitude, lng: pb.longitude),
              intermediate: FFAppState().pointC.address.isNotEmpty
                  ? LocationEntity(
                      lat: FFAppState().pointC.latlng!.latitude,
                      lng: FFAppState().pointC.latlng!.longitude,
                    )
                  : null,
              movers: FFAppState().movers,
            ),
          );
    }

    if (!mounted) return;
    Navigator.of(context).pop(picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      body: Stack(
        children: [
          Positioned.fill(
            child: custom_widgets.YandexPickerMap(
              initialLocation: _center,
              initialZoom: _zoom,
              allowInteraction: true,
              onCameraIdle: _onCameraIdle,
              onMapCreated: (controller) async {
                _mapController = controller;
                await _moveCamera(_center, _zoom);
              },
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 49),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AddressLabel(
                      text: _loadingLabel && _addressLabel.isEmpty
                          ? '…'
                          : _addressLabel,
                    ),
                    CustomPaint(
                      size: const Size(7, 7),
                      painter: _TrianglePainter(color: const Color(0xFF007AFF)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 17,
                      color: const Color(0xFF007AFF),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 18,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Color(0xFF070707),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 30,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(6, 16, 6, bottomInset + 12),
              child: SafeArea(
                top: false,
                child: GestureDetector(
                  onTap: _confirm,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007AFF),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Выбрать адрес',
                      style:
                          FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'SF',
                                color: Colors.white,
                                fontSize: 16.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressLabel extends StatelessWidget {
  const _AddressLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'SF',
              color: Colors.white,
              fontSize: 16.0,
              letterSpacing: 0.0,
            ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

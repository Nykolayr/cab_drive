import 'package:cab_drive/backend/schema/enums/enums.dart';
import 'package:cab_drive/customer/edit_order/widgets/edit_app_bar.dart';
import 'package:cab_drive/customer/edit_order/widgets/movers.dart';
import 'package:cab_drive/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '../../auth/firebase_auth/auth_util.dart';
import '../../backend/api/app_me_api.dart';
import '../../backend/api/order_record_mapper.dart';
import '../../backend/api/saved_cards_record_mapper.dart';
import '../../backend/api_requests/api_calls.dart';
import '../../backend/schema/order_record.dart';
import '../../backend/schema/structs/point_struct.dart';
import '../../backend/schema/structs/sender_struct.dart';
import '../../flutter_flow/custom_functions.dart';
import '../create_map_page/domain/entities/entities.dart';
import '../create_map_page/presentation/bloc/orders_bloc.dart';
import '../create_order/karta/karta_widget.dart';

class EditOrderPage extends StatefulWidget {
  final DocumentReference orderReference;

  EditOrderPage({required this.orderReference});

  @override
  _EditOrderPageState createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  late OrderRecord orderRecord;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  final TextEditingController _pointAController = TextEditingController();
  final TextEditingController _pointBController = TextEditingController();
  final TextEditingController _pointCController = TextEditingController();

  bool _isLoading = true;

  DateTime? dateTime;
  int supply = 1; // 1 - В ближайшее время, 2 - Заказать ко времени

  @override
  void initState() {
    super.initState();
    _loadOrderData();
  }

  late PointStruct _lastPointA;
  late PointStruct _lastPointB;
  late PointStruct _lastPointC;

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    _pointAController.dispose();
    _pointBController.dispose();
    _pointCController.dispose();
    FFAppState().pointA = _lastPointA;
    FFAppState().pointB = _lastPointB;
    FFAppState().pointC = _lastPointC;

    super.dispose();
  }

  late int movers = 0;

  String time = "";
  int distance = 0;

  Future<void> _loadOrderData() async {
    _lastPointA = FFAppState().pointA;
    _lastPointB = FFAppState().pointB;
    _lastPointC = FFAppState().pointC;

    final map = await AppMeApi.getOrder(widget.orderReference.id);
    if (map == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить заказ')),
        );
      }
      return;
    }
    orderRecord = OrderRecordMapper.fromApi(map, widget.orderReference.id);
    setState(() {
      time = orderRecord.time;
      distance = orderRecord.distance;
      movers = orderRecord.movers;
      _descriptionController.text = orderRecord.description ?? '';
      _budgetController.text = (orderRecord.budget ?? 0).toString();
      _pointAController.text = orderRecord.pointA?.address ?? '';
      _pointBController.text = orderRecord.pointB?.address ?? '';
      _pointCController.text = orderRecord.pointC?.address ?? '';
      FFAppState().pointA = orderRecord.pointA;
      FFAppState().pointB = orderRecord.pointB;
      FFAppState().pointC = orderRecord.pointC;

      dateTime = orderRecord.dateTime;
      supply = orderRecord.supply ?? 1;
      _isLoading = false;
    });
  }

  _updateRoutePrice({Function(int, String time, int km)? onUpdate}) async {
    context.read<OrdersBloc>().add(
        OrdersEvent.getPrices(
            userLocation: LocationEntity(
                lat: FFAppState().pointA
                    .latlng!.latitude,
                lng: FFAppState().pointA
                    .latlng!.longitude),
            destLocation: LocationEntity(
                lat: FFAppState().pointB
                    .latlng!.latitude,
                lng: FFAppState().pointB
                    .latlng!.longitude),
            intermediate: FFAppState().pointC.address.isNotEmpty ? LocationEntity(
                lat: FFAppState().pointC
                    .latlng!.latitude,
                lng: FFAppState().pointC
                    .latlng!.longitude) : null,
            movers: movers, onSuccess: (value) {
          int price = 0;
          if (orderRecord.car == Car.largus) {
            price = value!['largus']!.price.toInt();
          } else if (orderRecord.car == Car.largusTermo) {
            price = value!['largustermo']!.price.toInt();
          } else {
            price = value!['fiat']!.price.toInt();
          }

          // Get time and distance from price response
          final priceItem = value!['fiat'] ?? value['largus'] ?? value['largustermo'];
          final durationMin = (priceItem!.durationSec / 60).round();
          final time = '$durationMin мин';
          final km = (priceItem.distanceKm * 1000).toInt();

          safeSetState(() {});
          onUpdate?.call(price, time, km);
        }));
  }

  Future<void> _saveOrder() async {
    if (supply == 1) {
      dateTime = DateTime.now();
    } else {
      if (dateTime == null) {
        final picked = await _selectDateTime(context);
        if (picked == null) return;
        dateTime = picked;
      }
    }

    if (FFAppState().pointA.sender?.phone == ',' ||
        FFAppState().pointA.sender?.phone == '') {
      FFAppState().pointA.sender = SenderStruct(
        name: currentUserDisplayName,
        phone: currentPhoneNumber,
        itsMe: true,
      );
    }
    if (FFAppState().pointB.sender?.phone == ',' ||
        FFAppState().pointB.sender?.phone == '') {
      FFAppState().pointB.sender = SenderStruct(
        name: currentUserDisplayName,
        phone: currentPhoneNumber,
        itsMe: true,
      );
    }
    if (FFAppState().pointC.sender?.phone == ',' ||
        FFAppState().pointC.sender?.phone == '' && FFAppState().pointC.latlng != null) {
      FFAppState().pointC.sender = SenderStruct(
        name: currentUserDisplayName,
        phone: currentPhoneNumber,
        itsMe: true,
      );
    }

    final int parsedBudget =
        int.tryParse(_budgetController.text.replaceAll(' ', '')) ?? 0;

    final data = createOrderRecordData(
        description: _descriptionController.text.trim(),
        budget: parsedBudget,
        dateTime: dateTime,
        supply: supply,
        movers: movers,
        pointA: FFAppState().pointA,
        pointB: FFAppState().pointB,
        pointC: FFAppState().pointC.latlng != null ? FFAppState().pointC : null,
        time: time,
        distance: distance);

    final ok = await AppMeApi.patchOrder(
      widget.orderReference.id,
      {
        'description': _descriptionController.text.trim(),
        'budget': parsedBudget,
        'dateTime': dateTime?.toUtc().toIso8601String(),
        'supply': supply,
        'movers': movers,
        'pointA': pointToApiMap(FFAppState().pointA),
        'pointB': pointToApiMap(FFAppState().pointB),
        if (FFAppState().pointC.latlng != null)
          'pointC': pointToApiMap(FFAppState().pointC),
        'time': time,
        'distance': distance,
      },
    );
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить заказ')),
        );
      }
      return;
    }
    Navigator.pop(context);
  }

  Future<void> _editPointA(BuildContext context) async {
    await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(20),
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context).copyWith(bottom: 20),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  TextField(
                    controller: TextEditingController(
                        text: FFAppState().pointA.address),
                    onTap: () async {
                      var value = await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return WebViewAware(
                            child: KartaWidget(point: 'A'),
                          );
                        },
                      );

                      Navigator.pop(context);
                      setState(() {});
                    },
                    decoration: InputDecoration(labelText: 'Адрес'),
                  ),
                  GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      TextField(
                        controller: TextEditingController(
                            text:
                                FFAppState().pointA.entrance?.toString() ?? ''),
                        decoration: InputDecoration(labelText: 'Вход'),
                        onChanged: (value) {
                          FFAppState().pointA.entrance = int.tryParse(value);
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointA.floor?.toString() ?? ''),
                        decoration: InputDecoration(labelText: 'Этаж'),
                        onChanged: (value) {
                          FFAppState().pointA.floor = int.tryParse(value);
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointA.flat),
                        decoration: InputDecoration(labelText: 'Квартира'),
                        onChanged: (value) {
                          FFAppState().pointA.flat = value;
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointA.intercom),
                        decoration: InputDecoration(labelText: 'Домофон'),
                        onChanged: (value) {
                          FFAppState().pointA.intercom = value;
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: TextEditingController(
                        text: FFAppState().pointA.comment),
                    decoration: InputDecoration(labelText: 'Комментарий'),
                    onChanged: (value) {
                      FFAppState().pointA.comment = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _updateRoutePrice(onUpdate: (price, time, km) {
        _budgetController.text = (price).toString();
        this.time = time;
        this.distance = km;
        setState(() {});
      });
      safeSetState(() {});
    });
  }

  Future<void> _editPointB(BuildContext context) async {
    await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(20),
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context).copyWith(bottom: 20),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  TextField(
                    controller: TextEditingController(
                        text: FFAppState().pointB.address),
                    onTap: () async {
                      var value = await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return WebViewAware(
                            child: KartaWidget(point: 'B'),
                          );
                        },
                      );

                      Navigator.pop(context);
                      setState(() {});
                    },
                    decoration: InputDecoration(labelText: 'Адрес B'),
                  ),
                  GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      TextField(
                        controller: TextEditingController(
                            text:
                                FFAppState().pointB.entrance?.toString() ?? ''),
                        decoration: InputDecoration(labelText: 'Вход'),
                        onChanged: (value) {
                          FFAppState().pointB.entrance = int.tryParse(value);
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointB.floor?.toString() ?? ''),
                        decoration: InputDecoration(labelText: 'Этаж'),
                        onChanged: (value) {
                          FFAppState().pointB.floor = int.tryParse(value);
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointB.flat),
                        decoration: InputDecoration(labelText: 'Квартира'),
                        onChanged: (value) {
                          FFAppState().pointB.flat = value;
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointB.intercom),
                        decoration: InputDecoration(labelText: 'Домофон'),
                        onChanged: (value) {
                          FFAppState().pointB.intercom = value;
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: TextEditingController(
                        text: FFAppState().pointB.comment),
                    decoration: InputDecoration(labelText: 'Комментарий'),
                    onChanged: (value) {
                      FFAppState().pointB.comment = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      safeSetState(() {});
      _updateRoutePrice(onUpdate: (price, time, km) {
        _budgetController.text = (price).toString();
        this.time = time;
        this.distance = km;
        setState(() {});
      });
    });
  }

  Future<void> _editPointC(BuildContext context) async {
    await showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.all(20),
            child: Padding(
              padding: MediaQuery.viewInsetsOf(context).copyWith(bottom: 20),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  TextField(
                    controller: TextEditingController(
                        text: FFAppState().pointC.address),
                    onTap: () async {
                      var value = await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return WebViewAware(
                            child: KartaWidget(point: 'C'),
                          );
                        },
                      );

                      Navigator.pop(context);
                      setState(() {});
                    },
                    decoration:
                        InputDecoration(labelText: 'Промежуточная точка'),
                  ),
                  GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      TextField(
                        controller: TextEditingController(
                            text:
                                FFAppState().pointC.entrance?.toString() ?? ''),
                        decoration: InputDecoration(labelText: 'Вход'),
                        onChanged: (value) {
                          FFAppState().pointC.entrance = int.tryParse(value);
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointC.floor?.toString() ?? ''),
                        decoration: InputDecoration(labelText: 'Этаж'),
                        onChanged: (value) {
                          FFAppState().pointC.floor = int.tryParse(value);
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointC.flat),
                        decoration: InputDecoration(labelText: 'Квартира'),
                        onChanged: (value) {
                          FFAppState().pointC.flat = value;
                        },
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: FFAppState().pointC.intercom),
                        decoration: InputDecoration(labelText: 'Домофон'),
                        onChanged: (value) {
                          FFAppState().pointC.intercom = value;
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: TextEditingController(
                        text: FFAppState().pointC.comment),
                    decoration: InputDecoration(labelText: 'Комментарий'),
                    onChanged: (value) {
                      FFAppState().pointC.comment = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      safeSetState(() {});
      _updateRoutePrice(onUpdate: (price, time, km) {
        _budgetController.text = (price).toString();
        this.time = time;
        this.distance = km;
        setState(() {});
      });
    });
  }

  Future<DateTime?> _selectDateTime(BuildContext context) async {
    DateTime initial = ((dateTime ?? DateTime.now()).secondsSinceEpoch >
                DateTime.now().secondsSinceEpoch
            ? dateTime
            : DateTime.now())!
        .add(Duration(hours: 2));
    DateTime temp = initial;

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3 + 60,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Выбрать дату и время',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(temp),
                      child: Text('Готово'),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  minimumDate: DateTime.now(),
                  initialDateTime: initial,
                  maximumDate: DateTime(2050),
                  use24hFormat: true,
                  onDateTimeChanged: (newDt) {
                    temp = newDt;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    return picked;
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Не выбрано';
    final d = dt.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day.$month.$year  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: Column(
                      children: [
                        EditAppBar(),
                        EditMoversWidget(
                            value: movers,
                            car: orderRecord.car ?? Car.fiat,
                            order: orderRecord,
                            selected: (movers, price) {
                              this.movers = movers;
                              _budgetController.text = (price).toString();
                              setState(() {});
                            }),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Описание груза',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: TextFormField(
                                    controller: _descriptionController,
                                    decoration: InputDecoration(
                                      hintText: 'Описание',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Color(0xFFF7F8FB),
                                    ),
                                    maxLines: 2,
                                    onChanged: (v) {},
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return 'Введите описание';
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Card: Точки отправки
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Точки Отправки',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: TextEditingController(
                                      text: FFAppState().pointA.address),
                                  decoration: InputDecoration(
                                    hintText: 'Отправление',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF7F8FB),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _editPointA(context);
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: TextEditingController(
                                      text: FFAppState().pointB.address),
                                  decoration: InputDecoration(
                                    hintText: 'Прибытие',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF7F8FB),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        _editPointB(context);
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: TextEditingController(
                                      text: FFAppState().pointC.address),
                                  decoration: InputDecoration(
                                    hintText: 'Промежуточная точка',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Color(0xFFF7F8FB),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            _editPointC(context);
                                          },
                                        ),
                                        if (FFAppState().pointC.latlng != null)
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              FFAppState().pointC =
                                                  PointStruct();
                                              _pointCController
                                                  .clear(); // Очищаем поле
                                              safeSetState(() {});
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Card: Подача (Expandable)
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            title: Text('Подача',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            childrenPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            children: [
                              Column(
                                children: [
                                  RadioListTile<int>(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    value: 1,
                                    groupValue: supply,
                                    title: Text('В ближайшее время'),
                                    onChanged: (v) {
                                      setState(() {
                                        supply = v!;
                                        if (supply == 1)
                                          dateTime = DateTime.now();
                                      });
                                    },
                                  ),
                                  RadioListTile<int>(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    value: 2,
                                    groupValue: supply,
                                    title: Text('Заказать ко времени'),
                                    onChanged: (v) {
                                      setState(() {
                                        supply = v!;
                                        if (supply == 1)
                                          dateTime = DateTime.now();
                                      });
                                    },
                                  ),
                                  if (supply == 2)
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('Дата и время'),
                                      subtitle: Text(_formatDateTime(dateTime)),
                                      trailing:
                                          Icon(Icons.calendar_today_outlined),
                                      onTap: () async {
                                        final picked =
                                            await _selectDateTime(context);
                                        if (picked != null) {
                                          setState(() {
                                            dateTime = picked;
                                          });
                                        }
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 200,
                        )
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 12),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text('Бюджет',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(height: 8),
                                  IgnorePointer(
                                    child: TextFormField(
                                      controller: _budgetController,
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        prefixText: '₽ ',
                                        filled: true,
                                        fillColor: Color(0xFFF7F8FB),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty)
                                          return 'Введите бюджет';
                                        if (int.tryParse(
                                                value.replaceAll(' ', '')) ==
                                            null)
                                          return 'Неверный формат числа';
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await _saveOrder();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            elevation: 4,
                                          ),
                                          child: Text('Сохранить',
                                              style: TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

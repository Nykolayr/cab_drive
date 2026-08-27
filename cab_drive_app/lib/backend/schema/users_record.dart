import 'dart:async';
import 'package:collection/collection.dart';
import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? ''; // Ensure not null
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? ''; // Ensure not null
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? ''; // Ensure not null
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? ''; // Ensure not null
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? ''; // Ensure not null
  bool hasPhoneNumber() => _phoneNumber != null;

  // "login_complete" field.
  bool? _loginComplete;
  bool get loginComplete => _loginComplete ?? false; // Default to false
  bool hasLoginComplete() => _loginComplete != null;

  // "is_driver" field.
  bool? _isDriver;
  bool get isDriver => _isDriver ?? false; // Default to false
  bool hasIsDriver() => _isDriver != null;

  // "admin" field.
  bool? _admin;
  bool get admin => _admin ?? false; // Default to false
  bool hasAdmin() => _admin != null;

  // "surname" field.
  String? _surname;
  String get surname => _surname ?? ''; // Ensure not null
  bool hasSurname() => _surname != null;

  // "dfb" field.
  DateTime? _dfb;
  DateTime? get dfb => _dfb;
  bool hasDfb() => _dfb != null;

  // "city" field.
  String? _city;
  String get city => _city ?? ''; // Ensure not null
  bool hasCity() => _city != null;

  // "verif_compl" field.
  bool? _isBlocked;
  bool get isBlocked => _isBlocked ?? false; // Default to false

  // "verif_compl" field.
  bool? _verifCompl;
  bool get verifCompl => _verifCompl ?? false; // Default to false
  bool hasVerifCompl() => _verifCompl != null;

  // "chat_with_support" field.
  DocumentReference? _chatWithSupport;
  DocumentReference? get chatWithSupport => _chatWithSupport;
  set chatWithSupport (DocumentReference? value) => _chatWithSupport = value;

  bool hasChatWithSupport() => _chatWithSupport != null;

  // "balance" field.
  double? _balance;
  double get balance => _balance ?? 0.0; // Default to 0.0
  bool hasBalance() => _balance != null;

  // "bonus_balance" field — write-off only, never withdrawn.
  double? _bonusBalance;
  double get bonusBalance => _bonusBalance ?? 0.0;
  bool hasBonusBalance() => _bonusBalance != null;

  // "average_rating" field.
  double? _averageRating;
  double get averageRating => _averageRating ?? 0.0; // Default to 0.0
  bool hasAverageRating() => _averageRating != null;

  // "on_verif_now" field.
  bool? _onVerifNow;
  bool get onVerifNow => _onVerifNow ?? false; // Default to false
  bool hasOnVerifNow() => _onVerifNow != null;

  // "addresses" field.
  List<PointStruct>? _addresses;
  List<PointStruct> get addresses => _addresses ?? const []; // Default to empty list
  bool hasAddresses() => _addresses != null;

  // "number_of_reviews" field.
  int? _numberOfReviews;
  int get numberOfReviews => _numberOfReviews ?? 0; // Default to 0
  bool hasNumberOfReviews() => _numberOfReviews != null;

  // "car" field.
  CarStruct? _car;
  CarStruct get car => _car ?? CarStruct(); // Default to CarStruct instance
  bool hasCar() => _car != null;

  // "last_online" field.
  DateTime? _lastOnline;
  DateTime? get lastOnline => _lastOnline;
  bool hasLastOnline() => _lastOnline != null;

  // "verif_ne_proidena" field.
  bool? _verifNeProidena;
  bool get verifNeProidena => _verifNeProidena ?? false; // Default to false
  bool hasVerifNeProidena() => _verifNeProidena != null;

  // "verif_id" field.
  int? _verifId;
  int get verifId => _verifId ?? 0; // Default to 0
  bool hasVerifId() => _verifId != null;

  // "email_user" field.
  String? _emailUser;
  String get emailUser => _emailUser ?? ''; // Ensure not null
  bool hasEmailUser() => _emailUser != null;

  // "current_order" field.
  CurrentOrderStruct? _currentOrder;
  CurrentOrderStruct? get currentOrder => _currentOrder;
  bool hasCurrentOrder() => _currentOrder != null;

  // "ContractorID" field.
  int? _contractorID;
  int get contractorID => _contractorID ?? 0; // Default to 0
  bool hasContractorID() => _contractorID != null;

  // "on_shift" field.
  bool? _onShift;
  bool get onShift => _onShift ?? false; // Default to false
  bool hasOnShift() => _onShift != null;

  // "current_commision" field.
  double? _currentCommision;
  double get currentCommision => _currentCommision ?? 0.0; // Default to 0.0
  bool hasCurrentCommision() => _currentCommision != null;


  // "commission_percent" field.
  double? _commissionPercent;
  double get commissionPercent => (_commissionPercent ?? 15);
  bool hascommissionPercent() => _commissionPercent != null;

  // "fine" field.
  bool? _fine;
  bool get fine => _fine ?? false; // Default to false
  bool hasFine() => _fine != null;

  // "shift_completion_date_time" field.
  DateTime? _shiftCompletionDateTime;
  DateTime? get shiftCompletionDateTime => _shiftCompletionDateTime;
  bool hasShiftCompletionDateTime() => _shiftCompletionDateTime != null;

  // "shift_start_date_time" field.
  DateTime? _shiftStartDateTime;
  DateTime? get shiftStartDateTime => _shiftStartDateTime;
  bool hasShiftStartDateTime() => _shiftStartDateTime != null;

  // "cityLatlng" field.
  LatLng? _cityLatlng;
  LatLng? get cityLatlng => _cityLatlng;
  bool hasCityLatlng() => _cityLatlng != null;

  // "region" field.
  String? _region;
  String get region => _region ?? ''; // Ensure not null
  bool hasRegion() => _region != null;

  // "additional_phone_number" field.
  String? _additionalPhoneNumber;
  String get additionalPhoneNumber => _additionalPhoneNumber ?? '';
  bool hasAdditionalPhoneNumber() => _additionalPhoneNumber != null;

  // "active_orders_queue" field (multi-orders / «по пути»).
  List<DocumentReference>? _activeOrdersQueue;
  List<DocumentReference> get activeOrdersQueue =>
      _activeOrdersQueue ?? const [];
  bool hasActiveOrdersQueue() => _activeOrdersQueue != null;

  void _initializeFields() {
    print(snapshotData);
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String? ?? (_email ?? '').split('@').first;
    _loginComplete = snapshotData['login_complete'] as bool?;
    _isDriver = snapshotData['is_driver'] as bool?;
    _admin = snapshotData['admin'] as bool?;
    _surname = snapshotData['surname'] as String?;
    _dfb = snapshotData['dfb'] as DateTime?;
    _city = snapshotData['city'] as String?;
    _verifCompl = snapshotData['verif_compl'] is String ? snapshotData['verif_compl'] == 'on' : snapshotData['verif_compl'] as bool?;
    _isBlocked = snapshotData['is_blocked'] as bool?;
    _chatWithSupport = snapshotData['chat_with_support'] as DocumentReference?;
    _balance = (snapshotData['balance'] as num?)?.toDouble(); // Handle null safely
    _bonusBalance = (snapshotData['bonus_balance'] as num?)?.toDouble();
    _averageRating = castToType<double>(snapshotData['average_rating']);
    _onVerifNow = snapshotData['on_verif_now'] as bool?;
    _addresses = getStructList(
      snapshotData['addresses'],
      PointStruct.fromMap,
    );
    _numberOfReviews = castToType<int>(snapshotData['number_of_reviews']);
    _car = snapshotData['car'] is CarStruct
        ? snapshotData['car']
        : CarStruct.maybeFromMap(snapshotData['car']);
    _lastOnline = snapshotData['last_online'] as DateTime?;
    _verifNeProidena = snapshotData['verif_ne_proidena'] is String ? snapshotData['verif_ne_proidena'] != 'on' : snapshotData['verif_ne_proidena'] as bool?;
    _verifId = castToType<int>(snapshotData['verif_id']);
    _emailUser = snapshotData['email_user'] as String?;
    _currentOrder = snapshotData['current_order'] is CurrentOrderStruct
        ? snapshotData['current_order']
        : CurrentOrderStruct.maybeFromMap(snapshotData['current_order']);
    _contractorID = castToType<int>(snapshotData['ContractorID']);
    _onShift = snapshotData['on_shift'] as bool?;
    _commissionPercent = (snapshotData['commission_percent'] as num?)?.toDouble(); // Handle null safely
    _currentCommision = (snapshotData['current_commision'] as num?)?.toDouble(); // Handle null safely
    _fine = snapshotData['fine'] as bool?;
    _shiftCompletionDateTime =
        snapshotData['shift_completion_date_time'] as DateTime?;
    _shiftStartDateTime = snapshotData['shift_start_date_time'] as DateTime?;
    _cityLatlng = snapshotData['cityLatlng'] as LatLng?;
    _region = snapshotData['region'] as String?;
    _additionalPhoneNumber = snapshotData['additional_phone_number'] as String?;
    _activeOrdersQueue = getDataList(snapshotData['active_orders_queue']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? fbId,

  String? displayName,
  String? photoUrl,
  int? commissionPercent,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  bool? loginComplete,
  bool? isDriver,
  bool? admin,
  String? surname,
  DateTime? dfb,
  String? city,
  bool? verifCompl,
  DocumentReference? chatWithSupport,
  double? balance,
  double? bonusBalance,
  double? averageRating,
  bool? onVerifNow,
  int? numberOfReviews,
  CarStruct? car,
  DateTime? lastOnline,
  bool? verifNeProidena,
  int? verifId,
  String? emailUser,
  CurrentOrderStruct? currentOrder,
  int? contractorID,
  bool? onShift,
  double? currentCommision,
  bool? fine,
  DateTime? shiftCompletionDateTime,
  DateTime? shiftStartDateTime,
  LatLng? cityLatlng,
  String? region,
  String? additionalPhoneNumber,
  List<DocumentReference>? activeOrdersQueue,
}) {
  print('firebase id to set $fbId');
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'fb_id':fbId,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'login_complete': loginComplete,
      'is_driver': isDriver,
      'admin': admin,
      'surname': surname,
      'dfb': dfb,
      'city': city,
      'verif_compl': verifCompl,
      'chat_with_support': chatWithSupport,
      'balance': balance,
      'bonus_balance': bonusBalance,
      'average_rating': averageRating,
      'on_verif_now': onVerifNow,
      'number_of_reviews': numberOfReviews,
      'car': CarStruct().toMap(),
      'last_online': lastOnline,
      'verif_ne_proidena': verifNeProidena,
      'verif_id': verifId,
      'email_user': emailUser,
      'current_order': CurrentOrderStruct().toMap(),
      'ContractorID': contractorID,
      'on_shift': onShift,
      'current_commision': currentCommision,
      'fine': fine,
      'shift_completion_date_time': shiftCompletionDateTime,
      'shift_start_date_time': shiftStartDateTime,
      'cityLatlng': cityLatlng,
      'region': region,
      'commission_percent': commissionPercent,
      'additional_phone_number': additionalPhoneNumber,
      'active_orders_queue': activeOrdersQueue,
    }.withoutNulls,
  );

  // Handle nested data for "car" field.
  addCarStructData(firestoreData, car, 'car');

  // Handle nested data for "current_order" field.
  addCurrentOrderStructData(firestoreData, currentOrder, 'current_order');

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.loginComplete == e2?.loginComplete &&
        e1?.isDriver == e2?.isDriver &&
        e1?.admin == e2?.admin &&
        e1?.surname == e2?.surname &&
        e1?.dfb == e2?.dfb &&
        e1?.city == e2?.city &&
        e1?.verifCompl == e2?.verifCompl &&
        e1?.chatWithSupport == e2?.chatWithSupport &&
        e1?.balance == e2?.balance &&
        e1?.bonusBalance == e2?.bonusBalance &&
        e1?.averageRating == e2?.averageRating &&
        e1?.onVerifNow == e2?.onVerifNow &&
        listEquality.equals(e1?.addresses, e2?.addresses) &&
        e1?.numberOfReviews == e2?.numberOfReviews &&
        e1?.car == e2?.car &&
        e1?.lastOnline == e2?.lastOnline &&
        e1?.verifNeProidena == e2?.verifNeProidena &&
        e1?.verifId == e2?.verifId &&
        e1?.emailUser == e2?.emailUser &&
        e1?.currentOrder == e2?.currentOrder &&
        e1?.contractorID == e2?.contractorID &&
        e1?.onShift == e2?.onShift &&
        e1?.currentCommision == e2?.currentCommision &&
        e1?.fine == e2?.fine &&
        e1?.shiftCompletionDateTime == e2?.shiftCompletionDateTime &&
        e1?.shiftStartDateTime == e2?.shiftStartDateTime &&
        e1?.cityLatlng == e2?.cityLatlng &&
        e1?.region == e2?.region &&
        e1?.additionalPhoneNumber == e2?.additionalPhoneNumber &&
        listEquality.equals(e1?.activeOrdersQueue, e2?.activeOrdersQueue);
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.loginComplete,
        e?.isDriver,
        e?.admin,
        e?.surname,
        e?.dfb,
        e?.city,
        e?.verifCompl,
        e?.chatWithSupport,
        e?.balance,
        e?.bonusBalance,
        e?.averageRating,
        e?.onVerifNow,
        e?.addresses,
        e?.numberOfReviews,
        e?.car,
        e?.lastOnline,
        e?.verifNeProidena,
        e?.verifId,
        e?.emailUser,
        e?.currentOrder,
        e?.contractorID,
        e?.onShift,
        e?.currentCommision,
        e?.fine,
        e?.shiftCompletionDateTime,
        e?.shiftStartDateTime,
        e?.cityLatlng,
        e?.region,
        e?.additionalPhoneNumber,
        e?.activeOrdersQueue
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
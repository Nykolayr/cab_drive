import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';

/// JSON для /me/addresses* (без GeoPoint/LatLng объектов).
Map<String, dynamic> pointToApiMap(PointStruct p) {
  final out = <String, dynamic>{};
  final ll = p.latlng;
  if (ll != null) {
    out['latlng'] = {'lat': ll.latitude, 'lng': ll.longitude};
  }
  if (p.hasPlaceID()) out['place_ID'] = p.placeID;
  if (p.hasAddress()) out['address'] = p.address;
  if (p.hasFullAddress()) out['fullAddress'] = p.fullAddress;
  if (p.hasEntrance()) out['entrance'] = p.entrance;
  if (p.hasFloor()) out['Floor'] = p.floor;
  if (p.hasFlat()) out['flat'] = p.flat;
  if (p.hasIntercom()) out['Intercom'] = p.intercom;
  if (p.hasComment()) out['comment'] = p.comment;
  if (p.hasCity()) out['city'] = p.city;
  if (p.hasRegion()) out['region'] = p.region;
  if (p.hasSender()) {
    out['sender'] = p.sender.toMap();
  }
  return out;
}

/// Маппинг cards API → SavedCardsRecord.
class SavedCardsRecordMapper {
  SavedCardsRecordMapper._();

  static SavedCardsRecord fromApi(Map<String, dynamic> m) {
    final id = m['id']?.toString() ?? 'tmp';
    final uid = m['user_id']?.toString() ?? '_';
    final parent = UsersRecord.collection.doc(uid);
    final data = <String, dynamic>{
      'pan': m['pan']?.toString() ?? '',
      'RebillId': m['rebill_id'] ?? m['RebillId'],
    };
    return SavedCardsRecord.getDocumentFromData(
      data,
      SavedCardsRecord.createDoc(parent, id: id),
    );
  }
}

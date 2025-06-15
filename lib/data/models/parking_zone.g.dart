// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingZone _$ParkingZoneFromJson(Map<String, dynamic> json) => ParkingZone(
  id: (json['id'] as num).toInt(),
  zoneTypeId: (json['zone_type_id'] as num).toInt(),
  location:
      (json['location'] as List<dynamic>)
          .map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList(),
);

Map<String, dynamic> _$ParkingZoneToJson(ParkingZone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'zone_type_id': instance.zoneTypeId,
      'location': instance.location,
    };

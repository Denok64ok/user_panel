// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingPlace _$ParkingPlaceFromJson(Map<String, dynamic> json) => ParkingPlace(
  id: (json['id'] as num).toInt(),
  placeNumber: (json['place_number'] as num).toInt(),
  placeStatusId: (json['place_status_id'] as num).toInt(),
  parkingZoneId: (json['parking_zone_id'] as num).toInt(),
);

Map<String, dynamic> _$ParkingPlaceToJson(ParkingPlace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'place_number': instance.placeNumber,
      'place_status_id': instance.placeStatusId,
      'parking_zone_id': instance.parkingZoneId,
    };

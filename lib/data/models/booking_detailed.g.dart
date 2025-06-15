// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_detailed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingDetailed _$BookingDetailedFromJson(Map<String, dynamic> json) =>
    BookingDetailed(
      id: (json['id'] as num).toInt(),
      address: json['address'] as String?,
      zoneName: json['zone_name'] as String?,
      placeNumber: (json['place_number'] as num?)?.toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      carNumber: json['car_number'] as String?,
      bookingStatusName: json['booking_status_name'] as String?,
    );

Map<String, dynamic> _$BookingDetailedToJson(BookingDetailed instance) =>
    <String, dynamic>{
      'id': instance.id,
      'address': instance.address,
      'zone_name': instance.zoneName,
      'place_number': instance.placeNumber,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'car_number': instance.carNumber,
      'booking_status_name': instance.bookingStatusName,
    };

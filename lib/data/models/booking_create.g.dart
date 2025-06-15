// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingCreate _$BookingCreateFromJson(Map<String, dynamic> json) =>
    BookingCreate(
      carUserId: (json['car_user_id'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      parkingPlaceId: (json['parking_place_id'] as num).toInt(),
      bookingStatusId: (json['booking_status_id'] as num).toInt(),
    );

Map<String, dynamic> _$BookingCreateToJson(BookingCreate instance) =>
    <String, dynamic>{
      'car_user_id': instance.carUserId,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'parking_place_id': instance.parkingPlaceId,
      'booking_status_id': instance.bookingStatusId,
    };

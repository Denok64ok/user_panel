// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_finish_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingFinishResponse _$BookingFinishResponseFromJson(
  Map<String, dynamic> json,
) => BookingFinishResponse(
  id: (json['id'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  pricePerMinute: (json['price_per_minute'] as num).toInt(),
  totalPrice: (json['total_price'] as num).toInt(),
  status: json['status'] as String,
);

Map<String, dynamic> _$BookingFinishResponseToJson(
  BookingFinishResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'duration_minutes': instance.durationMinutes,
  'price_per_minute': instance.pricePerMinute,
  'total_price': instance.totalPrice,
  'status': instance.status,
};

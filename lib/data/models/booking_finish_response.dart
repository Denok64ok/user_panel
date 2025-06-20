import 'package:json_annotation/json_annotation.dart';

part 'booking_finish_response.g.dart';

@JsonSerializable()
class BookingFinishResponse {
  final int id;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @JsonKey(name: 'price_per_minute')
  final int pricePerMinute;
  @JsonKey(name: 'total_price')
  final int totalPrice;
  final String status;

  BookingFinishResponse({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.pricePerMinute,
    required this.totalPrice,
    required this.status,
  });

  factory BookingFinishResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingFinishResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BookingFinishResponseToJson(this);
}

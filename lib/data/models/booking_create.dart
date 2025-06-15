import 'package:json_annotation/json_annotation.dart';

part 'booking_create.g.dart';

@JsonSerializable()
class BookingCreate {
  @JsonKey(name: 'car_user_id')
  final int carUserId;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'parking_place_id')
  final int parkingPlaceId;
  @JsonKey(name: 'booking_status_id')
  final int bookingStatusId;

  BookingCreate({
    required this.carUserId,
    required this.startTime,
    required this.endTime,
    required this.parkingPlaceId,
    required this.bookingStatusId,
  });

  factory BookingCreate.fromJson(Map<String, dynamic> json) =>
      _$BookingCreateFromJson(json);
  Map<String, dynamic> toJson() => _$BookingCreateToJson(this);
}

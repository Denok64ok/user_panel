import 'package:json_annotation/json_annotation.dart';

part 'booking_detailed.g.dart';

@JsonSerializable()
class BookingDetailed {
  final int id;
  final String? address;
  @JsonKey(name: 'zone_name')
  final String? zoneName;
  @JsonKey(name: 'place_number')
  final int? placeNumber;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;
  @JsonKey(name: 'car_number')
  final String? carNumber;
  @JsonKey(name: 'booking_status_name')
  final String? bookingStatusName;

  BookingDetailed({
    required this.id,
    this.address,
    this.zoneName,
    this.placeNumber,
    required this.startTime,
    this.endTime,
    this.carNumber,
    this.bookingStatusName,
  });

  factory BookingDetailed.fromJson(Map<String, dynamic> json) =>
      _$BookingDetailedFromJson(json);
  Map<String, dynamic> toJson() => _$BookingDetailedToJson(this);

  DateTime get startDateTime => DateTime.parse(startTime);
  DateTime? get endDateTime =>
      endTime != null ? DateTime.parse(endTime!) : null;
}

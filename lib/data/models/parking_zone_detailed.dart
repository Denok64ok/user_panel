import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'parking_zone_detailed.g.dart';

@JsonSerializable()
class ParkingZoneDetailed {
  final int id;
  @JsonKey(name: 'zone_name')
  final String zoneName;
  @JsonKey(name: 'type_name')
  final String typeName;
  final String address;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'price_per_minute')
  final int pricePerMinute;
  @JsonKey(name: 'total_places')
  final int totalPlaces;
  @JsonKey(name: 'free_places')
  final int freePlaces;
  final List<List<double>> location;
  @JsonKey(name: 'update_time')
  final String updateTime;

  ParkingZoneDetailed({
    required this.id,
    required this.zoneName,
    required this.typeName,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.pricePerMinute,
    required this.totalPlaces,
    required this.freePlaces,
    required this.location,
    required this.updateTime,
  });

  String get formattedUpdateTime {
    try {
      final dateTime = DateTime.parse(updateTime);
      return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    } catch (e) {
      return updateTime;
    }
  }

  factory ParkingZoneDetailed.fromJson(Map<String, dynamic> json) =>
      _$ParkingZoneDetailedFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingZoneDetailedToJson(this);
}

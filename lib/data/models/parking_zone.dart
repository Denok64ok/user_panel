import 'package:json_annotation/json_annotation.dart';

part 'parking_zone.g.dart';

@JsonSerializable()
class ParkingZone {
  final int id;
  @JsonKey(name: 'zone_type_id')
  final int zoneTypeId;
  final List<List<double>> location;

  ParkingZone({
    required this.id,
    required this.zoneTypeId,
    required this.location,
  });

  factory ParkingZone.fromJson(Map<String, dynamic> json) =>
      _$ParkingZoneFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingZoneToJson(this);
}

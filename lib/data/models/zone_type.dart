import 'package:json_annotation/json_annotation.dart';

part 'zone_type.g.dart';

@JsonSerializable()
class ZoneType {
  final int id;
  @JsonKey(name: 'type_name')
  final String typeName;

  ZoneType({required this.id, required this.typeName});

  factory ZoneType.fromJson(Map<String, dynamic> json) =>
      _$ZoneTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ZoneTypeToJson(this);
}

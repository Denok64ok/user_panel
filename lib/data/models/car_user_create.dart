import 'package:json_annotation/json_annotation.dart';

part 'car_user_create.g.dart';

@JsonSerializable()
class CarUserCreate {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'car_id')
  final int carId;

  CarUserCreate({required this.userId, required this.carId});

  factory CarUserCreate.fromJson(Map<String, dynamic> json) =>
      _$CarUserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$CarUserCreateToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'car_user.g.dart';

@JsonSerializable()
class CarUser {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'car_number')
  final String? carNumber;
  @JsonKey(name: 'car_id')
  final int carId;

  CarUser({
    required this.id,
    required this.userId,
    required this.carNumber,
    required this.carId,
  });

  factory CarUser.fromJson(Map<String, dynamic> json) =>
      _$CarUserFromJson(json);
  Map<String, dynamic> toJson() => _$CarUserToJson(this);
}

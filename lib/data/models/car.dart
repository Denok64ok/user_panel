import 'package:json_annotation/json_annotation.dart';

part 'car.g.dart';

@JsonSerializable()
class Car {
  final int id;
  @JsonKey(name: 'car_number')
  final String carNumber;

  Car({required this.id, required this.carNumber});

  factory Car.fromJson(Map<String, dynamic> json) => _$CarFromJson(json);
  Map<String, dynamic> toJson() => _$CarToJson(this);
}

@JsonSerializable()
class CarCreate {
  @JsonKey(name: 'car_number')
  final String carNumber;

  CarCreate({required this.carNumber});

  factory CarCreate.fromJson(Map<String, dynamic> json) =>
      _$CarCreateFromJson(json);
  Map<String, dynamic> toJson() => _$CarCreateToJson(this);
}

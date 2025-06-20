// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Car _$CarFromJson(Map<String, dynamic> json) => Car(
  id: (json['id'] as num).toInt(),
  carNumber: json['car_number'] as String,
);

Map<String, dynamic> _$CarToJson(Car instance) => <String, dynamic>{
  'id': instance.id,
  'car_number': instance.carNumber,
};

CarCreate _$CarCreateFromJson(Map<String, dynamic> json) =>
    CarCreate(carNumber: json['car_number'] as String);

Map<String, dynamic> _$CarCreateToJson(CarCreate instance) => <String, dynamic>{
  'car_number': instance.carNumber,
};

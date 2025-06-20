// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_user_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarUserCreate _$CarUserCreateFromJson(Map<String, dynamic> json) =>
    CarUserCreate(
      userId: (json['user_id'] as num).toInt(),
      carId: (json['car_id'] as num).toInt(),
    );

Map<String, dynamic> _$CarUserCreateToJson(CarUserCreate instance) =>
    <String, dynamic>{'user_id': instance.userId, 'car_id': instance.carId};

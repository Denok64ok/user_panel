// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarUser _$CarUserFromJson(Map<String, dynamic> json) => CarUser(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  carNumber: json['car_number'] as String?,
  carId: (json['car_id'] as num).toInt(),
);

Map<String, dynamic> _$CarUserToJson(CarUser instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'car_number': instance.carNumber,
  'car_id': instance.carId,
};

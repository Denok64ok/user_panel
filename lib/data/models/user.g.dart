// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  userName: json['user_name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  password: json['password'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'user_name': instance.userName,
  'phone': instance.phone,
  'email': instance.email,
  'password': instance.password,
};

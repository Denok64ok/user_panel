import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  @JsonKey(name: 'user_name')
  final String userName;
  final String phone;
  final String email;
  final String? password;

  User({
    required this.id,
    required this.userName,
    required this.phone,
    required this.email,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

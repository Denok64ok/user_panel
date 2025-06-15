import 'package:json_annotation/json_annotation.dart';

part 'camera_snapshot.g.dart';

@JsonSerializable()
class CameraSnapshot {
  final String image;
  final String format;

  CameraSnapshot({required this.image, required this.format});

  factory CameraSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CameraSnapshotFromJson(json);
  Map<String, dynamic> toJson() => _$CameraSnapshotToJson(this);
}

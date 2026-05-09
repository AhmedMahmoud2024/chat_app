import 'package:stream_video_flutter/stream_video_flutter.dart';
import 'package:chat_app/Features/Video%20Calls/domain/entities/call_entity.dart';

class CallUserModel extends User {
  final String id;
  final String name;
  final String image;

  CallUserModel({
    required this.id,
    required this.name,
    required this.image,
  }) : super(
    info: UserInfo(id: id, image: image, name: name),
  );

  factory CallUserModel.fromCallEntity(CallEntity entity) {
    return CallUserModel(
      id: entity.callId,
      name: entity.participantName,
      image: 'https://getstream.io/random_png/?id=${entity.callId}',
    );
  }

  CallEntity toEntity() {
    return CallEntity(
      callId: id,
      participantName: name,
      isVideoEnabled: true,
      isAudioEnabled: true,
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCallEvent extends VideoCallEvent {
  final String userId;
  final String userName;
  final String token;

  const InitializeCallEvent({
    required this.userId,
    required this.userName,
    required this.token,
  });

  @override
  List<Object?> get props => [userId, userName, token];
}

class CreateAndJoinCallEvent extends VideoCallEvent {
  final String callId;
  final List<String> memberIds;

  const CreateAndJoinCallEvent({
    required this.callId,
    required this.memberIds,
  });

  @override
  List<Object?> get props => [callId, memberIds];
}

class ToggleCameraEvent extends VideoCallEvent {
  final bool isEnabled;

  const ToggleCameraEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class ToggleMicEvent extends VideoCallEvent {
  final bool isEnabled;

  const ToggleMicEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class LeaveCallEvent extends VideoCallEvent {
  const LeaveCallEvent();
}

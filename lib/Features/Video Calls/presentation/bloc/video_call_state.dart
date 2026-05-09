import 'package:equatable/equatable.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();

  @override
  List<Object?> get props => [];
}

class VideoCallInitial extends VideoCallState {
  const VideoCallInitial();
}

class VideoCallInitializing extends VideoCallState {
  const VideoCallInitializing();
}

class VideoCallInitialized extends VideoCallState {
  final String userId;

  const VideoCallInitialized({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class VideoCallJoined extends VideoCallState {
  final Call call;

  const VideoCallJoined({required this.call});

  @override
  List<Object?> get props => [call];
}

class VideoCallLoading extends VideoCallState {
  const VideoCallLoading();
}

class VideoCallError extends VideoCallState {
  final String message;

  const VideoCallError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CameraToggled extends VideoCallState {
  final bool isEnabled;

  const CameraToggled({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class MicToggled extends VideoCallState {
  final bool isEnabled;

  const MicToggled({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}

class VideoCallEnded extends VideoCallState {
  const VideoCallEnded();
}

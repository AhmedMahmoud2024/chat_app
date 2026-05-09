import 'package:stream_video_flutter/stream_video_flutter.dart';

abstract class VideoCallRepository {
  Future<void> initializeCall(String userId, String userName, String token);
  Future<Call> createAndJoinCall(String callId, List<String> memberIds);
  Future<void> leaveCall();
  Future<void> toggleCamera(bool isEnabled);
  Future<void> toggleMic(bool isEnabled);
}
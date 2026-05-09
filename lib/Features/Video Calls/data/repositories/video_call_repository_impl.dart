import 'package:chat_app/Features/Video%20Calls/data/dataSources/stream_manager_data_source.dart';
import 'package:chat_app/Features/Video%20Calls/domain/repository/video_call_repository.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  final StreamManagerDataSource dataSource;

  VideoCallRepositoryImpl({required this.dataSource});

  @override
  Future<void> initializeCall(String userId, String userName, String token) async {
    return await dataSource.initializeStreamClient(userId, userName, token);
  }

  @override
  Future<Call> createAndJoinCall(String callId, List<String> memberIds) async {
    return await dataSource.createAndJoinCall(callId, memberIds);
  }

  @override
  Future<void> leaveCall() async {
    return await dataSource.leaveCall();
  }

  @override
  Future<void> toggleCamera(bool isEnabled) async {
    return await dataSource.toggleCamera(isEnabled);
  }

  @override
  Future<void> toggleMic(bool isEnabled) async {
    return await dataSource.toggleMic(isEnabled);
  }
}

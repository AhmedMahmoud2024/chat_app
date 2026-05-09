import 'dart:developer';
import 'package:chat_app/Core/Network/video_service.dart';
import 'package:chat_app/Core/constants/secrets.dart';
import 'package:chat_app/Features/Video%20Calls/data/models/call_user_model.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

abstract class StreamManagerDataSource {
  Future<void> initializeStreamClient(
    String userId,
    String userName,
    String token,
  );
  
  Future<Call> createAndJoinCall(String callId, List<String> memberIds);
  Future<void> leaveCall();
  Future<void> toggleCamera(bool isEnabled);
  Future<void> toggleMic(bool isEnabled);
  StreamVideo getStreamClient();
}

class StreamManagerDataSourceImpl implements StreamManagerDataSource {
  static StreamVideo? _client;

  StreamVideo _getStreamClient() {
    if (_client == null) {
      throw Exception('Stream client not initialized. Call initializeStreamClient() first.');
    }
    return _client!;
  }

  @override
  Future<void> initializeStreamClient(
    String userId,
    String userName,
    String token,
  ) async {
    if (_client != null) {
      log('[StreamManagerDataSource] Stream Client already initialized, skipping');
      return;
    }

    try {
      log('[StreamManagerDataSource] Initializing Stream client for userId: $userId');

      // Create user model
      final user = CallUserModel(
        id: userId,
        name: userName,
        image: 'https://getstream.io/random_png/?id=$userId',
      );

      // Get Stream API key from environment
      final apiKey = AppSecrets.apiKey;
      if (apiKey.isEmpty) {
        throw Exception('STREAM_API_KEY not configured');
      }

      log('[StreamManagerDataSource] Creating StreamVideo client with apiKey: $apiKey');

      // Initialize Stream client
      _client = StreamVideo(
        apiKey,
        user: user,
        userToken: token,
      );

      log('[StreamManagerDataSource] Stream client initialized successfully');
    } catch (e, stackTrace) {
      log('[StreamManagerDataSource] Error initializing Stream client: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<Call> createAndJoinCall(String callId, List<String> memberIds) async {
    try {
      log('[StreamManagerDataSource] Creating and joining call: $callId with members: $memberIds');

      final streamClient = _getStreamClient();

      // Create call
      final call = streamClient.makeCall(
        callType: StreamCallType.liveStream(),
        id: callId,
      );

      // Join call with members
      await call.getOrCreate(memberIds: memberIds);

      log('[StreamManagerDataSource] Call created and joined successfully: $callId');
      return call;
    } catch (e, stackTrace) {
      log('[StreamManagerDataSource] Error creating/joining call: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> leaveCall() async {
    try {
      log('[StreamManagerDataSource] User leaving call');
      // Call leave logic can be implemented as needed
    } catch (e, stackTrace) {
      log('[StreamManagerDataSource] Error leaving call: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> toggleCamera(bool isEnabled) async {
    try {
      log('[StreamManagerDataSource] Toggling camera to: $isEnabled');
      // Toggle camera logic can be implemented with call instance
    } catch (e, stackTrace) {
      log('[StreamManagerDataSource] Error toggling camera: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> toggleMic(bool isEnabled) async {
    try {
      log('[StreamManagerDataSource] Toggling mic to: $isEnabled');
      // Toggle mic logic can be implemented with call instance
    } catch (e, stackTrace) {
      log('[StreamManagerDataSource] Error toggling mic: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  StreamVideo getStreamClient() {
    return _getStreamClient();
  }
}
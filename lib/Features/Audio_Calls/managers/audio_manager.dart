import 'dart:async';
import 'dart:developer';

import 'package:chat_app/Core/Network/video_service.dart';
import 'package:chat_app/Features/video_%20service/managers/stream_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stream_video/stream_video.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  Call? _currentCall;
  bool _isInitialized = false;

  AudioManager._internal();

  static AudioManager get instance => _instance;

  Call? get currentCall => _currentCall;

  bool get isInitialized => _isInitialized;

  /// Initialize StreamManager if needed and prepare for audio calls
  Future<void> init() async {
    if (_isInitialized) {
      log('[AudioManager] Stream client already initialized, skipping');
      return;
    }

    try {
      log('[AudioManager] Initializing Stream client for audio calls');

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get Stream token
      final token = await VideoService.getStreamToken(currentUser.uid);
      if (token == null) {
        throw Exception('Failed to get Stream token');
      }

      log('[AudioManager] Token obtained, initializing Stream manager');

      // Initialize StreamManager
      await StreamManager.init(
        currentUser.uid,
        currentUser.displayName ?? 'User',
        token,
      );

      _isInitialized = true;
      log('[AudioManager] Stream client initialized successfully');
    } catch (e) {
      log('[AudioManager] Error initializing Stream: $e');
      rethrow;
    }
  }

  /// Create and join an audio call (disables video)
  Future<Call> createAudioCall({
    required String callId,
    required List<String> memberIds,
  }) async {
    if (!_isInitialized) {
      throw Exception(
          'Stream client not initialized. Call init() first.');
    }

    try {
      log('[AudioManager] Creating audio call: $callId with members: $memberIds');

      // Create call with video disabled
      final call = StreamManager.streamClient.makeCall(
        callType: StreamCallType.defaultType(),
        id: callId,
      );

      // Create or join the call
      await call.getOrCreate(memberIds: memberIds);

      // Disable camera for audio-only call
      await call.setCameraEnabled(enabled: false);
      await call.setMicrophoneEnabled(enabled: true);

      _currentCall = call;

      log('[AudioManager] Audio call created successfully: $callId');
      return call;
    } catch (e) {
      log('[AudioManager] Error creating audio call: $e');
      rethrow;
    }
  }

  /// Leave the current audio call
  Future<void> leaveCall() async {
    if (_currentCall == null) {
      log('[AudioManager] No active call to leave');
      return;
    }

    try {
      log('[AudioManager] Leaving audio call');
      await _currentCall!.leave();
      _currentCall = null;
      log('[AudioManager] Successfully left audio call');
    } catch (e) {
      log('[AudioManager] Error leaving call: $e');
      rethrow;
    }
  }

  /// Toggle microphone on/off
  Future<void> setMicrophoneEnabled(bool enabled) async {
    if (_currentCall == null) {
      throw Exception('No active call');
    }

    try {
      await _currentCall!.setMicrophoneEnabled(enabled: enabled);
      log('[AudioManager] Microphone ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      log('[AudioManager] Error toggling microphone: $e');
      rethrow;
    }
  }

  /// Toggle speaker on/off
  Future<void> setSpeakerEnabled(bool enabled) async {
    if (_currentCall == null) {
      throw Exception('No active call');
    }

    try {
      // Stream Video handles audio routing automatically
      // This is a placeholder for speaker control if needed
      log('[AudioManager] Speaker ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      log('[AudioManager] Error toggling speaker: $e');
      rethrow;
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    try {
      if (_currentCall != null) {
        log('[AudioManager] Disposing audio call');
        await leaveCall();
      }
      _isInitialized = false;
      log('[AudioManager] Audio manager disposed successfully');
    } catch (e) {
      log('[AudioManager] Error disposing: $e');
      rethrow;
    }
  }
}

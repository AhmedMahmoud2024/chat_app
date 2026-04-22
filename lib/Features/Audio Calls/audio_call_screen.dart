import 'dart:async';
import 'dart:developer';
import 'package:chat_app/Core/Network/call_service.dart';
import 'package:chat_app/Core/Network/firebase_auth_service.dart';
import 'package:chat_app/Core/Network/socket_service.dart';
import 'package:chat_app/Features/Audio%20Calls/widgets/audio_only_call_content.dart';
import 'package:chat_app/Features/Audio%20Calls/widgets/initialization_error_widget.dart';
import 'package:chat_app/Features/Audio%20Calls/widgets/is_initializing_widget.dart';
import 'package:chat_app/Features/Audio_Calls/managers/audio_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class AudioCallScreen extends StatefulWidget {
  final String callId;
  final List<String> memberIds;
  final String remoteUserName;

  const AudioCallScreen({
    super.key,
    required this.callId,
    required this.memberIds,
    required this.remoteUserName,
  });

 

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  bool _isInitializing = false;
   String? initializationError;

  @override
  void initState() {
    super.initState();
   SocketService.connect(myUserId: FirebaseAuth.instance.currentUser!.uid);
    log('[AudioCallScreen] initState: Initializing audio call for callId=${widget.callId}');
    _initializeAudioCall();
  }

  /// Initialize audio call with error handling
  Future<void> _initializeAudioCall() async {
    if (_isInitializing) {
      log('[AudioCallScreen] Audio call initialization already in progress');
      return;
    }

    setState(() {
      _isInitializing = true;
      initializationError = null;
    });

    try {
      log('[AudioCallScreen] Initializing Stream client for audio call');

      // Initialize AudioManager (which initializes StreamManager)
      await AudioManager.instance.init();

      log('[AudioCallScreen] Creating audio call with callId: ${widget.callId}');

      // Create audio call
      final call = await AudioManager.instance.createAudioCall(
        callId: widget.callId,
        memberIds: widget.memberIds,
      );

      log('[AudioCallScreen] Audio call created successfully');

      // Navigate to call screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreamCallContainer(
              call: call,
              callContentWidgetBuilder: (context, call) {
                return AudioOnlyCallContent(
                  call: call,
                  remoteUserName: widget.remoteUserName,
                  callId: widget.callId,
                );
              },
            ),
          ),
        );
      }
    } on TimeoutException catch (e) {
      log('[AudioCallScreen] ✗ Timeout during audio call initialization: $e');
      _handleInitializationError('Connection timeout. Please check your network and try again.');
    } catch (e, stackTrace) {
      log('[AudioCallScreen] ✗ Error during audio call initialization: $e\nStackTrace: $stackTrace');
      _handleInitializationError('Failed to initialize audio call: $e');
    }
  }

  /// Handle initialization errors
  void _handleInitializationError(String errorMessage) {
    log('[AudioCallScreen] Handling error: $errorMessage');

    setState(() {
      _isInitializing = false;
      initializationError = errorMessage;
    });

    // Show error dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Audio Call Error'),
          content: Text(initializationError ?? 'An unexpected error occurred'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit call screen
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initializeAudioCall(); // Retry
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    log('[AudioCallScreen] dispose: Cleaning up audio call');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return IsInitializingWidget();
    }

    if (initializationError != null) {
      return InitializationErrorWidget(initializationError);
    }

    // Show loading while initializing
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

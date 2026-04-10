import 'dart:async';
import 'dart:developer';

import 'package:chat_app/Core/Network/call_service.dart';
import 'package:chat_app/Core/Network/firebase_auth_service.dart';
import 'package:chat_app/Core/Network/socket_service.dart';
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
  String? _initializationError;

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
      _initializationError = null;
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
                return _AudioOnlyCallContent(
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
      _initializationError = errorMessage;
    });

    // Show error dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Audio Call Error'),
          content: Text(_initializationError ?? 'An unexpected error occurred'),
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
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Initializing audio call...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Connecting...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_initializationError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 64,
                ),
                const SizedBox(height: 20),
                Text(
                  _initializationError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
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

/// Custom audio-only call UI that hides video and shows only audio controls
class _AudioOnlyCallContent extends StatefulWidget {
  final Call call;
  final String remoteUserName;
  final String callId;

  const _AudioOnlyCallContent({
    required this.call,
    required this.remoteUserName,
    required this.callId,
  });

  @override
  State<_AudioOnlyCallContent> createState() => _AudioOnlyCallContentState();
}

class _AudioOnlyCallContentState extends State<_AudioOnlyCallContent> {
  late DateTime _callStartTime;
  int _elapsedSeconds = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _callStartTime = DateTime.now();
    
    // Start timer to update elapsed time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = DateTime.now().difference(_callStartTime).inSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Format elapsed time as hh:mm:ss
  String _formatElapsedTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Save call log when ending the call
  Future<void> _endCallAndSaveLog() async {
    final callDuration = DateTime.now().difference(_callStartTime).inSeconds;
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      // Determine call status (for now, assume completed)
      final status = 'completed'; // Could be 'missed' or 'declined' based on logic
      
      // Save to MongoDB via Node.js backend
      final success = await CallService().saveCallLog(
        callId: widget.callId,
        callerId: currentUser.uid,
        calleeId: 'remote_user_id', // TODO: Get actual remote user ID
        callerName: currentUser.displayName ?? 'Unknown',
        calleeName: widget.remoteUserName,
        status: status,
        callType: 'audio',
        duration: callDuration,
      );
      
      log('[AudioCallScreen] Call log ${success ? 'saved' : 'failed to save'}');
    }
    
    // Leave the call
    await AudioManager.instance.leaveCall();
    
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Audio-only UI (no video)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    widget.remoteUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Connected',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Display elapsed time
                  Text(
                    _formatElapsedTime(_elapsedSeconds),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            // Audio controls at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Microphone toggle
                    FloatingActionButton(
                      heroTag: 'mic',
                      backgroundColor: Colors.white,
                      onPressed: () {
                        widget.call.setMicrophoneEnabled(enabled: true);
                      },
                      child: const Icon(
                        Icons.mic,
                        color: Colors.black,
                      ),
                    ),
                    // End call
                    FloatingActionButton(
                      heroTag: 'EndCall',
                      backgroundColor: Colors.red,
                      onPressed: _endCallAndSaveLog,
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                      ),
                    ),
                    // Speaker toggle
                    FloatingActionButton(
                      heroTag: 'speaker',
                      backgroundColor: Colors.white,
                      onPressed: () {
                        log('[AudioCall] Speaker toggled');
                      },
                      child: const Icon(
                        Icons.volume_up,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

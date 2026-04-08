import 'dart:developer';

import 'package:chat_app/Core/Network/video_service.dart';
import 'package:chat_app/Features/video_%20service/managers/stream_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

class VideoCalls extends StatefulWidget {
  final String callId;
  final List<String> memberIds;

  const VideoCalls({
    super.key,
    required this.callId,
    required this.memberIds,
  });

  @override
  State<VideoCalls> createState() => _VideoCallsState();
}

class _VideoCallsState extends State<VideoCalls> {
  bool _isInitializing = false;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    log('[VideoCalls] initState: Initializing video call for callId=${widget.callId}');
    _initializeVideoCall();
  }

  /// Initialize video call with error handling and retry logic
  Future<void> _initializeVideoCall() async {
    if (_isInitializing) {
      log('[VideoCalls] Video call initialization already in progress');
      return;
    }

    setState(() {
      _isInitializing = true;
      _initializationError = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      log('[VideoCalls] Fetching Stream token for userId: ${currentUser.uid}');

      // Get Stream token (with retry logic handled in VideoService)
      final token = await VideoService.getStreamToken(currentUser.uid);
      if (token == null) {
        throw Exception('Failed to fetch Stream token after max retries');
      }

      log('[VideoCalls] Token obtained, initializing Stream client');

      // Initialize Stream client
      await StreamManager.init(
        currentUser.uid,
        currentUser.displayName ?? 'User',
        token,
      );

      log('[VideoCalls] Stream client initialized, creating call');

      // Create and join call
      final call = StreamManager.streamClient.makeCall(
        callType: StreamCallType.defaultType(),
        id: widget.callId,
      );
       
      await call.getOrCreate(memberIds: widget.memberIds);
         
         Call? Videocall ;
      setState(() {
        Videocall= call;
      });
      // Call created successfully
      log('[VideoCalls] Call created successfully: ${widget.callId}');

      // Navigate to call screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StreamCallContainer(
              call: call,
              callContentWidgetBuilder: (context, call) {
                return StreamCallContent(call: call);
              },
            ),
          ),
        );
      }
    } on TimeoutException catch (e) {
      log('[VideoCalls] ✗ Timeout during video call initialization: $e');
      _handleInitializationError('Connection timeout. Please check your network and try again.');
    } catch (e, stackTrace) {
      log('[VideoCalls] ✗ Error during video call initialization: $e\nStackTrace: $stackTrace');
      _handleInitializationError('Failed to initialize video call: $e');
    }
  }

  /// Handle initialization errors
  void _handleInitializationError(String errorMessage) {
    log('[VideoCalls] Handling error: $errorMessage');
    
    setState(() {
      _isInitializing = false;
      _initializationError = errorMessage;
    });

    // Show error dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Video Call Error'),
          content: Text(_initializationError ?? 'An unexpected error occurred'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initializeVideoCall(); // Retry
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
    log('[VideoCalls] dispose: Cleaning up video call');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  Call? Videocall ;
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Call')),
        body: Videocall == null ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to call...'),
            ],
          ),
        ) :StreamCallContainer(call: Videocall!)
        ,
      );
    }

    if (_initializationError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video Call Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _initializationError ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeVideoCall,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Call initialized successfully
    return Scaffold(
      body: Center(
        child: Text('Video call initialized: ${widget.callId}'),
      ),
    );
  }
}
import 'dart:async';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static late IO.Socket socket;
  static String? _currentUserId;
  static bool _isConnecting = false;
  static Timer? _reconnectTimer;
  static int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 10;
  static const Duration baseReconnectDelay = Duration(seconds: 1);
  static const int connectionTimeout = 10;

  /// Registry to track listeners for cleanup
  static final Map<String, Function?> _listeners = {};

  static bool get isConnected => socket.connected;

  static Future<void> connect({required String myUserId}) async {
    if (_isConnecting || (socket.connected)) {
      log('[SocketService] Already connecting or connected, skipping duplicate connect');
      return;
    }

    _isConnecting = true;
    _currentUserId = myUserId;
    _reconnectAttempts = 0;

    try {
      socket = IO.io(
        'http://192.168.0.106:3000',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': true,
          'reconnection': true,
          'reconnectionDelay': 500,
          'reconnectionDelayMax': 5000,
          'reconnectionAttempts': maxReconnectAttempts,
          'timeout': connectionTimeout * 1000,
        },
      );

      // Connection established
      socket.onConnect((_) {
        log('[SocketService] ✓ Connected to Node.js server (userId: $myUserId)');
        _reconnectAttempts = 0;
        _cancelReconnectTimer();
        socket.emit('store-user', myUserId);
        _isConnecting = false;
      });

      // Connection error
      socket.onConnectError((error) {
        log('[SocketService] ✗ Connection error: $error');
        _handleConnectionError();
      });

      // Disconnection
      socket.onDisconnect((_) {
        log('[SocketService] ✗ Disconnected from Node.js server');
        _isConnecting = false;
        _scheduleReconnect();
      });

      // Generic error event
      socket.on('error', (error) {
        log('[SocketService] ✗ Socket error event: $error');
        _handleConnectionError();
      });

      // Connection timeout
      socket.on('connect_timeout', (_) {
        log('[SocketService] ✗ Connection timeout (after ${connectionTimeout}s)');
        _handleConnectionError();
      });
    } catch (e) {
      log('[SocketService] Failed to initialize socket: $e');
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  /// Register listener and track for cleanup
  static void on(String eventName, Function(dynamic)? callback) {
    if (!socket.connected) {
      log('[SocketService] Warning: Registering listener "$eventName" but socket not connected');
    }
    _listeners[eventName] = callback;
    if (callback != null) {
      socket.on(eventName, (data) => callback(data));
    }
    log('[SocketService] Listener registered for: $eventName');
  }

  /// Emit event with connection check
  static void emit(String eventName, dynamic data) {
    if (!socket.connected) {
      log('[SocketService] ⚠ Emit "$eventName" called but socket not connected. Queuing...');
      // Could implement event queue here for resilience
      return;
    }
    socket.emit(eventName, data);
    log('[SocketService] Event emitted: $eventName');
  }

  /// Cleanup all listeners to prevent memory leaks
  static void _cleanupListeners() {
    for (final eventName in _listeners.keys) {
      socket.off(eventName);
    }
    _listeners.clear();
    log('[SocketService] All listeners cleaned up (${_listeners.length} removed)');
  }

  /// Handle connection errors with reconnect scheduling
  static void _handleConnectionError() {
    _isConnecting = false;
    _scheduleReconnect();
  }

  /// Schedule reconnection with exponential backoff
  static void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      log('[SocketService] ✗ Max reconnection attempts ($maxReconnectAttempts) reached. Manual intervention needed.');
      return;
    }

    _cancelReconnectTimer();
    _reconnectAttempts++;

    // Exponential backoff: 1s, 2s, 4s, 8s, etc. (capped at 30s)
    final delayMs = (baseReconnectDelay.inMilliseconds *
            (1 << (_reconnectAttempts - 1)))
        .clamp(0, 30000);
    final delay = Duration(milliseconds: delayMs);

    log('[SocketService] Scheduling reconnection attempt $_reconnectAttempts/$maxReconnectAttempts after ${delay.inSeconds}s');

    _reconnectTimer = Timer(delay, () {
      if (!socket.connected && _currentUserId != null) {
        log('[SocketService] Attempting reconnect (attempt $_reconnectAttempts)...');
        socket.connect();
      }
    });
  }

  /// Cancel pending reconnect timer
  static void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Graceful disconnect and cleanup
  static Future<void> disconnect() async {
    log('[SocketService] Disconnecting and cleaning up...');
    _cancelReconnectTimer();
    _cleanupListeners();
    socket.disconnect();
    socket.dispose();
    _isConnecting = false;
    _currentUserId = null;
    log('[SocketService] Disconnected and cleaned up successfully');
  }

  /// Force reconnect immediately
  static void forceReconnect() {
    if (_currentUserId == null) {
      log('[SocketService] Cannot force reconnect: currentUserId is null');
      return;
    }
    log('[SocketService] Force reconnect triggered');
    disconnect().then((_) => connect(myUserId: _currentUserId!));
  }

  /// Get connection status info
  static String getConnectionStatus() {
    return 'Connected: $isConnected | UserId: $_currentUserId | Reconnect Attempts: $_reconnectAttempts/$maxReconnectAttempts';
  }
}
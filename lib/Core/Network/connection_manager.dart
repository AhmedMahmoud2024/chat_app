import 'dart:async';
import 'dart:developer';

import 'package:chat_app/Core/Network/socket_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Manages all real-time connections and provides unified status/diagnostics
/// Monitors network status and coordinates connection recovery
class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  
  ConnectivityResult _currentConnectivity = ConnectivityResult.none;
  final List<ConnectionStatusListener> _statusListeners = [];
  
  // Connection health metrics
  int _totalConnectionAttempts = 0;
  int _successfulConnections = 0;
  int _failedConnections = 0;
  DateTime? _lastConnectionTime;
  
  bool _isInitialized = false;

  factory ConnectionManager() {
    return _instance;
  }

  ConnectionManager._internal();

  /// Initialize connection monitoring
  Future<void> initialize() async {
    if (_isInitialized) {
      log('[ConnectionManager] Already initialized');
      return;
    }

    _isInitialized = true;
    log('[ConnectionManager] Initializing connection monitoring...');

    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _currentConnectivity = result.first;
      log('[ConnectionManager] Initial connectivity status: $_currentConnectivity');

      // Monitor connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (error) {
          log('[ConnectionManager] Error monitoring connectivity: $error');
        },
      );

      log('[ConnectionManager] Connectivity monitoring started');
    } catch (e) {
      log('[ConnectionManager] Failed to initialize: $e');
      _isInitialized = false;
    }
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final newConnectivity = results.isNotEmpty ? results.first : ConnectivityResult.none;
    
    if (newConnectivity == _currentConnectivity) {
      return; // No change
    }

    _currentConnectivity = newConnectivity;
    log('[ConnectionManager] Connectivity changed: $_currentConnectivity');

    if (_currentConnectivity == ConnectivityResult.none) {
      log('[ConnectionManager] ✗ Network disconnected');
      _notifyStatusChange(ConnectionStatus.offline);
    } else {
      log('[ConnectionManager] ✓ Network connected');
      _notifyStatusChange(ConnectionStatus.online);
      
      // If socket is disconnected, try to reconnect
      if (!SocketService.isConnected) {
        log('[ConnectionManager] Network restored, attempting to reconnect Socket.IO...');
        SocketService.forceReconnect();
      }
    }
  }

  /// Register listener for connection status changes
  void addStatusListener(ConnectionStatusListener listener) {
    _statusListeners.add(listener);
    log('[ConnectionManager] Status listener registered');
  }

  /// Remove status listener
  void removeStatusListener(ConnectionStatusListener listener) {
    _statusListeners.remove(listener);
    log('[ConnectionManager] Status listener removed');
  }

  /// Notify all listeners of status change
  void _notifyStatusChange(ConnectionStatus status) {
    for (final listener in _statusListeners) {
      listener(status);
    }
  }

  /// Record connection attempt
  void recordConnectionAttempt({required bool successful}) {
    _totalConnectionAttempts++;
    if (successful) {
      _successfulConnections++;
      _lastConnectionTime = DateTime.now();
      log('[ConnectionManager] Connection attempt #$_totalConnectionAttempts: SUCCESS');
    } else {
      _failedConnections++;
      log('[ConnectionManager] Connection attempt #$_totalConnectionAttempts: FAILED');
    }
  }

  /// Get connection health metrics
  ConnectionHealthMetrics getHealthMetrics() {
    final successRate = _totalConnectionAttempts > 0
        ? (_successfulConnections / _totalConnectionAttempts * 100).toStringAsFixed(2)
        : 'N/A';

    return ConnectionHealthMetrics(
      totalAttempts: _totalConnectionAttempts,
      successfulConnections: _successfulConnections,
      failedConnections: _failedConnections,
      successRate: successRate,
      lastConnectionTime: _lastConnectionTime,
      isNetworkOnline: _currentConnectivity != ConnectivityResult.none,
      isSocketConnected: SocketService.isConnected,
    );
  }

  /// Get comprehensive status
  String getDetailedStatus() {
    final metrics = getHealthMetrics();
    return '''
[Connection Status]
Network: ${metrics.isNetworkOnline ? '✓ Online' : '✗ Offline'}
Socket.IO: ${metrics.isSocketConnected ? '✓ Connected' : '✗ Disconnected'}
Total Attempts: ${metrics.totalAttempts}
Successful: ${metrics.successfulConnections}
Failed: ${metrics.failedConnections}
Success Rate: ${metrics.successRate}%
Last Connection: ${metrics.lastConnectionTime?.toIso8601String() ?? 'Never'}
Socket Status: ${SocketService.getConnectionStatus()}
    ''';
  }

  /// Reset metrics (for testing)
  void resetMetrics() {
    _totalConnectionAttempts = 0;
    _successfulConnections = 0;
    _failedConnections = 0;
    _lastConnectionTime = null;
    log('[ConnectionManager] Metrics reset');
  }

  /// Cleanup
  Future<void> dispose() async {
    log('[ConnectionManager] Disposing...');
    await _connectivitySubscription.cancel();
    _statusListeners.clear();
    _isInitialized = false;
    log('[ConnectionManager] Disposed');
  }

  /// Utility to check if any real-time connection is available
  bool get hasActiveConnection {
    return SocketService.isConnected && _currentConnectivity != ConnectivityResult.none;
  }
}

/// Callback type for connection status changes
typedef ConnectionStatusListener = void Function(ConnectionStatus status);

/// Connection status enum
enum ConnectionStatus {
  online,
  offline,
  reconnecting,
  error,
}

/// Connection health metrics
class ConnectionHealthMetrics {
  final int totalAttempts;
  final int successfulConnections;
  final int failedConnections;
  final String successRate;
  final DateTime? lastConnectionTime;
  final bool isNetworkOnline;
  final bool isSocketConnected;

  ConnectionHealthMetrics({
    required this.totalAttempts,
    required this.successfulConnections,
    required this.failedConnections,
    required this.successRate,
    required this.lastConnectionTime,
    required this.isNetworkOnline,
    required this.isSocketConnected,
  });

  Map<String, dynamic> toJson() => {
    'totalAttempts': totalAttempts,
    'successfulConnections': successfulConnections,
    'failedConnections': failedConnections,
    'successRate': successRate,
    'lastConnectionTime': lastConnectionTime?.toIso8601String(),
    'isNetworkOnline': isNetworkOnline,
    'isSocketConnected': isSocketConnected,
  };
}

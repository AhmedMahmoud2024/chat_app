import 'dart:developer';
import 'package:intl/intl.dart';

/// Logs and tracks metrics for real-time call quality and connectivity
class CallQualityLogger {
  static final CallQualityLogger _instance = CallQualityLogger._internal();
  
  final List<CallLogEntry> _callLogs = [];
  final List<MetricSnapshot> _metricsHistory = [];
  
  static const int maxLogEntries = 1000;
  static const int maxMetricsHistory = 500;

  factory CallQualityLogger() {
    return _instance;
  }

  CallQualityLogger._internal();

  /// Log call initiation
  void logCallStart({
    required String callId,
    required String userId,
    required String remoteUserId,
    String? callType = 'video',
  }) {
    final entry = CallLogEntry.start(
      callId: callId,
      userId: userId,
      remoteUserId: remoteUserId,
      callType: callType,
      timestamp: DateTime.now(),
    );
    _addLogEntry(entry);
    log('[CallQualityLogger] Call started: $callId');
  }

  /// Log successful token fetch
  void logTokenFetchSuccess({
    required String userId,
    required int latencyMs,
    int? retryCount = 0,
  }) {
    final entry = CallLogEntry.tokenFetch(
      success: true,
      userId: userId,
      latencyMs: latencyMs,
      retryCount: retryCount ?? 0,
      timestamp: DateTime.now(),
    );
    _addLogEntry(entry);
    log('[CallQualityLogger] Token fetch success - latency: ${latencyMs}ms, retries: $retryCount');
  }

  /// Log failed token fetch attempt
  void logTokenFetchFailure({
    required String userId,
    required String reason,
    required int retryCount,
  }) {
    final entry = CallLogEntry.tokenFetchFailure(
      userId: userId,
      reason: reason,
      totalRetries: retryCount,
      timestamp: DateTime.now(),
    );
    _addLogEntry(entry);
    log('[CallQualityLogger] Token fetch failed - reason: $reason, retries: $retryCount');
  }

  /// Log socket connection event
  void logSocketConnection({
    required bool successful,
    required int latencyMs,
    String? reason,
  }) {
    final entry = CallLogEntry.socketEvent(
      event: successful ? 'connected' : 'failed',
      latencyMs: latencyMs,
      details: reason,
      timestamp: DateTime.now(),
    );
    _addLogEntry(entry);
    log('[CallQualityLogger] Socket ${successful ? "connected" : "failed"} - latency: ${latencyMs}ms');
  }

  /// Log socket disconnection
  void logSocketDisconnection({
    String? reason,
    required int durationSeconds,
  }) {
    final entry = CallLogEntry.socketEvent(
      event: 'disconnected',
      latencyMs: durationSeconds * 1000,
      details: reason,
      timestamp: DateTime.now(),
    );
    _addLogEntry(entry);
    log('[CallQualityLogger] Socket disconnected - duration: ${durationSeconds}s, reason: $reason');
  }

  /// Log call ended
  void logCallEnd({
    required String callId,
    required int durationSeconds,
    String? reason,
  }) {
    final entry = CallLogEntry.end(
      callId: callId,
      durationSeconds: durationSeconds,
      endReason: reason,
      timestamp: DateTime.now(),
    );
    _addLogEntry(entry);
    log('[CallQualityLogger] Call ended: $callId - duration: ${durationSeconds}s, reason: $reason');
  }

  /// Record a metric snapshot
  void recordMetricSnapshot({
    required double socketLatencyMs,
    required double callConnectTimeMs,
    required bool socketConnected,
    required int activeCallCount,
    required int queuedEvents,
  }) {
    final snapshot = MetricSnapshot(
      timestamp: DateTime.now(),
      socketLatencyMs: socketLatencyMs,
      callConnectTimeMs: callConnectTimeMs,
      socketConnected: socketConnected,
      activeCallCount: activeCallCount,
      queuedEvents: queuedEvents,
    );
    _metricsHistory.add(snapshot);

    // Keep size bounded
    if (_metricsHistory.length > maxMetricsHistory) {
      _metricsHistory.removeAt(0);
    }

    log('[CallQualityLogger] Metric recorded - socket latency: ${socketLatencyMs.toStringAsFixed(2)}ms, call connect: ${callConnectTimeMs.toStringAsFixed(2)}ms');
  }

  /// Get call summary statistics
  CallStatistics getStatistics() {
    if (_callLogs.isEmpty) {
      return CallStatistics.empty();
    }

    final callStarts = _callLogs.where((e) => e.type == 'call_start').length;
    final callEnds = _callLogs.where((e) => e.type == 'call_end').length;
    final tokenFetches = _callLogs.where((e) => e.type == 'token_fetch').length;
    final successfulTokens = _callLogs.where((e) => e.type == 'token_fetch' && e.details?['success'] == true).length;

    final durationMs = _metricsHistory.isNotEmpty
        ? _metricsHistory.last.timestamp.difference(_metricsHistory.first.timestamp).inMilliseconds
        : 0;

    final avgSocketLatency = _metricsHistory.isNotEmpty
        ? _metricsHistory.map((m) => m.socketLatencyMs).reduce((a, b) => a + b) / _metricsHistory.length
        : 0.0;

    final avgCallConnectTime = _metricsHistory.isNotEmpty
        ? _metricsHistory.map((m) => m.callConnectTimeMs).reduce((a, b) => a + b) / _metricsHistory.length
        : 0.0;

    return CallStatistics(
      totalCalls: callStarts,
      completedCalls: callEnds,
      totalTokenFetches: tokenFetches,
      successfulTokenFetches: successfulTokens,
      uptime: durationMs,
      avgSocketLatencyMs: avgSocketLatency,
      avgCallConnectTimeMs: avgCallConnectTime,
      logEntryCount: _callLogs.length,
    );
  }

  /// Get recent logs
  List<CallLogEntry> getRecentLogs({int limit = 50}) {
    return _callLogs.skip((_callLogs.length - limit).clamp(0, _callLogs.length)).toList();
  }

  /// Get metrics history
  List<MetricSnapshot> getMetricsHistory({int limit = 100}) {
    return _metricsHistory.skip((_metricsHistory.length - limit).clamp(0, _metricsHistory.length)).toList();
  }

  /// Generate detailed report
  String generateReport() {
    final stats = getStatistics();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    
    return '''
╔════════════════════════════════════════════════════════════╗
║              CALL QUALITY & CONNECTIVITY REPORT             ║
╚════════════════════════════════════════════════════════════╝

📊 STATISTICS
─────────────────────────────────────────────────────────────
Total Calls Initiated:        ${stats.totalCalls}
Completed Calls:              ${stats.completedCalls}
Call Completion Rate:         ${(stats.totalCalls > 0 ? (stats.completedCalls / stats.totalCalls * 100).toStringAsFixed(1) : 'N/A')}%

📱 REAL-TIME CONNECTIVITY
─────────────────────────────────────────────────────────────
Token Fetch Attempts:         ${stats.totalTokenFetches}
Successful Token Fetches:     ${stats.successfulTokenFetches}
Token Success Rate:           ${(stats.totalTokenFetches > 0 ? (stats.successfulTokenFetches / stats.totalTokenFetches * 100).toStringAsFixed(1) : 'N/A')}%

⏱️ PERFORMANCE METRICS
─────────────────────────────────────────────────────────────
Avg Socket Latency:           ${stats.avgSocketLatencyMs.toStringAsFixed(2)} ms
Avg Call Connect Time:        ${stats.avgCallConnectTimeMs.toStringAsFixed(2)} ms
Total Uptime Tracked:         ${_formatDuration(stats.uptime)}

📈 LOG ENTRIES
─────────────────────────────────────────────────────────────
Total Entries:                ${stats.logEntryCount}
Recent Entries (Last 5):
${_formatRecentLogs()}

╚════════════════════════════════════════════════════════════╝
Generated: ${formatter.format(DateTime.now())}
    ''';
  }

  String _formatDuration(int ms) {
    final seconds = ms ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    
    if (hours > 0) {
      return '$hours h ${minutes % 60} m ${seconds % 60} s';
    } else if (minutes > 0) {
      return '$minutes m ${seconds % 60} s';
    } else {
      return '$seconds s';
    }
  }

  String _formatRecentLogs() {
    return getRecentLogs(limit: 5)
        .map((log) {
          final formatter = DateFormat('HH:mm:ss');
          final time = formatter.format(log.timestamp);
          return '  [$time] ${log.type}: ${log.details?['message'] ?? 'N/A'}';
        })
        .join('\n');
  }

  void _addLogEntry(CallLogEntry entry) {
    _callLogs.add(entry);
    
    // Keep size bounded
    if (_callLogs.length > maxLogEntries) {
      _callLogs.removeAt(0);
    }
  }

  /// Clear all logs (for testing)
  void clearLogs() {
    _callLogs.clear();
    _metricsHistory.clear();
    log('[CallQualityLogger] Logs cleared');
  }

  /// Export logs as JSON-friendly format
  List<Map<String, dynamic>> exportLogs() {
    return _callLogs.map((log) => {
      'type': log.type,
      'timestamp': log.timestamp.toIso8601String(),
      'details': log.details,
    }).toList();
  }
}

class CallLogEntry {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  CallLogEntry({
    required this.type,
    required this.timestamp,
    this.details,
  });

  factory CallLogEntry.start({
    required String callId,
    required String userId,
    required String remoteUserId,
    String? callType,
    required DateTime timestamp,
  }) {
    return CallLogEntry(
      type: 'call_start',
      timestamp: timestamp,
      details: {
        'callId': callId,
        'userId': userId,
        'remoteUserId': remoteUserId,
        'callType': callType ?? 'video',
        'message': 'Call started: $callId',
      },
    );
  }

  factory CallLogEntry.end({
    required String callId,
    required int durationSeconds,
    String? endReason,
    required DateTime timestamp,
  }) {
    return CallLogEntry(
      type: 'call_end',
      timestamp: timestamp,
      details: {
        'callId': callId,
        'durationSeconds': durationSeconds,
        'endReason': endReason,
        'message': 'Call ended: $callId (${durationSeconds}s)',
      },
    );
  }

  factory CallLogEntry.tokenFetch({
    required bool success,
    required String userId,
    required int latencyMs,
    int retryCount = 0,
    required DateTime timestamp,
  }) {
    return CallLogEntry(
      type: 'token_fetch',
      timestamp: timestamp,
      details: {
        'success': success,
        'userId': userId,
        'latencyMs': latencyMs,
        'retryCount': retryCount,
        'message': 'Token fetch success: ${latencyMs}ms (retry $retryCount)',
      },
    );
  }

  factory CallLogEntry.tokenFetchFailure({
    required String userId,
    required String reason,
    int totalRetries = 0,
    required DateTime timestamp,
  }) {
    return CallLogEntry(
      type: 'token_fetch_failure',
      timestamp: timestamp,
      details: {
        'success': false,
        'userId': userId,
        'reason': reason,
        'totalRetries': totalRetries,
        'message': 'Token fetch failed: $reason (retried $totalRetries times)',
      },
    );
  }

  factory CallLogEntry.socketEvent({
    required String event,
    required int latencyMs,
    String? details,
    required DateTime timestamp,
  }) {
    return CallLogEntry(
      type: 'socket_event',
      timestamp: timestamp,
      details: {
        'event': event,
        'latencyMs': latencyMs,
        'details': details,
        'message': 'Socket $event: ${latencyMs}ms',
      },
    );
  }
}

class MetricSnapshot {
  final DateTime timestamp;
  final double socketLatencyMs;
  final double callConnectTimeMs;
  final bool socketConnected;
  final int activeCallCount;
  final int queuedEvents;

  MetricSnapshot({
    required this.timestamp,
    required this.socketLatencyMs,
    required this.callConnectTimeMs,
    required this.socketConnected,
    required this.activeCallCount,
    required this.queuedEvents,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'socketLatencyMs': socketLatencyMs,
    'callConnectTimeMs': callConnectTimeMs,
    'socketConnected': socketConnected,
    'activeCallCount': activeCallCount,
    'queuedEvents': queuedEvents,
  };
}

class CallStatistics {
  final int totalCalls;
  final int completedCalls;
  final int totalTokenFetches;
  final int successfulTokenFetches;
  final int uptime;
  final double avgSocketLatencyMs;
  final double avgCallConnectTimeMs;
  final int logEntryCount;

  CallStatistics({
    required this.totalCalls,
    required this.completedCalls,
    required this.totalTokenFetches,
    required this.successfulTokenFetches,
    required this.uptime,
    required this.avgSocketLatencyMs,
    required this.avgCallConnectTimeMs,
    required this.logEntryCount,
  });

  factory CallStatistics.empty() {
    return CallStatistics(
      totalCalls: 0,
      completedCalls: 0,
      totalTokenFetches: 0,
      successfulTokenFetches: 0,
      uptime: 0,
      avgSocketLatencyMs: 0,
      avgCallConnectTimeMs: 0,
      logEntryCount: 0,
    );
  }
}

import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';

/// Call log filtering service
/// Provides pure utility functions for filtering call logs by type and search query
class CallLogFilteringService {
  /// Filters call logs by type and search query
  /// 
  /// [logs] - List of call logs to filter
  /// [filterType] - Filter by call type: 'all', 'audio', or 'video'
  /// [searchQuery] - Filter by caller/callee name (case-insensitive substring match)
  /// 
  /// Returns filtered list matching both criteria (AND logic)
 
  static List<CallLogEntity> applyFilters(
    List<CallLogEntity> logs,
    String filterType,
    String searchQuery,
  ) {
    return logs.where((log) {
      // Filter by call type
      final matchesType = filterType == 'all' || log.callType == filterType;

      // Filter by search query
      final matchesSearch = searchQuery.isEmpty ||
          log.callerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          log.calleeName.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesType && matchesSearch;
    }).toList();
  }

  /// Filters call logs by type only
  static List<CallLogEntity> filterByType(
    List<CallLogEntity> logs,
    String filterType,
  ) {
    if (filterType == 'all') return logs;
    return logs.where((log) => log.callType == filterType).toList();
  }

  /// Filters call logs by search query only
  static List<CallLogEntity> filterBySearch(
    List<CallLogEntity> logs,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return logs;
    return logs
        .where((log) =>
            log.callerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            log.calleeName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }
}

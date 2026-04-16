/// Format service for call log entities
/// Provides pure utility functions for formatting durations and timestamps
class FormatService {
  /// Formats duration in seconds to a readable string (e.g., "2h 5m 30s")
  static String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Formats DateTime to a human-readable string
  /// Examples: "Today 14:32", "Yesterday 09:15", "3 days ago", "12/04/2026"
  static String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return 'Today ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

/*
class StreamConfig {
  /// Stream.io Chat API Key
  /// Get this from your Stream.io Dashboard (https://dashboard.getstream.io)
  static const String chatApiKey = 'YOUR_STREAM_API_KEY';

  /// Stream.io Video API Key (usually same as chat API key)
  static const String videoApiKey = 'YOUR_STREAM_API_KEY';

  /// Your Stream.io App ID
  static const String appId = 'YOUR_STREAM_APP_ID';

  /// Backend URL to generate Stream auth tokens (JWT)
  /// This should match your Node.js backend endpoint
  static const String tokenServerUrl = 'http://192.168.0.105:3000/stream/token';

  /// Stream chat base URL
  static const String chatBaseUrl = 'https://chat-proxy.getstream.io';

  /// Stream video base URL
  static const String videoBaseUrl = 'https://video-proxy.getstream.io';

  /// Channel name prefix for 1-1 chats
  static const String directChatPrefix = 'direct';

  /// Channel separator (e.g., direct_{userId1}_{userId2})
  static const String channelSeparator = '_';

  /// Environment: 'dev', 'staging', 'production'
  static const String environment = 'dev';

  /// Debug logging enabled
  static const bool debugLogging = true;

  /// Request timeout in seconds
  static const int requestTimeoutSeconds = 30;

  /// Max retries for network requests
  static const int maxRetries = 3;
}
*/
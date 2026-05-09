import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class VideoService {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(milliseconds: 500);
  static const String tokenEndpoint = 'http://192.168.0.105:3000/get-stream-token';
  static const int tokenFetchTimeout = 10;

  static Future<String?> getStreamToken(String userId) async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        final String url = '$tokenEndpoint?userId=$userId';
        
        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $userId'
              },
            )
            .timeout(
              const Duration(seconds: tokenFetchTimeout),
              onTimeout: () => throw TimeoutException(
                'Token fetch timed out after $tokenFetchTimeout seconds',
              ),
            );

        if (response.statusCode == 200) {
          log('[VideoService] Token fetched successfully for userId: $userId');
          return jsonDecode(response.body)['token'];
        }

        log('[VideoService] Token fetch failed with status ${response.statusCode}');
        retryCount++;
        
        if (retryCount < maxRetries) {
          final delay = baseDelay * (1 << (retryCount - 1));
          log('[VideoService] Retrying token fetch (attempt $retryCount/$maxRetries) after ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
        }
      } on TimeoutException catch (e) {
        log('[VideoService] Token fetch timeout: $e');
        retryCount++;
        
        if (retryCount < maxRetries) {
          final delay = baseDelay * (1 << (retryCount - 1));
          log('[VideoService] Retrying after timeout (attempt $retryCount/$maxRetries) after ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
        }
      } catch (e) {
        log('[VideoService] Unexpected error fetching token: $e');
        retryCount++;
        
        if (retryCount < maxRetries) {
          final delay = baseDelay * (1 << (retryCount - 1));
          await Future.delayed(delay);
        }
      }
    }

    log('[VideoService] Failed to fetch token after $maxRetries attempts for userId: $userId');
    return null;
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

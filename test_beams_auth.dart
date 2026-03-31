import 'package:carbo/base/api/endpoint/api_endpoint.dart';
import 'package:carbo/base/utils/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

final _logger = Logger();

/// Test script to verify Pusher Beams auth endpoint
/// 
/// Add this method to your push_notification_service.dart for testing
Future<void> testAuthEndpoint() async {
  final token = LocalStorage.token;
  final authUrl = '${ApiConfig.baseUrl}/user/pusher/beams-auth';
  
  _logger.i('═══════════════════════════════════════════════════');
  _logger.i('🧪 TESTING PUSHER BEAMS AUTH ENDPOINT');
  _logger.i('═══════════════════════════════════════════════════');
  _logger.i('URL: $authUrl');
  _logger.i('Token: ${token.substring(0, 30)}...');
  
  try {
    final response = await http.get(
      Uri.parse(authUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    
    _logger.i('Status Code: ${response.statusCode}');
    _logger.i('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('token')) {
        _logger.i('✅ SUCCESS: Backend auth endpoint works correctly');
        _logger.i('Token received (first 50 chars): ${data['token'].toString().substring(0, 50)}...');
      } else {
        _logger.e('❌ ERROR: Response is 200 but no token field');
        _logger.e('Response: $data');
      }
    } else {
      _logger.e('❌ ERROR: HTTP ${response.statusCode}');
      _logger.e('Response: ${response.body}');
    }
    
    _logger.i('═══════════════════════════════════════════════════');
  } catch (e, stackTrace) {
    _logger.e('❌ Exception testing auth endpoint: $e');
    _logger.e('Stack trace: $stackTrace');
  }
}

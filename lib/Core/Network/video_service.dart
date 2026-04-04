import 'dart:convert';

import 'package:http/http.dart' as http;

class VideoService{
    static const String url = 'http://192.168.0.106:3000/video/token';
static Future<String?> getStreamToken(String jwt)async{

  final response = await http.get(Uri.parse(url),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $jwt'
  }
  
  
    );
    if(response.statusCode=='200'){
    return jsonDecode(response.body)['token'];
    }
    return null ;
  }
}
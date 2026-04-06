import 'dart:convert';

import 'package:chat_app/Features/video%20service/managers/stream_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class VideoService{

static Future<String?> getStreamToken(String userId)async{
  final String url = 'http://192.168.0.106:3000/token?userId=$userId}'; 
  final response = await http.get(Uri.parse(url),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer$userId'
  }
  
  
    );
    if(response.statusCode==200){
    return jsonDecode(response.body)['token'];
    }
   //await StreamManager.init(currentUser!.uid, currentUser!.displayName!, jwt);  
    return null ;
  }
}

import 'dart:convert';
import 'dart:developer' as consle;

import 'package:chat_app/Core/constants/secrets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class GeminiRemoteDataSource{
final String serverUrl=AppSecrets.serverUrl;

Future<String> getResponse(String prompt)async{
try{
final response=await http.post(
  Uri.parse(serverUrl),
  headers: {'Content-Type':'application/json'},
  body: jsonEncode({'prompt':prompt})
);
if(response.statusCode==200){
  final data=jsonDecode(response.body);
  return data['text']??'No response from AI';
}else{
  consle.log('Error response from Gemini API: ${response.statusCode} - ${response.body}');
  throw Exception('Failed to fetch response from Gemini API');
}
}
catch(e){
  consle.log('Error fetching response from Gemini API: $e');
  throw Exception('Failed to fetch response from Gemini API');
}
}
}
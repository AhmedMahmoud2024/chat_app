import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/Features/recents%20Screen/data/model/call_log_model.dart';
import 'package:http/http.dart' as http;

abstract class RemoteRecentsDataSource {
 Future<List<CallLogModel>> getCallLogsFromApi({int page ,int limit ,required String userId});
 Future<bool> deleteCallLog(String callId);
}

class RemoteRecentsDataSourceImpl implements RemoteRecentsDataSource{
  final http.Client client ;
  RemoteRecentsDataSourceImpl({
    required this.client
  });

  @override
  Future<List<CallLogModel>> getCallLogsFromApi({int page = 1, int limit = 20,
  required String userId
  })async {
    log('calling api with userId :$userId');
    try{
    final uri = "http://192.168.0.106:3000/api/calls/history/${userId}?page=$page&limit=$limit";
  final response = await client.get(Uri.parse(uri),headers: {
    'Content-type':'application/json'
  });
  log('response reached: ${response.body}');
  if(response.statusCode==200){
    final  decodedData=json.decode(response.body);
   final List<dynamic> logsJson= decodedData['data'] ?? decodedData ;
    return logsJson.map((item)=>CallLogModel.fromJson(item)).toList();

  }else{
    throw Exception('Server Error');
  }
    }catch(e){
      log('error is here :$e');
      rethrow;
    }
  
  }

  @override
  Future<bool> deleteCallLog(String callId) async {
    final uri = 'http://192.168.0.106:3000/api/calls/$callId';
    final response = await client.delete(
      Uri.parse(uri),
      headers: {'Content-type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete call log');
    }
  }
  
}
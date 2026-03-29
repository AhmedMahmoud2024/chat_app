import 'dart:convert';

import 'package:chat_app/Core/Network/socket_service.dart';
import 'package:chat_app/Features/recents%20Screen/data/model/call_log_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
List <CallLogModel> logs=[];
Future<List<CallLogModel>> fetchLogs()async{
final response = await http.get(Uri.parse('http://192.168.0.105:3000/call-history/userId'));
if(response.statusCode==200){
  List data = json.decode(response.body);
  return data.map((log)=>
    CallLogModel.fromJson(log)
  ).toList();
}
return [];
}  
@override
  void initState() {
    super.initState();
    fetchLogs();
   SocketService.socket.on('new-log-added', (data){
if(mounted){
      setState(() {
        logs.insert(0, CallLogModel.fromJson(data));
      });
    }
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Calls'),
      ),
      body: FutureBuilder(future: fetchLogs(),
       builder: (context,snapshot){
        if(!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
         return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context,index){
          var log = snapshot.data![index];
          return ListTile(
   leading: Icon(log.status == 'missed' ? Icons.call_missed : Icons.call_received,
   color: log.status == 'missed' ? Colors.red : Colors.green,
   ),
   title: Text(log.callerName),
   subtitle: Text(log.time.toString()),
   trailing: Icon(Icons.phone ),
          );
          });
       }
       ),
    );
  }
}
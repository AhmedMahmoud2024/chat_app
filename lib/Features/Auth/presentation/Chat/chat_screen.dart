
import 'package:chat_app/Core/Network/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
   ChatScreen({required this.receiverName, required this.receiverId});
  final String receiverName, receiverId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
    TextEditingController _messageController = TextEditingController();

    final  _scrollController = ScrollController();

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;


   @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }


  String _getChatId(){
    final ids =[widget.receiverId,currentUserId];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _sendMessage()async{
    if(_messageController.text.trim().isEmpty) return;
    final message= _messageController.text.trim();
    _messageController.clear();
    try{
  final chatId= _getChatId();
  await FirebaseFirestore.instance
  .collection('chats').doc(chatId)
  .collection('messages')
  .add({
  'text':message,
  'resceiverId':widget.receiverId,
  'senderId':currentUserId,
  'timestamp':FieldValue.serverTimestamp(),
  });
   
   if(_scrollController.hasClients){
     _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.bounceOut);
   }
    }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString()))
    );
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName)
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').doc(
                _getChatId()
              ).collection('messages').orderBy(
                'timestamp',descending: true
              ).snapshots(),
               builder: (context,snapshot){
                if(!snapshot.hasData ||snapshot.data!.docs.isEmpty){
                return Center(child: Text('No messages yet ...'),);
                } 
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder:(context,index){
                    final messageData=snapshot.data?.docs[index].data() as Map<String,dynamic>;
                     final isMe= messageData['senderId'] ==currentUserId ;
                     final timeStamp= messageData['timestamp'] as Timestamp ;
                     //need to install dateformat package
                    final timeString = timeStamp!=null ?DateFormat('HH:mm').format(timeStamp.toDate()) : '';
             return  Align(alignment: isMe? Alignment.centerRight :Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isMe?Colors.blue :Colors.grey[300]
                    ),
                    child: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.end, 
                      children: [
                     Text(messageData['text'],style: TextStyle(
                      color: isMe? Colors.white :Colors.black
                     ),), //meassage content
                     Text(timeString) //uncommet after install package   
                     
                      ],
                    ),
                  ),
                  );
                  } 
                  );
               }
               ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  spreadRadius: 1
                  
                )
              ]
            ),
            child: SafeArea(child: Row(
              children: [
                Expanded(child: TextField(
                  onSubmitted:(value) {
                    _sendMessage();
                 //   FirebaseAuthService().saveDeviceToken();
                //    print(FirebaseAuthService().saveDeviceToken().toString());
                  },
                controller: _messageController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hint: Text('Enter your message ....')
                ),
                )),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(onPressed: _sendMessage, icon: 
                  Icon(Icons.send,color: Colors.white,)),
                )
              ],
            )),
          )
        ],
      ),
    );
  }
}
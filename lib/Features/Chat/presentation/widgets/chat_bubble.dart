import 'package:chat_app/Features/Chat/domain/entities/message_entity.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final MessageEntity message;
  const ChatBubble({super.key,required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
  alignment:message.isMe ? Alignment.centerRight:
  Alignment.centerLeft
  ,
  child: Container(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.75
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 12,vertical: 10
    ),
    margin: const EdgeInsets.symmetric(
      horizontal: 16,vertical: 4
    ),
    decoration: BoxDecoration(
      color: message.isMe ? Colors.blueAccent :
      Colors.grey[300],
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft:  Radius.circular(message.isMe? 16:0),
         bottomRight:  Radius.circular(message.isMe? 16:0),
      )
    ),
    child: Column(
   //   crossAxisAlignment: message.isMe ?CrossAxisAlignment.end:
     crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message.text,style: TextStyle(
          
          color: message.isMe ? Colors.white70:
          Colors.black87,
          fontSize: 20
        ),
        ),
        const SizedBox(height: 4,),
        Text("${message.dateTime.hour} : ${message.dateTime.minute}",
        style: TextStyle(
          color: message.isMe ?Colors.white70 :
          const Color.fromRGBO(0, 0, 0, 0.541),
          fontSize: 10
        ),
        )
      ],
    ),
  ),
    );
  }
}
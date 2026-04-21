import 'package:chat_app/Features/Chat/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
 const MessageModel({
  required super.messageId,
  required super.text,
  required super.senderId,
  required super.recevierId,
  required super.dateTime,
   required super.isMe
   });
 
 factory MessageModel.fromJson(
  Map<String,dynamic> json,String currentUserId
 ){
  return MessageModel(
    messageId: json['_id']?.toString() ?? '',
     text: json['text']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
       recevierId:json['receiverId']?.toString() ?? '',
        dateTime: json['createdAt'] !=null ? DateTime.parse(json['createdAt'].toString()) :DateTime.now(),
         isMe: json['senderId'] ==currentUserId
         );
 }

  factory MessageModel.fromEntity(MessageEntity entity){
 return MessageModel(
  messageId: entity.messageId,
   text: entity.text,
    senderId: entity.senderId,
     recevierId: entity.recevierId,
      dateTime: entity.dateTime,
       isMe: entity.isMe
       );
    }

       MessageEntity toEntity(){
 return MessageEntity(
  messageId: messageId,
   text: text,
    senderId: senderId,
     recevierId: recevierId,
      dateTime: dateTime,
       isMe: isMe
       );
    }
 Map<String,dynamic> toJson(){
 return {
  'messageId':messageId,
  'senderId':senderId,
  'receiverId':recevierId,
  'text':text,
  'createdAt':dateTime.toIso8601String()
 };
 }


}
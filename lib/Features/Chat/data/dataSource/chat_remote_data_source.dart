import 'package:chat_app/Features/Chat/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ChatRemoteDataSource {
 Stream<List<MessageModel>> getMessages(String receiverId);
Future<void> sendMessage(MessageModel message);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource{
   final   currentUser = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore firestore= FirebaseFirestore.instance;
   ChatRemoteDataSourceImpl({
required this.firestore
   });

  @override

  Stream<List<MessageModel>> getMessages(String chatRoomId) {
  return firestore.collection('chats').doc(_getChatId(chatRoomId)).collection('messages').orderBy('createdAt',descending: true)
  .snapshots().map((snapshot)=>snapshot.docs.map((doc)=>MessageModel.fromJson(
    doc.data(),
     currentUser
    )
    ).toList()
    );
  
  }
  
  @override
  Future<void> sendMessage(MessageModel messageModel) async{
   final chatId = _getChatId(messageModel.recevierId);
  await  firestore.
  collection('chats').
  doc(chatId).
  collection('messages').
  add(messageModel.toJson());
  }
  
String _getChatId(String receiverId){
   final ids =[receiverId,currentUser];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
   }
}
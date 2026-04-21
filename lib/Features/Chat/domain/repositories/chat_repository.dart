import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/Chat/domain/entities/message_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
 Stream<Either<Failure,List<MessageEntity>>>  getMessages(String chatRoomId);
 Future<Either<Failure,Unit>> sendMessage(MessageEntity message);

}
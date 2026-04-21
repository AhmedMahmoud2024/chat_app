import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/Chat/domain/entities/message_entity.dart';
import 'package:chat_app/Features/Chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetMessagesUseCase {
  final ChatRepository repository;
  
  GetMessagesUseCase(this.repository);

 Stream<Either<Failure,List<MessageEntity>>> call (String chatRoomId){
 return repository.getMessages(chatRoomId);
  }
}
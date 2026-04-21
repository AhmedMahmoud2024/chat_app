import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/Chat/domain/entities/message_entity.dart';
import 'package:chat_app/Features/Chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure,Unit>> call(MessageEntity message)async{
  return await repository.sendMessage(message);
  }
}
import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/Chat/data/dataSource/chat_remote_data_source.dart';
import 'package:chat_app/Features/Chat/data/models/message_model.dart';
import 'package:chat_app/Features/Chat/domain/entities/message_entity.dart';
import 'package:chat_app/Features/Chat/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class ChatRepositoryImpl  implements ChatRepository{

final ChatRemoteDataSource remoteDataSource;

ChatRepositoryImpl({
  required this.remoteDataSource
});
  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String chatRoomId) {
   return remoteDataSource.getMessages(chatRoomId).map((models)=>Right<Failure,List<MessageEntity>>(
    models.map((model)=>
    model.toEntity()
    ).toList(),
   ),
   ).handleError((error){
    return Left(ServerFailure());
   }
   );
  }

  @override
  Future<Either<Failure, Unit>> sendMessage(MessageEntity message) async{
    try{
   final model = MessageModel.fromEntity(message);
   await remoteDataSource.sendMessage(model);
   return const Right(unit);
    }catch(e){
      return Left(ServerFailure());
    }
  }

}
import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';
import 'package:chat_app/Features/recents%20Screen/repositories/recents_repository.dart';
import 'package:dartz/dartz.dart';

class GetCallLogsUseCase {
  final RecentsRepository repository;
    
  GetCallLogsUseCase( this.repository,);
 Future<Either<Failure,List<CallLogEntity>>> call(String userId)async{
 return await repository.getCallLogs(userId) ;
  }
}
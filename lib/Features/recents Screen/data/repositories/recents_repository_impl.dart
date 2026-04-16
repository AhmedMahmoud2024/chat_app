import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/recents%20Screen/data/dataSources/remote_recents_data_source.dart';
import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';
import 'package:chat_app/Features/recents%20Screen/repositories/recents_repository.dart';
import 'package:dartz/dartz.dart';

class RecentsRepositoryImpl  implements RecentsRepository{
 final RemoteRecentsDataSource remoteRecentsDataSource;

  RecentsRepositoryImpl({required this.remoteRecentsDataSource});
 
  @override
  Future<Either<Failure, List<CallLogEntity>>> getCallLogs(String userId)async {
  try{
  final  remoteLogs = await remoteRecentsDataSource.getCallLogsFromApi(userId: userId);
  final entities = remoteLogs.map((model)=>
   model.toEntity()
  ).toList();
  return Right(entities);
  }catch(e){
  return Left(ServerFailure());
  }
  }

  @override
  Future<Either<Failure, bool>> deleteCallLog(String callId) async {
    try {
      final success = await remoteRecentsDataSource.deleteCallLog(callId);
      return Right(success);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

}
import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';
import 'package:dartz/dartz.dart';

abstract class RecentsRepository {
 Future<Either<Failure,List<CallLogEntity>>> getCallLogs(String userId);
 Future<Either<Failure, bool>> deleteCallLog(String callId);
}
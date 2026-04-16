import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/recents%20Screen/repositories/recents_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for deleting a call log
/// Removes a call log by ID through the repository
class DeleteCallLogUseCase {
  final RecentsRepository repository;

  DeleteCallLogUseCase(this.repository);

  /// Deletes a call log by ID
  /// 
  /// [callId] - The ID of the call log to delete
  /// 
  /// Returns Either<Failure, bool> where bool indicates success
  Future<Either<Failure, bool>> call(String callId) async {
    return await repository.deleteCallLog(callId);
  }
}

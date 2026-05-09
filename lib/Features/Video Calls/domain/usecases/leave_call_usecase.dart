import 'package:dartz/dartz.dart';
import 'package:chat_app/Core/Utils/failures.dart';
import 'package:chat_app/Core/Utils/usecase_base.dart';
import 'package:chat_app/Features/Video%20Calls/domain/repository/video_call_repository.dart';

class LeaveCallUsecase
    extends UseCase<void, NoParams> {
  final VideoCallRepository repository;

  LeaveCallUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await repository.leaveCall();
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(message: e.toString()));
    }
  }
}

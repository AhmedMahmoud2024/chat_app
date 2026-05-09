import 'package:dartz/dartz.dart';
import 'package:chat_app/Core/Utils/failures.dart';
import 'package:chat_app/Core/Utils/usecase_base.dart';
import 'package:chat_app/Features/Video%20Calls/domain/repository/video_call_repository.dart';

class ToggleMicUsecase
    extends UseCase<void, ToggleMicParams> {
  final VideoCallRepository repository;

  ToggleMicUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ToggleMicParams params) async {
    try {
      await repository.toggleMic(params.isEnabled);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(message: e.toString()));
    }
  }
}

class ToggleMicParams {
  final bool isEnabled;

  ToggleMicParams({required this.isEnabled});
}

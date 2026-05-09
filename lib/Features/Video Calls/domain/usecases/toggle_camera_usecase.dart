import 'package:dartz/dartz.dart';
import 'package:chat_app/Core/Utils/failures.dart';
import 'package:chat_app/Core/Utils/usecase_base.dart';
import 'package:chat_app/Features/Video%20Calls/domain/repository/video_call_repository.dart';

class ToggleCameraUsecase
    extends UseCase<void, ToggleCameraParams> {
  final VideoCallRepository repository;

  ToggleCameraUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(ToggleCameraParams params) async {
    try {
      await repository.toggleCamera(params.isEnabled);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(message: e.toString()));
    }
  }
}

class ToggleCameraParams {
  final bool isEnabled;

  ToggleCameraParams({required this.isEnabled});
}

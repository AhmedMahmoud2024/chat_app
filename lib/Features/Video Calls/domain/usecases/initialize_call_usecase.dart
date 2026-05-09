import 'package:dartz/dartz.dart';
import 'package:chat_app/Core/Utils/failures.dart';
import 'package:chat_app/Core/Utils/usecase_base.dart';
import 'package:chat_app/Features/Video%20Calls/domain/entities/call_entity.dart';
import 'package:chat_app/Features/Video%20Calls/domain/repository/video_call_repository.dart';

class InitializeCallUsecase
    extends UseCase<void, InitializeCallParams> {
  final VideoCallRepository repository;

  InitializeCallUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(InitializeCallParams params) async {
    try {
      await repository.initializeCall(params.userId, params.userName, params.token);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(message: e.toString()));
    }
  }
}

class InitializeCallParams {
  final String userId;
  final String userName;
  final String token;

  InitializeCallParams({
    required this.userId,
    required this.userName,
    required this.token,
  });
}

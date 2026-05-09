import 'package:dartz/dartz.dart';
import 'package:chat_app/Core/Utils/failures.dart';
import 'package:chat_app/Core/Utils/usecase_base.dart';
import 'package:chat_app/Features/Video%20Calls/domain/repository/video_call_repository.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' hide Failure;

class CreateAndJoinCallUsecase
    extends UseCase<Call, CreateAndJoinCallParams> {
  final VideoCallRepository repository;

  CreateAndJoinCallUsecase({required this.repository});

  @override
  Future<Either<Failure, Call>> call(CreateAndJoinCallParams params) async {
    try {
      final call = await repository.createAndJoinCall(
        params.callId,
        params.memberIds,
      );
      return Right(call);
    } catch (e) {
      return Left(FirebaseFailure(message: e.toString()));
    }
  }
}

class CreateAndJoinCallParams {
  final String callId;
  final List<String> memberIds;

  CreateAndJoinCallParams({
    required this.callId,
    required this.memberIds,
  });
}

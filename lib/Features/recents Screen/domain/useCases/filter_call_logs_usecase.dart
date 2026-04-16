import 'package:chat_app/Core/error/failures.dart';
import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';
import 'package:chat_app/Features/recents%20Screen/domain/services/call_log_filtering_service.dart';
import 'package:dartz/dartz.dart';

/// Use case for filtering call logs
/// Filters a list of call logs by type and search query
class FilterCallLogsUseCase {
  /// Filters call logs by type ('all', 'audio', 'video') and search query
  /// 
  /// [logs] - List of call logs to filter
  /// [filterType] - Call type filter: 'all', 'audio', or 'video'
  /// [searchQuery] - Search term for caller/callee name
  /// 
  /// Returns Either<Failure, List<CallLogEntity>> with filtered results
  Future<Either<Failure, List<CallLogEntity>>> call(
    List<CallLogEntity> logs,
    String filterType,
    String searchQuery,
  ) async {
    try {
      final filtered = CallLogFilteringService.applyFilters(
        logs,
        filterType,
        searchQuery,
      );
      return Right(filtered);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

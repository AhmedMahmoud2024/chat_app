import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';
import 'package:chat_app/Features/recents%20Screen/domain/services/format_service.dart';
import 'package:chat_app/Features/recents%20Screen/domain/useCases/delete_call_log_usecase.dart';
import 'package:chat_app/Features/recents%20Screen/domain/useCases/filter_call_logs_usecase.dart';
import 'package:chat_app/Features/recents%20Screen/domain/useCases/get_call_logs_usecase.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/bloc/recents_event.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/bloc/recents_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentsBloc extends Bloc<RecentsEvent, RecentsState> {
  final GetCallLogsUseCase getCallLogsUsecase;
  final FilterCallLogsUseCase filterCallLogsUseCase;
  final DeleteCallLogUseCase deleteCallLogUseCase;
  final FormatService formatService = FormatService();

  /// Cache for fetched logs to enable client-side filtering
  List<CallLogEntity> _cachedLogs = [];

  RecentsBloc({
    required this.getCallLogsUsecase,
    required this.filterCallLogsUseCase,
    required this.deleteCallLogUseCase,
  }) : super(const RecentsInitial()) {
    on<FetchCallLogsEvent>(_onFetchCallLogs);
    on<FilterCallLogsEvent>(_onFilterCallLogs);
    on<DeleteCallLogEvent>(_onDeleteCallLog);
  }

  Future<void> _onFetchCallLogs(
    FetchCallLogsEvent event,
    Emitter<RecentsState> emit,
  ) async {
    emit(const RecentsLoading());
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final result = await getCallLogsUsecase.call(userId);
    result.fold(
      (failure) => emit(const RecentsError('Failed to fetch call history')),
      (logs) {
        _cachedLogs = logs;
        emit(RecentsLoaded(logs));
      },
    );
  }

  Future<void> _onFilterCallLogs(
    FilterCallLogsEvent event,
    Emitter<RecentsState> emit,
  ) async {
    emit(RecentsFiltering(_cachedLogs));
    final result = await filterCallLogsUseCase.call(
      _cachedLogs,
      event.filterType,
      event.searchQuery,
    );
    result.fold(
      (failure) => emit(const RecentsError('Failed to filter call logs')),
      (filteredLogs) => emit(RecentsLoaded(filteredLogs)),
    );
  }

  Future<void> _onDeleteCallLog(
    DeleteCallLogEvent event,
    Emitter<RecentsState> emit,
  ) async {
    emit(RecentsDeleting(_cachedLogs));
    final result = await deleteCallLogUseCase.call(event.callId);
    result.fold(
      (failure) => emit(RecentsError('Failed to delete call log')),
      (_) {
        /// Remove from cache and update state
        _cachedLogs.removeWhere((log) => log.callId == event.callId);
        emit(RecentsDeleteSuccess(
          _cachedLogs,
          message: 'Call log deleted successfully',
        ));
        /// Emit final state with updated logs
        emit(RecentsLoaded(_cachedLogs));
      },
    );
  }
}


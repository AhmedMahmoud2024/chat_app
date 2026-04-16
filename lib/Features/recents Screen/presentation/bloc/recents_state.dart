import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';
import 'package:equatable/equatable.dart';

abstract class RecentsState extends Equatable {
  const RecentsState();
  @override
  List<Object?> get props => [];
}

class RecentsInitial extends RecentsState {
  const RecentsInitial();
}

class RecentsLoading extends RecentsState {
  const RecentsLoading();
}

class RecentsLoaded extends RecentsState {
  final List<CallLogEntity> logs;
  const RecentsLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}

class RecentsFiltering extends RecentsState {
  final List<CallLogEntity> logs;
  const RecentsFiltering(this.logs);
  @override
  List<Object?> get props => [logs];
}

class RecentsDeleting extends RecentsState {
  final List<CallLogEntity> logs;
  const RecentsDeleting(this.logs);
  @override
  List<Object?> get props => [logs];
}

class RecentsDeleteSuccess extends RecentsState {
  final List<CallLogEntity> logs;
  final String message;
  const RecentsDeleteSuccess(this.logs, {this.message = 'Call log deleted'});
  @override
  List<Object?> get props => [logs, message];
}

class RecentsError extends RecentsState {
  final String message;
  const RecentsError(this.message);
  @override
  List<Object?> get props => [message];
}


import 'package:equatable/equatable.dart';

abstract class RecentsEvent extends Equatable {
const RecentsEvent();
@override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchCallLogsEvent extends RecentsEvent {
  const FetchCallLogsEvent();
}

class FilterCallLogsEvent extends RecentsEvent {
  final String filterType;
  final String searchQuery;

  const FilterCallLogsEvent({
    required this.filterType,
    required this.searchQuery,
  });

  @override
  List<Object?> get props => [filterType, searchQuery];
}

class DeleteCallLogEvent extends RecentsEvent {
  final String callId;

  const DeleteCallLogEvent({required this.callId});

  @override
  List<Object?> get props => [callId];
}
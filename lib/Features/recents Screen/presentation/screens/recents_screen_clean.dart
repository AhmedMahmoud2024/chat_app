import 'package:chat_app/Core/service_locator.dart';
import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/bloc/recents_bloc.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/bloc/recents_event.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/bloc/recents_state.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/widgets/call_log_item_widget.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/widgets/filter_controls_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentsScreenClean extends StatefulWidget {
  const RecentsScreenClean({super.key});

  @override
  State<RecentsScreenClean> createState() => _RecentsScreenCleanState();
}

class _RecentsScreenCleanState extends State<RecentsScreenClean> {
  String selectedFilter = 'all';
  String searchQuery = '';


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecentsBloc>()..add(const FetchCallLogsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recent calls'),
          centerTitle: true,
        ),
        body: BlocListener<RecentsBloc, RecentsState>(
          listener: (context, state) {
            if (state is RecentsDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is RecentsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: BlocBuilder<RecentsBloc, RecentsState>(
            builder: (context, state) {
              if (state is RecentsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RecentsLoaded ||
                  state is RecentsFiltering ||
                  state is RecentsDeleting ||
                  state is RecentsDeleteSuccess) {
                final logs = _getLogsFromState(state);
                final isFiltering =
                    state is RecentsFiltering || state is RecentsDeleting;

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<RecentsBloc>()
                        .add(const FetchCallLogsEvent());
                  },
                  child: Column(
                    children: [
                      FilterControlsWidget(
                        selectedFilter: selectedFilter,
                        searchQuery: searchQuery,
                        onFilterChanged: (value) {
                          setState(() {
                            selectedFilter = value;
                          });
                          context.read<RecentsBloc>().add(
                                FilterCallLogsEvent(
                                  filterType: value,
                                  searchQuery: searchQuery,
                                ),
                              );
                        },
                        onSearchChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                          context.read<RecentsBloc>().add(
                                FilterCallLogsEvent(
                                  filterType: selectedFilter,
                                  searchQuery: value,
                                ),
                              );
                        },
                        onClearSearch: () {
                          setState(() {
                            searchQuery = '';
                          });
                          context.read<RecentsBloc>().add(
                                FilterCallLogsEvent(
                                  filterType: selectedFilter,
                                  searchQuery: '',
                                ),
                              );
                        },
                      ),
                      if (isFiltering)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue[400]!,
                            ),
                          ),
                        ),
                      Expanded(
                        child: logs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.call,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      searchQuery.isNotEmpty
                                          ? 'No calls found matching "$searchQuery"'
                                          : 'No ${selectedFilter == 'all' ? '' : selectedFilter} calls',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(8),
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  return CallLogItemWidget(
                                    log: logs[index],
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                              ),
                      ),
                    ],
                  ),
                );
              } else if (state is RecentsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => context
                            .read<RecentsBloc>()
                            .add(const FetchCallLogsEvent()),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  /// Helper function to extract logs from any state
  List<CallLogEntity> _getLogsFromState(RecentsState state) {
    if (state is RecentsLoaded) {
      return state.logs;
    } else if (state is RecentsFiltering) {
      return state.logs;
    } else if (state is RecentsDeleting) {
      return state.logs;
    } else if (state is RecentsDeleteSuccess) {
      return state.logs;
    }
    return [];
  }
}
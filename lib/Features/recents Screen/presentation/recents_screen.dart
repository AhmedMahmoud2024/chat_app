import 'dart:convert';

import 'package:chat_app/Core/Network/call_service.dart';
import 'package:chat_app/Core/Network/socket_service.dart';
import 'package:chat_app/Features/recents%20Screen/data/model/call_log_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class RecentsScreen extends StatefulWidget {
final String myUser;
   RecentsScreen({super.key, required this.myUser});
  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  List<CallLogModel> logs = [];
  List<CallLogModel> filteredLogs = [];
  String selectedFilter = 'all'; // 'all', 'audio', 'video'
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCallLogs();
    
   /* // Listen for real-time call log updates
    SocketService.socket.on('new-log-added', (data) {
      if (mounted) {
        setState(() {
          logs.insert(0, CallLogModel.fromJson(data));
          _applyFilters();
        });
      }
    });
 */
  }

  /// Load call logs from backend
  Future<void> _loadCallLogs() async {
    try {
      final fetchedLogs = await CallService().fetchLogs(widget.myUser);
      setState(() {
        logs = fetchedLogs;
        _applyFilters();
      });
    } catch (e) {
      print('Error loading call logs: $e');
    }
  }

  /// Apply filters and search to logs
  void _applyFilters() {
    filteredLogs = logs.where((log) {
      // Filter by call type
      bool matchesType = selectedFilter == 'all' || log.callType == selectedFilter;
      
      // Filter by search query
      bool matchesSearch = searchQuery.isEmpty ||
          log.callerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          log.calleeName.toLowerCase().contains(searchQuery.toLowerCase());
      
      return matchesType && matchesSearch;
    }).toList();
  }

  /// Delete a call log
  Future<void> _deleteCallLog(String callId) async {
    try {
      final success = await CallService().deleteCallLog(callId);
      if (success) {
        setState(() {
          logs.removeWhere((log) => log.callId == callId);
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Call log deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete call log')),
        );
      }
    } catch (e) {
      print('Error deleting call log: $e');
    }
  }

  /// Format duration in seconds to readable format (hh:mm:ss)
  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Format time to readable format
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays == 0) {
      return 'Today ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Calls'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search calls...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Audio', 'audio'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Video', 'video'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Call Logs List
          Expanded(
            child: FutureBuilder(
              future: CallService().fetchLogs(widget.myUser),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.call, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'No calls found matching "$searchQuery"'
                              : 'No ${selectedFilter == 'all' ? '' : selectedFilter} calls',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    
                    return Dismissible(
                      key: Key(log.callId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteCallLog(log.callId);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage: log.callerAvatar.isNotEmpty
                              ? NetworkImage(log.callerAvatar)
                              : null,
                          child: log.callerAvatar.isEmpty
                              ? Text(log.callerName.isNotEmpty
                                  ? log.callerName[0].toUpperCase()
                                  : '?')
                              : null,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                log.callerName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              log.callType == 'video'
                                  ? Icons.videocam
                                  : Icons.call,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              log.status == 'missed'
                                  ? Icons.call_missed
                                  : log.status == 'declined'
                                      ? Icons.call_end
                                      : Icons.call_received,
                              size: 14,
                              color: log.status == 'missed'
                                  ? Colors.red
                                  : log.status == 'declined'
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                log.status == 'missed'
                                    ? 'Missed call'
                                    : log.status == 'declined'
                                        ? 'Declined call'
                                        : _formatDuration(log.duration),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: log.status == 'missed'
                                      ? Colors.red
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          _formatTime(log.startTime),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          // TODO: Implement call details or return call action
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build a filter chip button
  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = value;
          _applyFilters();
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue[100],
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey[300]!,
      ),
    );
  }
}
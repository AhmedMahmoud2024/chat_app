import 'package:chat_app/Features/recents%20Screen/domain/entities/call_log_entity.dart';
import 'package:chat_app/Features/recents%20Screen/domain/services/format_service.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/bloc/recents_bloc.dart';
import 'package:chat_app/Features/recents%20Screen/presentation/bloc/recents_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallLogItemWidget extends StatelessWidget {
  final CallLogEntity log;
  const CallLogItemWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
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
        _deleteCallLog(context);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: log.status == 'missed'
              ? Colors.red[100]
              : Colors.green[100],
          child: Icon(
            log.status == 'missed'
                ? Icons.call_missed
                : Icons.call_received,
            color: log.status == 'missed' ? Colors.red : Colors.green,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.callerName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              log.callType == 'video' ? Icons.videocam : Icons.call,
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
                        : FormatService.formatDuration(log.duration),
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
          FormatService.formatTime(log.startTime),
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
  }

  void _deleteCallLog(BuildContext context) {
    context.read<RecentsBloc>().add(
          DeleteCallLogEvent(callId: log.callId),
        );
  }
}
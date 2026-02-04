import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of fetching call history (Android only).
class CallHistoryResult {
  final bool success;
  final String? errorMessage;
  final List<String> logLines;

  CallHistoryResult({
    required this.success,
    this.errorMessage,
    required this.logLines,
  });
}

/// Fetches device call history on Android only.
/// Handles READ_CALL_LOG permission and returns formatted log lines.
Future<CallHistoryResult> getCallHistory() async {
  if (!Platform.isAndroid) {
    return CallHistoryResult(
      success: false,
      errorMessage: 'Call history is only supported on Android.',
      logLines: [],
    );
  }

  try {
    // Request permission (READ_CALL_LOG is part of phone permission group on Android)
    final status = await Permission.phone.request();
    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        return CallHistoryResult(
          success: false,
          errorMessage:
              'Call log permission permanently denied. Open app settings to enable.',
          logLines: [],
        );
      }
      return CallHistoryResult(
        success: false,
        errorMessage: 'Call log permission denied.',
        logLines: [],
      );
    }

    final Iterable<CallLogEntry> entries = await CallLog.get();
    final List<String> lines = [];
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    for (final e in entries) {
      final type = _callTypeString(e.callType);
      final date =
          e.timestamp != null
              ? dateFormat.format(
                DateTime.fromMillisecondsSinceEpoch(e.timestamp!),
              )
              : '--';
      final duration = e.duration != null ? '${e.duration}s' : '--';
      final number = e.number ?? e.formattedNumber ?? '--';
      final name = e.name?.isNotEmpty == true ? e.name! : number;
      lines.add('$date | $type | $name | $duration');
    }

    return CallHistoryResult(success: true, logLines: lines);
  } catch (e, st) {
    return CallHistoryResult(
      success: false,
      errorMessage: e.toString(),
      logLines: ['Error: $e', st.toString()],
    );
  }
}

String _callTypeString(CallType? type) {
  if (type == null) return 'unknown';
  switch (type) {
    case CallType.incoming:
      return 'IN';
    case CallType.outgoing:
      return 'OUT';
    case CallType.missed:
      return 'MISSED';
    default:
      return type.name;
  }
}

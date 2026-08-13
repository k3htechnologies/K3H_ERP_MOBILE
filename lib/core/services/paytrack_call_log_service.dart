import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:call_state_listener/call_state_listener.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

class PayTrackCallLogEntry {
  final String phoneNumber;
  final int projectId;
  final int bookingId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final bool isSynced;

  PayTrackCallLogEntry({
    required this.phoneNumber,
    required this.projectId,
    required this.bookingId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'projectId': projectId,
      'bookingId': bookingId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'isSynced': isSynced,
    };
  }

  factory PayTrackCallLogEntry.fromJson(Map<String, dynamic> json) {
    return PayTrackCallLogEntry(
      phoneNumber: json['phoneNumber'] ?? '',
      projectId: json['projectId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: DateTime.parse(json['endedAt']),
      durationSeconds: json['durationSeconds'] ?? 0,
      isSynced: json['isSynced'] ?? false,
    );
  }

  PayTrackCallLogEntry copyWith({
    String? phoneNumber,
    int? projectId,
    int? bookingId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    bool? isSynced,
  }) {
    return PayTrackCallLogEntry(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      projectId: projectId ?? this.projectId,
      bookingId: bookingId ?? this.bookingId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

class PayTrackCallLogService {
  PayTrackCallLogService({bool enableCallStateListener = true}) {
    if (enableCallStateListener && Platform.isAndroid) {
      initialize();
    }
  }

  static const int _maxStoredLogs = 100;

  final ValueNotifier<int> logsUpdated = ValueNotifier(0);

  String? _pendingCallNumber;
  String? _currentCallNumber;

  int? _pendingProjectId;
  int? _pendingBookingId;

  int? _currentProjectId;
  int? _currentBookingId;

  DateTime? _callStartTime;

  StreamSubscription<String>? _subscription;
  void initialize() {
    if (!Platform.isAndroid) return;

    if (_subscription != null) return;

    try {
      _subscription = CallStateListener.callStateStream
          .handleError((error, stackTrace) {
            debugPrint('PayTrack CallStateListener error: $error');
          })
          .listen(_handleCallState);

      debugPrint('PayTrack CallStateListener initialized');
    } catch (e, st) {
      debugPrint('Failed to initialize PayTrack call listener: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  void startCallTracking({
    required String phoneNumber,
    required int projectId,
    required int bookingId,
  }) {
    if (!Platform.isAndroid) return;

    _pendingCallNumber = phoneNumber;
    _pendingProjectId = projectId;
    _pendingBookingId = bookingId;

    debugPrint('========================================');
    debugPrint('PAYTRACK PENDING CALL SET');
    debugPrint('Phone: $_pendingCallNumber');
    debugPrint('ProjectId: $_pendingProjectId');
    debugPrint('BookingId: $_pendingBookingId');
    debugPrint('========================================');
  }

  void _handleCallState(String state) {
    debugPrint('========================================');
    debugPrint('PAYTRACK CALL STATE => $state');
    debugPrint('Pending Phone => $_pendingCallNumber');
    debugPrint('Current Phone => $_currentCallNumber');
    debugPrint('========================================');

    switch (state) {
      case 'OFFHOOK':
        _handleOffhook();
        break;

      case 'IDLE':
        _handleIdle();
        break;
    }
  }

  void _handleOffhook() {
    if (_currentCallNumber != null) {
      return;
    }

    if (_pendingCallNumber == null ||
        _pendingProjectId == null ||
        _pendingBookingId == null) {
      return;
    }

    _currentCallNumber = _pendingCallNumber;
    _currentProjectId = _pendingProjectId;
    _currentBookingId = _pendingBookingId;

    _pendingCallNumber = null;
    _pendingProjectId = null;
    _pendingBookingId = null;

    _callStartTime = DateTime.now();

    debugPrint('========================================');
    debugPrint('PAYTRACK CALL STARTED');
    debugPrint('Phone: $_currentCallNumber');
    debugPrint('ProjectId: $_currentProjectId');
    debugPrint('BookingId: $_currentBookingId');
    debugPrint('Started At: $_callStartTime');
    debugPrint('========================================');
  }

  Future<void> _handleIdle() async {
    if (_callStartTime == null ||
        _currentCallNumber == null ||
        _currentProjectId == null ||
        _currentBookingId == null) {
      return;
    }

    final endedAt = DateTime.now();

    final durationSeconds = endedAt.difference(_callStartTime!).inSeconds;

    debugPrint('========================================');
    debugPrint('PAYTRACK CALL ENDED');
    debugPrint('Phone: $_currentCallNumber');
    debugPrint('ProjectId: $_currentProjectId');
    debugPrint('BookingId: $_currentBookingId');
    debugPrint('Duration: $durationSeconds seconds');
    debugPrint('========================================');

    final entry = PayTrackCallLogEntry(
      phoneNumber: _currentCallNumber!,
      projectId: _currentProjectId!,
      bookingId: _currentBookingId!,
      startedAt: _callStartTime!,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      isSynced: false,
    );

    _saveLog(entry);

    debugPrint('Total local PayTrack logs => ${getPayTrackCallLogs().length}');

    final success = await syncPayTrackCallLogsToApi();

    debugPrint(
      success
          ? 'PAYTRACK CALL LOG API HIT SUCCESSFULLY'
          : 'PAYTRACK CALL LOG API FAILED - LOG KEPT LOCALLY',
    );

    _clearCurrentCall();
  }

  void _saveLog(PayTrackCallLogEntry entry) {
    final list = getPayTrackCallLogs();

    list.insert(0, entry);

    final toStore = list.take(_maxStoredLogs).toList();

    _storeLogs(toStore);
  }

  void _storeLogs(List<PayTrackCallLogEntry> logs) {
    final jsonList = logs.map((e) => e.toJson()).toList();

    LocalStorageManager().setString(
      StorageKey.payTrackCallLogs,
      jsonEncode(jsonList),
    );
  }

  List<PayTrackCallLogEntry> getPayTrackCallLogs() {
    final raw = LocalStorageManager().getString(StorageKey.payTrackCallLogs);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;

      return list
          .map((e) => PayTrackCallLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to read PayTrack call logs: $e');
      return [];
    }
  }

  Future<bool> syncPayTrackCallLogsToApi() async {
    final logs = getPayTrackCallLogs();

    if (logs.isEmpty) return true;

    final Map<String, List<PayTrackCallLogEntry>> groupedLogs = {};

    for (final log in logs) {
      final key = '${log.projectId}_${log.bookingId}';

      groupedLogs.putIfAbsent(key, () => []);

      groupedLogs[key]!.add(log);
    }

    final remainingLogs = List<PayTrackCallLogEntry>.from(logs);
    final client = BaseClient();

    bool allSuccess = true;

    for (final group in groupedLogs.values) {
      if (group.isEmpty) continue;

      final firstLog = group.first;

      final payload =
          group.map((log) {
            return {
              "MobileNumber": getApiMobileNumber(log.phoneNumber),
              "CallDate": _formatCallDate(log.startedAt),
              "Duration": _formatDuration(log.durationSeconds),
              "Status": "",
            };
          }).toList();

      final requestBody = {
        "ProjectId": firstLog.projectId,
        "BookingId": firstLog.bookingId,
        "CallLogJSON": jsonEncode(payload),
      };
      debugPrint('========================================');
      debugPrint('PAYTRACK ADD CALL LOG API REQUEST');
      debugPrint('URL: PayTrackCallLog/AddPayTrackCallLog');
      debugPrint('ProjectId: ${firstLog.projectId}');
      debugPrint('BookingId: ${firstLog.bookingId}');
      debugPrint('CallLogJSON: ${jsonEncode(payload)}');
      debugPrint('========================================');
      try {
        final response = await client.postRequestWithAuthentication(
          "PayTrackCallLog/AddPayTrackCallLog",
          requestBody,
        );

        debugPrint('========================================');
        debugPrint('PAYTRACK ADD CALL LOG API SUCCESS');
        debugPrint('Response: $response');
        debugPrint('========================================');

        remainingLogs.removeWhere(
          (log) =>
              log.projectId == firstLog.projectId &&
              log.bookingId == firstLog.bookingId,
        );
      } catch (e, st) {
        allSuccess = false;

        debugPrint('========================================');
        debugPrint('PAYTRACK ADD CALL LOG API FAILED');
        debugPrint('Error: $e');
        debugPrint('========================================');

        debugPrintStack(stackTrace: st);
      }
    }

    _storeLogs(remainingLogs);

    logsUpdated.value++;

    return allSuccess;
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${twoDigits(hours)}:'
        '${twoDigits(minutes)}:'
        '${twoDigits(remainingSeconds)}';
  }

  String _formatCallDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dateTime);
  }

  void _clearCurrentCall() {
    _currentCallNumber = null;
    _currentProjectId = null;
    _currentBookingId = null;
    _callStartTime = null;

    _pendingCallNumber = null;
    _pendingProjectId = null;
    _pendingBookingId = null;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;

    logsUpdated.dispose();
  }
}

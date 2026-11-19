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
import 'package:permission_handler/permission_handler.dart';

/// =======================================================
/// 1. COMMON CALL LOG MODEL
/// =======================================================

class CallLogEntry {
  final String phoneNumber;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;

  // Module information is stored with each log.
  final int projectId;
  final int id;
  final String pageName;

  CallLogEntry({
    required this.phoneNumber,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.projectId,
    required this.id,
    required this.pageName,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'projectId': projectId,
      'id': id,
      'pageName': pageName,
    };
  }

  factory CallLogEntry.fromJson(Map<String, dynamic> json) {
    return CallLogEntry(
      phoneNumber: json['phoneNumber'] ?? '',
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: DateTime.parse(json['endedAt']),
      durationSeconds: json['durationSeconds'] ?? 0,
      projectId: json['projectId'] ?? 0,
      id: json['id'] ?? 0,
      pageName: json['pageName'] ?? '',
    );
  }
}

/// =======================================================
/// 2. COMMON MODULE CONFIGURATION
/// =======================================================

class CallMonitoringConfig {
  final int projectId;
  final int id;
  final String pageName;

  const CallMonitoringConfig({
    required this.projectId,
    required this.id,
    required this.pageName,
  });
}

/// =======================================================
/// 3. CENTRALIZED CALL MONITORING SERVICE
/// =======================================================

class CallMonitoringService {
  CallMonitoringService._internal();

  static final CallMonitoringService instance =
      CallMonitoringService._internal();

  static const int _maxStoredLogs = 100;

  final ValueNotifier<int> logsUpdated = ValueNotifier(0);

  StreamSubscription<String>? _subscription;

  CallMonitoringConfig? _pendingConfig;
  String? _pendingPhoneNumber;

  CallMonitoringConfig? _currentConfig;
  String? _currentPhoneNumber;

  DateTime? _callStartTime;

  bool _syncInProgress = false;

  /// =====================================================
  /// 4. INITIALIZE LISTENER
  /// =====================================================

  Future<void> initialize() async {
    if (!Platform.isAndroid) return;

    if (_subscription != null) return;

    final permission = await Permission.phone.status;

    if (!permission.isGranted) return;

    try {
      _subscription = CallStateListener.callStateStream
          .handleError((error) {
            debugPrint('Call monitoring error: $error');
          })
          .listen(_handleCallState);

      debugPrint('Call monitoring initialized');
    } catch (e) {
      debugPrint('Call monitoring initialization failed: $e');
    }
  }

  /// =====================================================
  /// 5. REQUEST PERMISSION
  /// =====================================================

  Future<bool> ensurePhonePermission() async {
    if (!Platform.isAndroid) return false;

    var status = await Permission.phone.status;

    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      await initialize();
    }

    return status.isGranted;
  }

  /// =====================================================
  /// 6. START CALL TRACKING
  /// =====================================================

  void startCallTracking({
    required String phoneNumber,
    required CallMonitoringConfig config,
  }) {
    if (!Platform.isAndroid) return;

    _pendingPhoneNumber = phoneNumber;
    _pendingConfig = config;

    debugPrint('Call tracking pending');
    debugPrint('Phone: $phoneNumber');
    debugPrint('Page: ${config.pageName}');
  }

  /// =====================================================
  /// 7. HANDLE ANDROID CALL STATES
  /// =====================================================

  void _handleCallState(String state) {
    debugPrint('Call state: $state');

    switch (state) {
      case 'OFFHOOK':
        _handleOffhook();
        break;

      case 'IDLE':
        _handleIdle();
        break;
    }
  }

  /// =====================================================
  /// 8. CALL STARTED
  /// =====================================================

  void _handleOffhook() {
    if (_currentPhoneNumber != null) return;

    if (_pendingPhoneNumber == null || _pendingConfig == null) {
      return;
    }

    _currentPhoneNumber = _pendingPhoneNumber;
    _currentConfig = _pendingConfig;

    _callStartTime = DateTime.now();

    _pendingPhoneNumber = null;
    _pendingConfig = null;

    debugPrint('Call started');
  }

  /// =====================================================
  /// 9. CALL ENDED
  /// =====================================================

  Future<void> _handleIdle() async {
    if (_callStartTime == null ||
        _currentPhoneNumber == null ||
        _currentConfig == null) {
      return;
    }

    final endedAt = DateTime.now();

    final duration = endedAt.difference(_callStartTime!).inSeconds;

    final entry = CallLogEntry(
      phoneNumber: _currentPhoneNumber!,
      startedAt: _callStartTime!,
      endedAt: endedAt,
      durationSeconds: duration,
      projectId: _currentConfig!.projectId,
      id: _currentConfig!.id,
      pageName: _currentConfig!.pageName,
    );

    _saveLog(entry);

    _clearCurrentCall();

    await syncCallLogs();
  }

  /// =====================================================
  /// 10. LOCAL STORAGE
  /// =====================================================

  List<CallLogEntry> getCallLogs() {
    final raw = LocalStorageManager().getString(StorageKey.payTrackCallLogs);

    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> data = jsonDecode(raw);

      return data.map((e) => CallLogEntry.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Read call logs error: $e');
      return [];
    }
  }

  void _saveLog(CallLogEntry entry) {
    final logs = getCallLogs();

    logs.insert(0, entry);

    _storeLogs(logs.take(_maxStoredLogs).toList());
  }

  void _storeLogs(List<CallLogEntry> logs) {
    final data = logs.map((e) => e.toJson()).toList();

    LocalStorageManager().setString(
      StorageKey.payTrackCallLogs,
      jsonEncode(data),
    );

    logsUpdated.value++;
  }

  /// =====================================================
  /// 11. API SYNCHRONIZATION
  /// =====================================================

  Future<bool> syncCallLogs() async {
    if (_syncInProgress) return false;

    _syncInProgress = true;

    try {
      final logs = getCallLogs();

      if (logs.isEmpty) return true;

      // Group logs using all module identifiers.
      final Map<String, List<CallLogEntry>> groups = {};

      for (final log in logs) {
        final key = '${log.projectId}_${log.id}_${log.pageName}';

        groups.putIfAbsent(key, () => []);

        groups[key]!.add(log);
      }

      final remainingLogs = List<CallLogEntry>.from(logs);

      final client = BaseClient();

      bool allSuccess = true;

      for (final group in groups.values) {
        if (group.isEmpty) continue;

        final firstLog = group.first;

        final payload =
            group.map((log) {
              return {
                'MobileNumber': getApiMobileNumber(log.phoneNumber),
                'CallDate': DateFormat(
                  'yyyy-MM-dd HH:mm:ss.SSS',
                ).format(log.startedAt),
                'Duration': _formatDuration(log.durationSeconds),
                'Status': '',
              };
            }).toList();

        final requestBody = {
          'ProjectId': firstLog.projectId,
          'Id': firstLog.id,
          'PageName': firstLog.pageName,
          'CallLogJSON': jsonEncode(payload),
        };

        try {
          await client.postRequestWithAuthentication(
            'CallMonitoring/AddCallMonitoring',
            requestBody,
          );

          // Remove only successfully synchronized logs.
          remainingLogs.removeWhere((log) => group.contains(log));

          debugPrint('Call logs synced: ${firstLog.pageName}');
        } catch (e) {
          allSuccess = false;

          debugPrint('Call log sync failed: $e');
        }
      }

      _storeLogs(remainingLogs);

      return allSuccess;
    } finally {
      _syncInProgress = false;
    }
  }

  /// =====================================================
  /// 12. FORMAT DURATION
  /// =====================================================

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(hours)}:'
        '${twoDigits(minutes)}:'
        '${twoDigits(remainingSeconds)}';
  }

  /// =====================================================
  /// 13. CLEAR CURRENT CALL
  /// =====================================================

  void _clearCurrentCall() {
    _currentPhoneNumber = null;
    _currentConfig = null;
    _callStartTime = null;

    _pendingPhoneNumber = null;
    _pendingConfig = null;
  }

  /// =====================================================
  /// 14. DISPOSE
  /// =====================================================

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

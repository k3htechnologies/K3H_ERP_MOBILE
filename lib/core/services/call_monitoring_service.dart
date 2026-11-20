import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:call_state_listener/call_state_listener.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/features/call_monitoring/data/repository/call_monitoring.repository.dart';
import 'package:k3h_erp_app/utils/functions/common_function.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:permission_handler/permission_handler.dart';

/// 1. COMMON CALL LOG MODEL
class CallLogEntry {
  final String phoneNumber;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
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

  /// Stable identity, survives JSON round-trips.
  String get key =>
      '$phoneNumber|${startedAt.microsecondsSinceEpoch}|$projectId|$id|$pageName';

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

/// 2. MODULE CONFIGURATION
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

/// 3. CENTRALIZED CALL MONITORING SERVICE
class CallMonitoringService {
  CallMonitoringService._internal();

  static final CallMonitoringService instance =
      CallMonitoringService._internal();

  static const int _maxStoredLogs = 100;

  final ValueNotifier<int> logsUpdated = ValueNotifier(0);

  StreamSubscription<String>? _subscription;

  late CallMonitoringRepository repository;
  bool _repositoryInitialized = false;

  CallMonitoringConfig? _pendingConfig;
  String? _pendingPhoneNumber;

  CallMonitoringConfig? _currentConfig;
  String? _currentPhoneNumber;

  DateTime? _callStartTime;

  bool _initializing = false;
  bool _syncInProgress = false;
  bool _resyncRequested = false;

  /// 4. INITIALIZE REPOSITORY
  void initializeRepository({required CallMonitoringRepository repository}) {
    this.repository = repository;
    _repositoryInitialized = true;
  }

  /// 5. INITIALIZE LISTENER (guarded against double subscription)
  Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    if (_subscription != null || _initializing) return;

    _initializing = true;
    try {
      final permission = await Permission.phone.status;
      if (!permission.isGranted) return;

      _subscription = CallStateListener.callStateStream
          .handleError((error) {
            debugPrint('Call monitoring error: $error');
          })
          .listen(_handleCallState);

      debugPrint('Call monitoring initialized');
    } catch (e) {
      debugPrint('Call monitoring initialization failed: $e');
    } finally {
      _initializing = false;
    }
  }

  /// 6. REQUEST PHONE PERMISSION
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

  /// 7. START CALL TRACKING
  void startCallTracking({
    required String phoneNumber,
    required CallMonitoringConfig config,
  }) {
    if (!Platform.isAndroid) return;

    _pendingPhoneNumber = phoneNumber;
    _pendingConfig = config;

    debugPrint('Call tracking pending: $phoneNumber (${config.pageName})');
  }

  /// 8. HANDLE ANDROID CALL STATES
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

  /// 9. CALL STARTED
  void _handleOffhook() {
    if (_currentPhoneNumber != null) return;
    if (_pendingPhoneNumber == null || _pendingConfig == null) return;

    _currentPhoneNumber = _pendingPhoneNumber;
    _currentConfig = _pendingConfig;
    _callStartTime = DateTime.now();

    _pendingPhoneNumber = null;
    _pendingConfig = null;

    debugPrint('Call started');
  }

  /// 10. CALL ENDED
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

  /// 11. LOCAL STORAGE
  List<CallLogEntry> getCallLogs() {
    final raw = LocalStorageManager().getString(StorageKey.callMonitoringLogs);

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
      StorageKey.callMonitoringLogs,
      jsonEncode(data),
    );

    logsUpdated.value++;
  }

  /// 12. API SYNCHRONIZATION
  Future<bool> syncCallLogs() async {
    if (_syncInProgress) {
      // A call may have ended mid-sync; run once more when this one finishes.
      _resyncRequested = true;
      return false;
    }

    if (!_repositoryInitialized) {
      debugPrint('Call monitoring repository not initialized');
      return false;
    }

    _syncInProgress = true;

    try {
      final logs = getCallLogs();
      if (logs.isEmpty) return true;

      final sentKeys = logs.map((e) => e.key).toSet();
      final failedKeys = <String>{};

      // Group logs by module information.
      final Map<String, List<CallLogEntry>> groups = {};
      for (final log in logs) {
        final groupKey = '${log.projectId}_${log.id}_${log.pageName}';
        groups.putIfAbsent(groupKey, () => []).add(log);
      }

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
          final result = await repository.addCallMonitoring(body: requestBody);

          result.fold(
            (failure) {
              allSuccess = false;
              failedKeys.addAll(group.map((e) => e.key));
              debugPrint('Call log sync failed: ${failure.message}');
            },
            (response) {
              debugPrint('Call logs synced: ${firstLog.pageName}');
            },
          );
        } catch (e) {
          allSuccess = false;
          failedKeys.addAll(group.map((e) => e.key));
          debugPrint('Call log sync failed: $e');
        }
      }

      // Re-read storage: drop logs sent successfully, keep failed ones
      // and any logs added while the sync was running.
      final latestLogsToKeep =
          getCallLogs().where((log) {
            final k = log.key;
            return !sentKeys.contains(k) || failedKeys.contains(k);
          }).toList();

      _storeLogs(latestLogsToKeep);

      return allSuccess;
    } finally {
      _syncInProgress = false;

      if (_resyncRequested) {
        _resyncRequested = false;
        unawaited(syncCallLogs());
      }
    }
  }

  /// 13. FORMAT DURATION
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(remainingSeconds)}';
  }

  /// 14. CLEAR CURRENT CALL
  void _clearCurrentCall() {
    _currentPhoneNumber = null;
    _currentConfig = null;
    _callStartTime = null;
    _pendingPhoneNumber = null;
    _pendingConfig = null;
  }

  /// 15. DISPOSE
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

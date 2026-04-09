/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:call_state_listener/call_state_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';

/// Single entry for a call initiated from the app (e.g. via CustomClickToContact).
/// We do NOT read device call history – only track when user taps call in our app
/// and telephony state goes OFFHOOK → IDLE.
class AppInitiatedCallEntry {
  final String phoneNumber;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;

  AppInitiatedCallEntry({
    required this.phoneNumber,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
  };

  factory AppInitiatedCallEntry.fromJson(Map<String, dynamic> json) {
    return AppInitiatedCallEntry(
      phoneNumber: json['phoneNumber'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationSeconds: json['durationSeconds'] as int,
    );
  }
}

/// Tracks calls that are initiated from the app (e.g. CustomClickToContact).
/// Uses telephony state only (OFFHOOK / IDLE) on Android – no READ_CALL_LOG.
/// Logs are stored locally and can be shown on the dashboard.
class AppCallTrackerService {
  AppCallTrackerService({bool enableCallStateListener = true}) {
    if (enableCallStateListener && Platform.isAndroid) {
      _startListening();
    }
  }

  static const int _maxStoredLogs = 100;

  final ValueNotifier<int> logsUpdated = ValueNotifier(0);

  String? _pendingCallNumber;
  String? _currentCallNumber;
  DateTime? _callStartTime;
  StreamSubscription<String>? _subscription;

  void _startListening() {
    try {
      _subscription = CallStateListener.callStateStream
          .handleError((error, stackTrace) {
            // Swallow platform errors from the native listen call so the app
            // does not crash if the plugin fails (e.g. missing permission).
            if (kDebugMode) {
              debugPrint('CallStateListener error: $error');
            }
          })
          .listen((String state) {
            switch (state) {
              case 'OFFHOOK':
                if (_pendingCallNumber != null) {
                  _currentCallNumber = _pendingCallNumber;
                  _pendingCallNumber = null;
                  _callStartTime = DateTime.now();
                }
                break;
              case 'IDLE':
                if (_callStartTime != null && _currentCallNumber != null) {
                  final endedAt = DateTime.now();
                  final durationSeconds =
                      endedAt.difference(_callStartTime!).inSeconds;
                  _saveLog(
                    AppInitiatedCallEntry(
                      phoneNumber: _currentCallNumber!,
                      startedAt: _callStartTime!,
                      endedAt: endedAt,
                      durationSeconds: durationSeconds,
                    ),
                  );
                  _currentCallNumber = null;
                  _callStartTime = null;
                  logsUpdated.value++;
                }
                break;
              default:
                break;
            }
          });
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Failed to start CallStateListener: $e\n$st');
      }
    }
  }

  /// Call this when the user taps to call from the app (e.g. CustomClickToContact).
  /// Only the next OFFHOOK→IDLE cycle will be attributed to this number.
  void setPendingCall(String phoneNumber) {
    if (!Platform.isAndroid) return;
    _pendingCallNumber = phoneNumber;
  }

  void _saveLog(AppInitiatedCallEntry entry) {
    final list = getAppInitiatedCallLogs();
    list.insert(0, entry);
    final toStore = list.take(_maxStoredLogs).toList();
    final jsonList = toStore.map((e) => e.toJson()).toList();
    LocalStorageManager().setString(
      StorageKey.appInitiatedCallLogs,
      jsonEncode(jsonList),
    );
  }

  /// Returns stored app-initiated call logs (newest first).
  List<AppInitiatedCallEntry> getAppInitiatedCallLogs() {
    final raw = LocalStorageManager().getString(
      StorageKey.appInitiatedCallLogs,
    );
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AppInitiatedCallEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void dispose() {
    _subscription?.cancel();
    logsUpdated.dispose();
  }
}
*/


import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:call_state_listener/call_state_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:k3h_erp_app/core/local_storage_manager.dart';
import 'package:k3h_erp_app/service/base_client.dart';
import 'package:k3h_erp_app/utils/storage_key.dart';
import 'package:k3h_erp_app/utils/utility_function.dart';

class AppInitiatedCallEntry {
  final String phoneNumber;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final bool isSynced;

  AppInitiatedCallEntry({
    required this.phoneNumber,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt.toIso8601String(),
    'durationSeconds': durationSeconds,
    'isSynced': isSynced,
  };

  factory AppInitiatedCallEntry.fromJson(Map<String, dynamic> json) {
    return AppInitiatedCallEntry(
      phoneNumber: json['phoneNumber'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationSeconds: json['durationSeconds'] as int,
      isSynced: json['isSynced'] ?? false,
    );
  }

  AppInitiatedCallEntry copyWith({
    String? phoneNumber,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    bool? isSynced,
  }) {
    return AppInitiatedCallEntry(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

class AppCallTrackerService {
  AppCallTrackerService({bool enableCallStateListener = true}) {
    if (enableCallStateListener && Platform.isAndroid) {
      _startListening();
    }
  }

  static const int _maxStoredLogs = 100;

  final ValueNotifier<int> logsUpdated = ValueNotifier(0);

  String? _pendingCallNumber;
  String? _currentCallNumber;
  DateTime? _callStartTime;
  StreamSubscription<String>? _subscription;

  void _startListening() {
    try {
      _subscription = CallStateListener.callStateStream
          .handleError((error, stackTrace) {
        if (kDebugMode) {
          debugPrint('CallStateListener error: $error');
        }
      }).listen((String state) {
        debugPrint('Call state => $state');
        debugPrint('Pending => $_pendingCallNumber');
        debugPrint('Current => $_currentCallNumber');

        switch (state) {
          case 'OFFHOOK':
            if (_pendingCallNumber != null) {
              _currentCallNumber = _pendingCallNumber;
              _pendingCallNumber = null;
              _callStartTime = DateTime.now();
              debugPrint(
                'Call started for $_currentCallNumber at $_callStartTime',
              );
            }
            break;

          case 'IDLE':
            if (_callStartTime != null && _currentCallNumber != null) {
              final endedAt = DateTime.now();
              final durationSeconds =
                  endedAt.difference(_callStartTime!).inSeconds;

              final entry = AppInitiatedCallEntry(
                phoneNumber: _currentCallNumber!,
                startedAt: _callStartTime!,
                endedAt: endedAt,
                durationSeconds: durationSeconds,
                isSynced: false,
              );

              debugPrint(
                'Saving call log => ${entry.phoneNumber}, duration => ${entry.durationSeconds}',
              );

              _saveLog(entry);

              final savedLogs = getAppInitiatedCallLogs();
              debugPrint('Total local logs => ${savedLogs.length}');

              _currentCallNumber = null;
              _callStartTime = null;
              logsUpdated.value++;
            }
            break;

          default:
            break;
        }
      });
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Failed to start CallStateListener: $e\n$st');
      }
    }
  }

  void setPendingCall(String phoneNumber) {
    if (!Platform.isAndroid) return;
    _pendingCallNumber = phoneNumber;
    debugPrint('Pending call set => $phoneNumber');
  }

  void _saveLog(AppInitiatedCallEntry entry) {
    final list = getAppInitiatedCallLogs();
    list.insert(0, entry);
    final toStore = list.take(_maxStoredLogs).toList();
    _storeLogs(toStore);
  }

  void _storeLogs(List<AppInitiatedCallEntry> logs) {
    final jsonList = logs.map((e) => e.toJson()).toList();
    LocalStorageManager().setString(
      StorageKey.appInitiatedCallLogs,
      jsonEncode(jsonList),
    );
  }

  List<AppInitiatedCallEntry> getAppInitiatedCallLogs() {
    final raw = LocalStorageManager().getString(
      StorageKey.appInitiatedCallLogs,
    );

    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AppInitiatedCallEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> syncTodayCallLogsToApi() async {
    final logs = getAppInitiatedCallLogs();
    final now = DateTime.now();

    final todayLogs = logs.where((log) {
      final d = log.startedAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

    print("hhh=>${todayLogs}");

    if (todayLogs.isEmpty) return true;

    final payload = todayLogs
        .map(
          (log) => {
        "MobileNumber": log.phoneNumber,
        "CallDate": _formatCallDateForApi(log.startedAt),
        "Duration": _formatDurationForApi(log.durationSeconds),
        "Status": "",
      },
    )
        .toList();

    final wrapper = {
      "ProjectId": getProject().projectId,
      "CallLogJSON": jsonEncode(payload),
    };

    try {
      final client = BaseClient();
      await client.postRequestWithAuthentication("CallLog/AddCallLog", wrapper);

      ///  CLEAR ALL LOGS AFTER SUCCESS
      LocalStorageManager().setString(
        StorageKey.appInitiatedCallLogs,
        jsonEncode([]),
      );

      logsUpdated.value++;

      return true;
    } catch (e, st) {
      debugPrint("Call log sync failed: $e");
      debugPrintStack(stackTrace: st);
      return false;
    }
  }

  String _formatDurationForApi(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;

    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  String _formatCallDateForApi(DateTime dt) {
    return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(dt);
  }

  void dispose() {
    _subscription?.cancel();
    logsUpdated.dispose();
  }
}
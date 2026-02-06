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

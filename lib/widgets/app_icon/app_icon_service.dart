import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppIconService {
  static const MethodChannel _channel = MethodChannel('com.k3h.app/app_icon');

  static Future<void> updateSeasonalIcon() async {
    // Prevent Platform-related issues on Flutter Web
    if (kIsWeb) return;

    final iconName = _getSeasonalIcon();

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _channel.invokeMethod('changeAppIcon', {'iconName': iconName});
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await _channel.invokeMethod('changeAppIcon', {'iconName': iconName});
      }

      debugPrint('Seasonal icon update requested: ${iconName ?? "Default"}');
    } on PlatformException catch (e) {
      debugPrint(
        'Failed to change app icon: '
        '${e.code} - ${e.message}',
      );
    } catch (e) {
      debugPrint('Failed to change app icon: $e');
    }
  }

  static String? _getSeasonalIcon() {
    final now = DateTime.now();

    // Raksha Bandhan
    final rakshaBandhanStart = DateTime(2026, 8, 19);
    final rakshaBandhanEnd = DateTime(2026, 8, 31, 23, 59, 59);

    if (!now.isBefore(rakshaBandhanStart) && !now.isAfter(rakshaBandhanEnd)) {
      return 'Rakshabandhan';
    }

    return null;
  }
}

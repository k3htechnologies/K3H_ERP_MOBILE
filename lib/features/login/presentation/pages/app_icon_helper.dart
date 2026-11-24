import 'package:dynamic_app_icon_flutter_plus/dynamic_app_icon_flutter_plus.dart';
import 'package:flutter/foundation.dart';

/// Single source of truth for every launcher icon.
///
/// [alias] must match the native activity-alias suffix:
/// MainActivity.default / .diwali / .holi / .christmas / .newyear
enum AppIcon {
  defaultIcon('default'),
  diwali('diwali'),
  holi('holi'),
  christmas('christmas'),
  newYear('newyear');

  const AppIcon(this.alias);

  final String alias;

  bool get isDefault => this == AppIcon.defaultIcon;

  /// Tolerant parser: "Diwali", "New Year", "new-year", null -> safe fallback.
  static AppIcon fromName(String? raw) {
    final key = (raw ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    return values.firstWhere(
      (icon) => icon.alias == key,
      orElse: () => AppIcon.defaultIcon,
    );
  }
}

class AppIconHelper {
  AppIconHelper._();

  static AppIcon? _current;
  static bool _busy = false;

  /// Reads the real native icon once, then serves from memory.
  /// Native is the source of truth, so no SharedPreferences is needed.
  static Future<AppIcon> getCurrent() async {
    if (_current != null) return _current!;

    try {
      final alias = await DynamicAppIconFlutterPlus.getAlternateIconName();
      return _current = AppIcon.fromName(alias);
    } catch (e) {
      debugPrint('[AppIcon] getCurrent failed: $e');
      return AppIcon.defaultIcon; // not cached, so we retry next time
    }
  }

  /// Changes the launcher icon. Returns true if the icon is now [icon].
  static Future<bool> change(AppIcon icon) async {
    if (kIsWeb || _busy) return false;

    _busy = true;
    try {
      if (await getCurrent() == icon) return true; // no native call needed

      await DynamicAppIconFlutterPlus.setAlternateIconName(
        icon.isDefault ? null : icon.alias,
        showAlert: true,
      );

      _current = icon;
      debugPrint('[AppIcon] Changed to: ${icon.alias}');
      return true;
    } catch (e, st) {
      debugPrint('[AppIcon] Change failed: $e\n$st');
      return false;
    } finally {
      _busy = false;
    }
  }

  /// Applies the icon for the festival sent by the API
  /// (`data["NameOfFestival"]`). Empty/unknown value -> default icon.
  static Future<bool> applyFromServer(Map<String, dynamic> data) {
    return change(AppIcon.fromName(data['NameOfFestival']?.toString()));
  }
}

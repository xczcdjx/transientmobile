import 'package:shared_preferences/shared_preferences.dart';
import '../constants/HiveKeys.dart';
import 'HiveUtil.dart';

/// Retains legacy data as a fallback. Only mark complete after Hive is flushed.
class PreferencesMigration {
  PreferencesMigration._();
  static const marker = 'shared_preferences_migrated_v1';
  static const settingsKeys = {
    'theme_mode',
    'theme_color',
    'theme_custom_color',
    'theme_is_custom',
    'locale',
  };

  static Future<void> migrate() async {
    final app = HiveUtil.getBox(HiveKeys.app);
    if (app.get(marker) == true) return;
    final settings = HiveUtil.getBox(HiveKeys.settings);
    final old = await SharedPreferences.getInstance();
    for (final key in old.getKeys()) {
      final value = old.get(key);
      final target = settingsKeys.contains(key) ? settings : app;
      if (value != null && !target.containsKey(key)) {
        await target.put(key, value);
      }
    }
    await settings.flush();
    await app.flush();
    await app.put(marker, true);
    await app.flush();
  }
}

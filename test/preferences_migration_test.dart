import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transientmobile/constants/HiveKeys.dart';
import 'package:transientmobile/utils/HiveUtil.dart';
import 'package:transientmobile/utils/preferences_migration.dart';
import 'package:transientmobile/utils/settings_storage.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('transient-migration-');
    Hive.init(directory.path);
    await HiveUtil.openBox(HiveKeys.app);
    await HiveUtil.openBox(HiveKeys.settings);
    SharedPreferences.setMockInitialValues({
      'theme_mode': 2,
      'theme_color': 0xFF123456,
      'theme_custom_color': 0xFFABCDEF,
      'theme_is_custom': true,
      'locale': 'zh_CN',
      'token': 'legacy-jwt',
      'example_list': <String>['a', 'b'],
    });
  });
  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
      'legacy preferences persist in Hive after reopening, without deleting the source',
      () async {
    await PreferencesMigration.migrate();
    await Hive.close();
    await HiveUtil.openBox(HiveKeys.app);
    await HiveUtil.openBox(HiveKeys.settings);
    expect(SettingsStorage.get<int>('theme_mode'), 2);
    expect(SettingsStorage.get<int>('theme_custom_color'), 0xFFABCDEF);
    expect(SettingsStorage.get<bool>('theme_is_custom'), isTrue);
    expect(SettingsStorage.languageCode, 'zh');
    expect(HiveUtil.get<String>('token'), 'legacy-jwt');
    expect(HiveUtil.get<List>('example_list'), ['a', 'b']);
    expect((await SharedPreferences.getInstance()).getString('token'),
        'legacy-jwt');
  });

  test('migration preserves existing Hive values and runs only once', () async {
    await SettingsStorage.set('theme_mode', 1);
    await PreferencesMigration.migrate();
    expect(SettingsStorage.get<int>('theme_mode'), 1);
    await SettingsStorage.set('locale', 'en');
    await (await SharedPreferences.getInstance()).setString('locale', 'zh');
    await PreferencesMigration.migrate();
    expect(SettingsStorage.languageCode, 'en');
  });

  test('wrong stored types and unsupported languages fall back safely',
      () async {
    await SettingsStorage.set('theme_mode', 'invalid');
    expect(SettingsStorage.get<int>('theme_mode', defaultValue: 0), 0);
    await SettingsStorage.set('locale', 'not-a-locale');
    expect(SettingsStorage.languageCode, isNull);
  });
}

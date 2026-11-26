import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../utils/settings_storage.dart';

class LangSwitch extends StatelessWidget {
  const LangSwitch({super.key, this.iconRender = false});
  final bool iconRender;
  static const _languages = {'en': 'English', 'zh': '中文'};

  Future<void> _change(BuildContext context, String? language) async {
    if (language == null || !_languages.containsKey(language)) return;
    await SettingsStorage.set('locale', language);
    if (context.mounted) await context.setLocale(Locale(language));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;
    if (iconRender) {
      return GestureDetector(
        onTapDown: (details) async {
          final selected = await showMenu<String>(
            context: context,
            position: RelativeRect.fromLTRB(
                details.globalPosition.dx,
                details.globalPosition.dy,
                details.globalPosition.dx,
                details.globalPosition.dy),
            items: _languages.entries
                .map((entry) => PopupMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value,
                          style: TextStyle(
                              color: entry.key == language
                                  ? Theme.of(context).colorScheme.primary
                                  : null)),
                    ))
                .toList(),
          );
          if (context.mounted) await _change(context, selected);
        },
        child: Image.asset('assets/images/lang.png', width: 24, height: 24),
      );
    }
    return DropdownButton<String>(
      value: _languages.containsKey(language) ? language : 'en',
      items: _languages.entries
          .map((entry) => DropdownMenuItem<String>(
              value: entry.key, child: Text(entry.value)))
          .toList(),
      onChanged: (value) => _change(context, value),
    );
  }
}

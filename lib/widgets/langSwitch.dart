import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:transientmobile/extensions/customColors.dart';
import 'package:transientmobile/utils/shareStorage.dart';

class LangSwitch extends StatefulWidget {
  bool iconRender;

  LangSwitch({super.key, this.iconRender = false});

  @override
  State<LangSwitch> createState() => _LangSwitch();
}

class LanCls {
  String k;
  String v;

  LanCls(this.k, this.v);
}

class _LangSwitch extends State<LangSwitch> {
  String _currentLang = "en";
  final List<LanCls> languages = [
    LanCls("en", "English"),
    LanCls("zh", "中文"),
  ];

// 切换语言并保存到本地
  Future<void> changeLanguage(String lang) async {
    await context.setLocale(Locale(lang));
    await WidgetsBinding.instance.performReassemble(); // ui重汇
    // await ShareStorage.set('locale', locale.languageCode);
  }

  Future<void> _loadLang() async {
    final savedLang = ShareStorage.get('locale');
    print(savedLang);
    if (savedLang != null) {
      setState(() {
        _currentLang = savedLang;
      });
      // context.setLocale(Locale(savedLang));
    } else {
      // 如果没有保存过，使用系统语言
      final systemLocale = context.deviceLocale.languageCode;
      if (languages.any((l) => l.k == systemLocale)) {
        setState(() {
          _currentLang = systemLocale;
        });
        // context.setLocale(Locale(systemLocale));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLang();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.iconRender
        ? GestureDetector(
      onTapDown: (details) async {
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
          // color: const Color(0xFF001F3F),
          items: languages.map((entry) {
            return PopupMenuItem<String>(
              value: entry.k,
              child: Text(
                entry.v,
                style: TextStyle(
                  color: entry.k == _currentLang
                      ? context.primary
                      : null,
                ),
              ),
            );
          }).toList(),
        );
        _switchLang(selected);
      },
      child: Image.asset('assets/images/lang.png', width: 24, height: 24),
    )
        : DropdownButton<String>(
      // dropdownColor: Color(0xFF001F3F),
      value: _currentLang,
      items: languages.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.k,
          child: Text(entry.v, style: TextStyle(
              color: entry.k==_currentLang?context.primary:null)),
        );
      }).toList(),
      onChanged: _switchLang,
    );
  }

  _switchLang(String? val) {
    if (val != null) {
      setState(() {
        _currentLang = val;
      });
      changeLanguage(_currentLang);
    }
  }
}

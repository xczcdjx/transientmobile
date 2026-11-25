import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:transientmobile/pages/home/musicPage.dart';
import 'package:transientmobile/pages/home/searchPage.dart';
import '../components/common/botNavBar.dart';
import '../music/musBotScreen.dart';
import '../store/index.dart';
import '../utils/getDevice.dart';
import 'home/homePage.dart';
import 'home/minePage.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({super.key});

  @override
  ConsumerState<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> {
  int _pageIndex = 0;
  final _pages = const [HomePage(), SearchPage(), MusicPage(), MinePage()];

  void _select(int index) {
    if (index != _pageIndex) setState(() => _pageIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final wide = isTabletAll(context);
    final hasSong = ref.watch(musPlayProvider.select((s) => s.curSong != null));
    final colors = Theme.of(context).colorScheme;
    final body = IndexedStack(index: _pageIndex, children: [
      for (var i = 0; i < _pages.length; i++)
        TickerMode(enabled: i == _pageIndex, child: _pages[i]),
    ]);
    return GlassScaffold(
      edgeFade: false,
      extendBody: false,
      background: DecoratedBox(
          decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Color.alphaBlend(
                  colors.primary.withValues(alpha: 0.08), colors.surface)
            ]),
      )),
      body: SafeArea(
          bottom: false,
          child: wide
              ? Row(children: [
                  BotNavBar(
                      isTablet: true,
                      selectedIndex: _pageIndex,
                      onTabChange: _select),
                  Expanded(child: body)
                ])
              : body),
      bottomBarHeight: wide ? (hasSong ? 86 : 0) : (hasSong ? 152 : 86),
      bottomBar: Column(mainAxisSize: MainAxisSize.min, children: [
        if (hasSong)
          Padding(
            padding: EdgeInsets.fromLTRB(wide ? 120 : 20, 8, 20, 4),
            child: Container(
              decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.45))),
              clipBehavior: Clip.antiAlias,
              child: const MusBotScreen(),
            ),
          ),
        if (!wide) BotNavBar(selectedIndex: _pageIndex, onTabChange: _select),
        if (wide && hasSong)
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
      ]),
    );
  }
}

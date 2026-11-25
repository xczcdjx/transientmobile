import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../components/common/botNavBar.dart';
import '../music/musBotScreen.dart';
import '../store/index.dart';
import '../utils/getDevice.dart';
import '../widgets/frosted_surface.dart';
import 'mainTab/homePage.dart';
import 'mainTab/minePage.dart';
import 'mainTab/searchPage.dart';
import 'mainTab/musicPage.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({super.key});

  @override
  ConsumerState<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends ConsumerState<IndexPage> {
  static const _tabCount = 4;
  final Set<int> _visitedTabs = {0};
  // Keep the mounted tab subtree when switching between bottom and side bars.
  final _tabsKey = GlobalKey();
  int _pageIndex = 0;

  List<Widget> get _pages => List.generate(_tabCount, (index) {
        if (!_visitedTabs.contains(index)) return const SizedBox.shrink();
        final page = switch (index) {
          0 => const HomePage(),
          1 => const SearchPage(),
          2 => const MusicPage(),
          3 => const MinePage(),
          _ => const SizedBox.shrink(),
        };
        return TickerMode(
          enabled: index == _pageIndex,
          child: ExcludeFocus(excluding: index != _pageIndex, child: page),
        );
      });

  void _select(int index) {
    if (index < 0 || index >= _tabCount || index == _pageIndex) return;
    setState(() {
      _pageIndex = index;
      _visitedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = isTabletAll(context);
    final hasSong = ref.watch(musPlayProvider.select((s) => s.curSong != null));
    final colors = Theme.of(context).colorScheme;
    final bottomHeight =
        wide ? (hasSong ? 86.0 : 0.0) : (hasSong ? 152.0 : 86.0);
    // Read insets below SafeArea so its consumed top padding is not restored.
    // Only add scrolling clearance for the floating controls at the bottom.
    final body = Builder(builder: (context) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(
          padding: media.padding.copyWith(
            bottom: bottomHeight + media.padding.bottom,
          ),
        ),
        child: IndexedStack(
          key: _tabsKey,
          index: _pageIndex,
          children: _pages,
        ),
      );
    });
    return GlassScaffold(
      edgeFade: false,
      extendBody: true,
      // Match the page canvas so the floating controls have no tinted strip.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      bottomBarHeight: bottomHeight,
      bottomBar: Column(mainAxisSize: MainAxisSize.min, children: [
        if (hasSong)
          Padding(
            padding: EdgeInsets.fromLTRB(wide ? 120 : 20, 8, 20, 4),
            child: wide
                ? const FrostedSurface(child: MusBotScreen())
                : Container(
                    transform: Matrix4.translationValues(0, 15, 0),
                    decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color:
                                colors.outlineVariant.withValues(alpha: 0.45))),
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

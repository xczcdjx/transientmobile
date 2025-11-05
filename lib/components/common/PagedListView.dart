// paged_list_view.dart
import 'package:flutter/material.dart';

/// 分页结果
class PageResult<T> {
  final List<T> items;
  final int total;
  PageResult({required this.items, required this.total});
}

/// 获取分页的函数签名：给你 pageNo/pageSize，返回 PageResult
typedef FetchPage<T> = Future<PageResult<T>> Function(int pageNo, int pageSize);

/// 通用分页列表
class PagedListView<T> extends StatefulWidget {
  const PagedListView({
    Key? key,
    required this.fetchPage,
    required this.itemBuilder,
    this.pageSize = 10,
    this.padding,
    this.separatorBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.physics,
    this.controller,
    this.initialRefresh = true,
    this.loadMoreTriggerOffset = 200.0, // 距底部 N 像素开始触发加载更多
  }) : super(key: key);

  /// 异步获取分页数据（必须）
  final FetchPage<T> fetchPage;

  /// 列表 ItemBuilder（必须）
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 每页数量，默认 10
  final int pageSize;

  /// 边距
  final EdgeInsetsGeometry? padding;

  /// 分割线
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// 空态
  final WidgetBuilder? emptyBuilder;

  /// 错误态
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;

  /// 自定义滚动物理
  final ScrollPhysics? physics;

  /// 可选外部控制器
  final ScrollController? controller;

  /// 组件首次构建时是否自动刷新加载第一页
  final bool initialRefresh;

  /// 与底部的触发距离
  final double loadMoreTriggerOffset;

  @override
  State<PagedListView<T>> createState() => _PagedListViewState<T>();
}

class _PagedListViewState<T> extends State<PagedListView<T>> {
  final List<T> _data = <T>[];

  /// 三个核心字段
  int _pageNo = 1;
  late final int _pageSize;
  int _total = 0;

  bool _initialized = false;
  bool _isLoading = false;
  Object? _error;

  late final ScrollController _scrollController;

  bool get _hasMore => _data.length < _total;
  bool get _isEmpty => _data.isEmpty && !_isLoading && _error == null;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.pageSize;
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);

    if (widget.initialRefresh) {
      // 首次自动刷新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refresh();
      });
    } else {
      _initialized = true;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || !_hasMore) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.position.pixels;
    if (max - offset <= widget.loadMoreTriggerOffset) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _pageNo = 1;
    });
    try {
      final res = await widget.fetchPage(_pageNo, _pageSize);
      setState(() {
        _data
          ..clear()
          ..addAll(res.items);
        _total = res.total;
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = e;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = null; // 清掉老的错误
    });
    try {
      final nextPage = _pageNo + 1;
      final res = await widget.fetchPage(nextPage, _pageSize);
      setState(() {
        _pageNo = nextPage;
        _data.addAll(res.items);
        _total = res.total; // 以服务端为准（可能变化）
      });
    } catch (e) {
      setState(() {
        _error = e;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildFooter() {
    if (_error != null && _data.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: TextButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.refresh),
            label: const Text('加载失败，点击重试'),
          ),
        ),
      );
    }
    if (_hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    // 没有更多
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: Text('没有更多了')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _buildList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: list,
    );
  }

  Widget _buildList() {
    if (!_initialized && _isLoading) {
      // 首屏骨架
      return ListView.builder(
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        controller: _scrollController,
        itemCount: 6,
        itemBuilder: (_, __) => const _SkeletonItem(),
      );
    }

    if (_error != null && _data.isEmpty) {
      // 整页错误态
      final builder = widget.errorBuilder;
      if (builder != null) {
        return builder(context, _error!, _refresh);
      }
      return ListView(
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        controller: _scrollController,
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 40, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          const Center(child: Text('加载失败')),
          const SizedBox(height: 8),
          Center(
            child: ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ),
        ],
      );
    }

    if (_isEmpty) {
      // 空态
      final builder = widget.emptyBuilder;
      if (builder != null) return builder(context);
      return ListView(
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        controller: _scrollController,
        children: const [
          SizedBox(height: 120),
          Icon(Icons.inbox, size: 40),
          SizedBox(height: 12),
          Center(child: Text('暂无数据')),
        ],
      );
    }

    final itemCount = _data.length + 1; // +1 放 footer
    final separator = widget.separatorBuilder;

    if (separator != null) {
      return ListView.separated(
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        controller: _scrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == _data.length) return _buildFooter();
          final item = _data[index];
          return widget.itemBuilder(context, item, index);
        },
        separatorBuilder: (context, index) =>
        index == _data.length - 1 ? const SizedBox.shrink() : separator(context, index),
      );
    }

    return ListView.builder(
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      controller: _scrollController,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == _data.length) return _buildFooter();
        final item = _data[index];
        return widget.itemBuilder(context, item, index);
      },
    );
  }
}

/// 简单的骨架占位
class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(height: 48, width: 48, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: double.infinity, color: Colors.black12),
                const SizedBox(height: 8),
                Container(height: 14, width: 160, color: Colors.black12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

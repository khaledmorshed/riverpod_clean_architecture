import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PagingView extends StatelessWidget {
  final Widget child;
  final VoidCallback onLoadNextPage;
  final Future<void> Function()? onRefresh;
  final bool isLoadingNextPage;

  const PagingView({
    super.key,
    required this.child,
    required this.onLoadNextPage,
    this.onRefresh,
    this.isLoadingNextPage = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoadingNextPage &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 &&
            scrollInfo.metrics.axisDirection == AxisDirection.down) {
          onLoadNextPage();
        }
        return false;
      },
      child: child,
    );

    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }
}

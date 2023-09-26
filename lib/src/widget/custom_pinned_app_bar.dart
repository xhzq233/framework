import 'package:flutter/widgets.dart';

class CustomPinnedAppBar extends StatelessWidget {
  const CustomPinnedAppBar({
    super.key,
    this.height = 44,
    this.fillColor = const Color(0xFFFFFFFF),
    required this.content,
  });

  final Color fillColor;

  final double height;

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: CustomPinnedAppBarDelegate(
        MediaQuery.viewPaddingOf(context).top,
        content: content,
      ),
      pinned: true,
    );
  }
}

class CustomPinnedAppBarDelegate extends SliverPersistentHeaderDelegate {
  CustomPinnedAppBarDelegate(
    this.topViewPadding, {
    this.height = 44,
    this.fillColor = const Color(0xFFFFFFFF),
    required this.content,
  }) : _total = topViewPadding + height;

  @override
  double get maxExtent => _total;

  final double topViewPadding;

  final double height;

  final Widget content;

  final double _total;

  final Color fillColor;

  @override
  double get minExtent => _total;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: fillColor.withOpacity(shrinkOffset / _total),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: topViewPadding),
          child: SizedBox(height: height, width: double.infinity, child: content),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(CustomPinnedAppBarDelegate oldDelegate) => _total != oldDelegate._total;
}

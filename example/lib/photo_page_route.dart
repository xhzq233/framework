import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framework/route.dart';

import 'package:framework/widgets.dart';

class PreviewImage extends StatelessWidget {
  const PreviewImage({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = hashCode;
    final child = NNImage('https://q1.qlogo.cn/g?b=qq&nk=1761373255&s=100');
    return GestureDetector(
      onTap: () => Navigator.of(context).push(PhotoPageRoute(draggableChild: child, heroTag: tag)),
      child: Hero(
        tag: tag,
        child: child,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: _Home()));
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: NNRefreshIndicator(
        onRefresh: () {
          (context as Element).markNeedsBuild();
          return Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              child: ColoredBox(
                color: Colors.green.withOpacity(0.6),
                child: const Align(child: PreviewImage()),
              ),
            )
          ],
        ),
      ),
    );
  }
}

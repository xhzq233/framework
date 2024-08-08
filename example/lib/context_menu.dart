import 'package:flutter/cupertino.dart';
import 'package:boxy/boxy.dart';
import 'package:flutter/material.dart';
import 'package:framework/cupertino.dart';
import 'package:framework/layout.dart';
import 'package:framework/util.dart';

void main() {
  runApp(
    const CupertinoApp(
      color: Colors.red,
      home: ContextMenuPage(),
    ),
  );
}

class ContextMenuPage extends StatelessWidget {
  const ContextMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const ts = TextStyle(decoration: TextDecoration.none, color: Colors.white, fontSize: 12);
    final actions = [
      CustomCupertinoContextMenuAction(
        child: const Text('copy'),
        onPressed: () => Navigator.pop(context),
      ),
    ];
    overflow(String s) => Container(
        color: Colors.red,
        width: 100,
        height: 700,
        alignment: Alignment.center,
        child: Text('$s overflow & long long long long text', style: ts));

    small(String s) => Container(color: Colors.red, width: 100, height: 100, child: Text('$s small', style: ts));
    const padding = SizedBox(height: 20, width: 20);
    const spacer = Spacer();
    final scrollView = SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 20,
            width: 50,
            child: CustomBoxy(
                delegate: AutoFittedBoxyDelegate(
                  originalSize: const Size(100, 100),
                  scaleLowerLimit: 0.2,
                ),
                children: [
                  CustomCupertinoButton(
                      child: Container(
                        color: Colors.red,
                        width: 100,
                        height: 100,
                      ),
                      onTap: () {
                        // success!
                        // logger.d('测试hitTest success!');
                      }),
                ]),
          ).border(),
          padding,
          Row(
            children: [padding, CustomCupertinoContextMenu(actions: actions, child: overflow('Custom')), spacer],
          ),
          padding,
          Row(
            children: [padding, CupertinoContextMenu(actions: actions, child: overflow('Cupertino')), spacer],
          ),
          padding,
          Row(
            children: [spacer, CustomCupertinoContextMenu(actions: actions, child: small('Custom')), padding],
          ),
          padding,
          Row(
            children: [spacer, CupertinoContextMenu(actions: actions, child: small('Cupertino')), padding],
          ),
        ],
      ),
    );

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: scrollView,
      ),
    );
  }
}

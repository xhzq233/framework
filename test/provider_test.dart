/// framework - main.dart
/// Created by xhz on 9/8/24

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:framework/base.dart';

class MyProvider extends Provider {
  int state = 0;
  bool disposed = false;

  @override
  void notifyListeners() {
    state++;
    super.notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

class MyProvider2 extends AspectProvider {
  int state = 0;
  @override
  void notifyListeners() {
    state++;
    super.notifyListeners();
  }
}

void main() {
  testWidgets('MyProvider Accessibility', (tester) async {
    await tester.pumpWidget(ProviderWidget(provider: MyProvider(), child: const SizedBox()));
    final provider = Provider.read<MyProvider>(tester.element(find.byType(SizedBox)));
    expect(provider, isNotNull);
  });

  testWidgets('MyProvider notify widgets', (tester) async {
    await tester.pumpWidget(ProviderWidget(
        provider: MyProvider(),
        child: Builder(builder: (context) {
          final provider = Provider.watch<MyProvider>(context);
          return SizedBox(key: ValueKey(provider.state));
        })));
    final provider = Provider.read<MyProvider>(tester.element(find.byType(SizedBox)));
    expect(provider.state, 0);
    expect(find.byKey(const ValueKey(0)), findsOneWidget);
    provider.notifyListeners();
    await tester.pump();
    expect(provider.state, 1);
    expect(find.byKey(const ValueKey(1)), findsOneWidget);
  });

  testWidgets('MyProvider not dispose after unmount with ProviderWidget', (tester) async {
    await tester.pumpWidget(ProviderWidget(provider: MyProvider(), child: const SizedBox()));
    final provider = Provider.read<MyProvider>(tester.element(find.byType(SizedBox)));
    final providerElement = tester.providerElement;
    expect(provider.disposed, isFalse);
    expect(providerElement.lazyProviderInstance, isNull);
    await tester.pumpWidget(const SizedBox());
    expect(provider.disposed, isFalse, reason: 'MyProvider lifecycle managed by itself');
    expect(providerElement.lazyProviderInstance, isNull);
  });

  testWidgets('MyProvider dispose after unmount', (tester) async {
    await tester.pumpWidget(ProviderWidget.owned(provider: (ctx) => MyProvider(), child: const SizedBox()));
    final provider = Provider.read<MyProvider>(tester.element(find.byType(SizedBox)));
    final providerElement = tester.providerElement;
    expect(providerElement.lazyProviderInstance, isNotNull);
    expect(provider.disposed, isFalse);
    await tester.pumpWidget(const SizedBox());
    expect(provider.disposed, isTrue, reason: 'MyProvider lifecycle managed by ProviderWidget.owned');
    expect(providerElement.lazyProviderInstance, isNull);
  });

  testWidgets('MyProvider lazy create', (tester) async {
    await tester.pumpWidget(ProviderWidget.owned(provider: (ctx) => MyProvider(), child: const SizedBox()));
    expect(tester.lazyProviderInstance, isNull);
    Provider.read<MyProvider>(tester.element(find.byType(SizedBox)));
    expect(tester.lazyProviderInstance, isNotNull);
  });

  testWidgets('MyProvider selectAspect', (tester) async {
    await tester.pumpWidget(
      ProviderWidget.owned(
        provider: (ctx) => MyProvider2(),
        child: Column(
          children: [
            Builder(
              builder: (context) => Align(key: ValueKey(100 + Provider.selectAspect<MyProvider2>(context, 'a').state)),
            ),
            Builder(
              builder: (context) => Align(key: ValueKey(10 + Provider.selectAspect<MyProvider2>(context, 'b').state)),
            ),
            Builder(
              builder: (context) => Align(key: ValueKey(1000 + Provider.watch<MyProvider2>(context).state)),
            )
          ],
        ),
      ),
    );

    Provider.read<MyProvider2>(tester.element(find.byType(Column))).notifyAspectListeners('a');
    await tester.pump();
    expect(find.byKey(const ValueKey(101)), findsOneWidget);
    expect(find.byKey(const ValueKey(10)), findsOneWidget);
    expect(find.byKey(const ValueKey(1001)), findsOneWidget);
    Provider.read<MyProvider2>(tester.element(find.byType(Column))).notifyAspectListeners('b');
    await tester.pump();
    expect(find.byKey(const ValueKey(101)), findsOneWidget);
    expect(find.byKey(const ValueKey(12)), findsOneWidget);
    expect(find.byKey(const ValueKey(1002)), findsOneWidget);

    Provider.read<MyProvider2>(tester.element(find.byType(Column))).notifyListeners();
    await tester.pump();
    expect(find.byKey(const ValueKey(101)), findsOneWidget);
    expect(find.byKey(const ValueKey(12)), findsOneWidget);
    expect(find.byKey(const ValueKey(1003)), findsOneWidget);
  });
}

extension GetProviderLazyProviderInstance on WidgetTester {
  Provider? get lazyProviderInstance => providerElement.lazyProviderInstance;

  dynamic get providerElement {
    final dynamic providerElement = element(find.bySubtype<ProviderWidget>());
    expect(providerElement, isNotNull);
    expect(providerElement, isA<InheritedElement>());
    expect(providerElement.runtimeType.toString(), contains('_ProviderElement'));
    return providerElement;
  }
}

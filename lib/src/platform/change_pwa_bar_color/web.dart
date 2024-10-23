import 'dart:ui';
import 'dart:html';

void changePWABarColorTo(Color color) {
  document
      .querySelector('meta[name="theme_color"]')
      ?.setAttribute('content', '#${color.value.toRadixString(16).substring(2)}');
}

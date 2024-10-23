library platform;

export 'src/platform/device_name/stub.dart'
if (dart.library.js_util) 'src/platform/device_name/web.dart'
if (dart.library.io) 'src/platform/device_name/mobile.dart';

export 'src/platform/change_pwa_bar_color/stub.dart'
if (dart.library.js_util) 'src/platform/change_pwa_bar_color/web.dart';

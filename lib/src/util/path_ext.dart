import 'package:path/path.dart';

extension GetUrlEtxExtension on String {
  String get urlFileExt {
    if (contains('?')) {
      final url = this.split('?').first;
      return extension(url);
    }
    return extension(this);
  }

  String get url2filename {
    final now = DateTime.now();
    return 'monica_image_${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}$urlFileExt';
  }
}

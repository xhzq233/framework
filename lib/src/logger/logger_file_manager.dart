import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LoggerFileManager {
  static const _kLoggerFileName = 'monica.log';
  static const _kLoggerFileSizeLimitByte = 5 * 1024 * 1024; // 5MB

  static Future<File> getLoggerFile(bool forReport) async {
    final Directory tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/$_kLoggerFileName');
    bool exist = await file.exists();
    if (!exist) {
      await file.create(recursive: true);
      return file;
    }
    if (!forReport) {
      await _checkFileLimit(file);
    }
    return file;
  }

  static Future<void> _checkFileLimit(File file) async {
    try {
      FileStat stat = await file.stat();
      if (stat.size > _kLoggerFileSizeLimitByte) {
        await file.delete();
        await file.create(recursive: true);
        return;
      }
    } catch (e) {
      // ignore
    }
  }
}

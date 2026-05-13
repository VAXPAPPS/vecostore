import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../domain/models/store_item.dart';

class InstallRepository {
  /// تحميل وتثبيت أي عنصر من المتجر
  Future<void> downloadAndInstall({
    required StoreItem item,
    required UpdateInfo updateInfo,
    required void Function(double progress) onProgress,
    required void Function() onSuccess,
    required void Function(String error) onError,
  }) async {
    try {
      // 1. تحميل الملف إلى /tmp
      final tempDir = await getTemporaryDirectory();
      final fileName = updateInfo.url.split('/').last.split('?').first;
      final tempPath = '${tempDir.path}/$fileName';

      await _downloadFile(updateInfo.url, tempPath, onProgress);

      // 2. تثبيت بحسب النوع
      if (item.type == StoreItemType.app) {
        await _installDeb(tempPath);
      } else {
        final installDir = _resolveInstallPath(item.type, updateInfo.installPath);
        await _extractTarGz(tempPath, installDir);
      }

      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }

  /// تحميل ملف مع تتبع التقدم
  Future<void> _downloadFile(
    String url,
    String savePath,
    void Function(double) onProgress,
  ) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      final total = response.contentLength ?? 0;
      int received = 0;

      final sink = File(savePath).openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress(received / total);
      }
      await sink.close();
    } finally {
      client.close();
    }
  }

  /// تثبيت .deb عبر pkexec (يطلب كلمة مرور النظام تلقائياً)
  Future<void> _installDeb(String debPath) async {
    final result = await Process.run('pkexec', ['dpkg', '-i', debPath]);
    if (result.exitCode != 0) {
      throw Exception('Installation failed:\n${result.stderr}');
    }
  }

  /// فك ضغط tar.gz إلى المجلد المحدد
  Future<void> _extractTarGz(String tarPath, String installDir) async {
    await Directory(installDir).create(recursive: true);
    final result = await Process.run('tar', ['-xzf', tarPath, '-C', installDir]);
    if (result.exitCode != 0) {
      throw Exception('Extraction failed:\n${result.stderr}');
    }
  }

  /// تحديد مسار التثبيت بحسب نوع العنصر
  String _resolveInstallPath(StoreItemType type, String? customPath) {
    final home = Platform.environment['HOME'] ?? '';
    if (customPath != null && customPath.isNotEmpty) {
      return customPath.replaceFirst('~', home);
    }
    final sub = switch (type) {
      StoreItemType.theme => 'themes',
      StoreItemType.plugin => 'plugins',
      StoreItemType.widget_ => 'widgets',
      _ => 'misc',
    };
    return '$home/.config/aether/$sub';
  }

  /// التحقق من الإصدار المثبّت عبر dpkg
  Future<String?> getInstalledVersion(String package) async {
    try {
      final result = await Process.run('dpkg', ['-s', package]);
      if (result.exitCode != 0) return null;
      for (final line in result.stdout.toString().split('\n')) {
        if (line.startsWith('Version:')) {
          return line.split(':').last.trim();
        }
      }
    } catch (_) {}
    return null;
  }

  /// التحقق من وجود ملف مثبّت في ~/.config/aether
  bool isAetherItemInstalled(StoreItemType type, String name) {
    final home = Platform.environment['HOME'] ?? '';
    final sub = switch (type) {
      StoreItemType.theme => 'themes',
      StoreItemType.plugin => 'plugins',
      StoreItemType.widget_ => 'widgets',
      _ => 'misc',
    };
    return Directory('$home/.config/aether/$sub/$name').existsSync();
  }
}

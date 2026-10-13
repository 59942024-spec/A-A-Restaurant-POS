import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String _fileName = 'serveease_data.json';

  // Resolved by init(). Falls back to a relative path when unavailable.
  static File? _file;

  /// Resolves a real writable directory. Call before runApp.
  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _file = File('${dir.path}${Platform.pathSeparator}$_fileName');
    } catch (e) {
      // path_provider throws MissingPluginException under `flutter test` and
      // on platforms without an implementation. The relative path keeps
      // desktop and tests working.
      debugPrint('StorageService init fallback: $e');
      _file = File(_fileName);
    }
  }

  static File get _target => _file ??= File(_fileName);

  /// Save application state to local storage file
  static Future<void> saveData(Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      await _target.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('StorageService saveData error: $e');
    }
  }

  /// Load application state from local storage file
  static Future<Map<String, dynamic>?> loadData() async {
    if (kIsWeb) return null;
    try {
      final file = _target;
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          return jsonDecode(content) as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('StorageService loadData error: $e');
    }
    return null;
  }

  /// Clear storage if needed
  static Future<void> clearData() async {
    if (kIsWeb) return;
    try {
      final file = _target;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('StorageService clearData error: $e');
    }
  }
}

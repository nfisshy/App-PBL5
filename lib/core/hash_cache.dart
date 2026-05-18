// hash_cache.dart  
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HashCache {
  static const _key = 'photo_hash_cache_v1';
  static Map<String, int>? _cache;

  static Future<Map<String, int>> load() async {
    if (_cache != null) return _cache!;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      _cache = {};
      return _cache!;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _cache = decoded.map((k, v) => MapEntry(k, v as int));
    return _cache!;
  }

  static Future<void> save(Map<String, int> data) async {
    _cache = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<void> invalidate(List<String> ids) async {
    final cache = await load();
    for (final id in ids) cache.remove(id);
    await save(cache);
  }
}
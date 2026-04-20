import '../core/i_local_preferences.dart';

class FakeLocalPreferences implements ILocalPreferences {
  final Map<String, dynamic> _storage = {};

  @override
  Future<String?> getString(String key) async => _storage[key] as String?;

  @override
  Future<void> setString(String key, String value) async => _storage[key] = value;

  @override
  Future<int?> getInt(String key) async => _storage[key] as int?;

  @override
  Future<void> setInt(String key, int value) async => _storage[key] = value;

  @override
  Future<double?> getDouble(String key) async => _storage[key] as double?;

  @override
  Future<void> setDouble(String key, double value) async => _storage[key] = value;

  @override
  Future<bool?> getBool(String key) async => _storage[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async => _storage[key] = value;

  @override
  Future<List<String>?> getStringList(String key) async => _storage[key] as List<String>?;

  @override
  Future<void> setStringList(String key, List<String> value) async => _storage[key] = value;

  @override
  Future<void> remove(String key) async => _storage.remove(key);

  @override
  Future<void> clear() async => _storage.clear();

  void injectToken(String token) {
    _storage['auth_token'] = token;
  }
}
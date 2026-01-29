import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/core/storage/key_value_local_storage.dart';
import 'package:todo_app/core/storage/local_storage_exception.dart';

class SharedPrefStorage implements KeyValueLocalStorage {
  const SharedPrefStorage({required SharedPreferencesAsync sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPreferencesAsync _sharedPreferences;

  @override
  Future<bool> hasKey(String key) async {
    return await _sharedPreferences.containsKey(key);
  }

  @override
  Future<void> put({required String key, required String value}) async {
    await _sharedPreferences.setString(key, value);
  }

  @override
  Future<String> get(String key) async {
    final value = await _sharedPreferences.getString(key);
    if (value != null) {
      return value;
    } else {
      throw LocalStorageException(
        'No value found for key: $key',
        StackTrace.current,
      );
    }
  }

  @override
  Future<void> delete(Set<String> keys) async {
    if (keys.isEmpty) return;
    for (final String key in keys) {
      await _sharedPreferences.remove(key);
    }
  }

  @override
  Future<void> clear({Set<String>? allowList}) async {
    if (allowList != null && allowList.isNotEmpty) {
      final storageDataPreservedList = <String, String>{};
      for (final String key in allowList) {
        if (await hasKey(key)) {
          final data = await get(key);
          storageDataPreservedList[key] = data;
        } else {
          continue;
        }
      }

      await _sharedPreferences.clear();

      for (final String key in storageDataPreservedList.keys) {
        await put(key: key, value: storageDataPreservedList[key]!);
      }
    } else {
      await _sharedPreferences.clear();
    }
  }
}

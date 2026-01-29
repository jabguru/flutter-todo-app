import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_app/core/storage/key_value_local_storage.dart';
import 'package:todo_app/core/storage/local_storage_exception.dart';

class SecureLocalStorage implements KeyValueLocalStorage {
  const SecureLocalStorage({required FlutterSecureStorage storage})
    : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  Future<bool> hasKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> put({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String> get(String key) async {
    final value = await _storage.read(key: key);
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

    for (final key in keys) {
      try {
        await _storage.delete(key: key);
      } on PlatformException catch (e) {
        throw LocalStorageException('''
      An error occurred while deleting the value for a key
       Key: $key
       Error: $e
       ''', StackTrace.current);
      }
    }
  }

  @override
  Future<void> clear({Set<String>? allowList}) async {
    try {
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

        await _storage.deleteAll();
        for (final String key in storageDataPreservedList.keys) {
          await put(key: key, value: storageDataPreservedList[key]!);
        }
      } else {
        await _storage.deleteAll();
      }
    } on PlatformException catch (e) {
      throw LocalStorageException(
        'An error occurred while deleting all values. Error: $e',
        StackTrace.current,
      );
    }
  }
}

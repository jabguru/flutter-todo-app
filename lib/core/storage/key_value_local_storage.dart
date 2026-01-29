/// An abstraction over a key-value local storage.
abstract class KeyValueLocalStorage {
  /// Checks if a key is available.
  Future<bool> hasKey(String key);

  /// Puts a new [value] to the [key].
  Future<void> put({required String key, required String value});

  /// Throws [LocalStorageException] if no value is found for the given [key].
  Future<String> get(String key);

  /// Deletes keys in the [keys] set.
  /// Can throw [LocalStorageException].
  Future<void> delete(Set<String> keys);

  /// Empties the database and deletes everything, except keys in the [allowList].
  Future<void> clear({Set<String>? allowList});
}

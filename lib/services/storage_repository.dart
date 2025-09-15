import 'package:hive/hive.dart';

/// Abstract repository interface for storage operations
abstract class StorageRepository<T> {
  Future<void> save(String key, T data);
  Future<T?> load(String key);
  Future<void> delete(String key);
  Future<List<T>> loadAll();
  Future<void> clear();
  Future<bool> exists(String key);
}

/// Generic Hive-based storage repository implementation
class HiveStorageRepository<T extends HiveObject> implements StorageRepository<T> {
  final String boxName;
  Box<T>? _box;

  HiveStorageRepository(this.boxName);

  /// Initialize the Hive box
  Future<Box<T>> get box async {
    _box ??= await Hive.openBox<T>(boxName);
    return _box!;
  }

  @override
  Future<void> save(String key, T data) async {
    final hiveBox = await box;
    await hiveBox.put(key, data);
  }

  @override
  Future<T?> load(String key) async {
    final hiveBox = await box;
    return hiveBox.get(key);
  }

  @override
  Future<void> delete(String key) async {
    final hiveBox = await box;
    await hiveBox.delete(key);
  }

  @override
  Future<List<T>> loadAll() async {
    final hiveBox = await box;
    return hiveBox.values.toList();
  }

  @override
  Future<void> clear() async {
    final hiveBox = await box;
    await hiveBox.clear();
  }

  @override
  Future<bool> exists(String key) async {
    final hiveBox = await box;
    return hiveBox.containsKey(key);
  }

  /// Get all keys in the box
  Future<List<String>> getAllKeys() async {
    final hiveBox = await box;
    return hiveBox.keys.cast<String>().toList();
  }

  /// Get the number of items in the box
  Future<int> count() async {
    final hiveBox = await box;
    return hiveBox.length;
  }

  /// Save multiple items at once
  Future<void> saveAll(Map<String, T> items) async {
    final hiveBox = await box;
    await hiveBox.putAll(items);
  }

  /// Load multiple items by keys
  Future<Map<String, T?>> loadMultiple(List<String> keys) async {
    final hiveBox = await box;
    final result = <String, T?>{};
    for (final key in keys) {
      result[key] = hiveBox.get(key);
    }
    return result;
  }

  /// Delete multiple items by keys
  Future<void> deleteMultiple(List<String> keys) async {
    final hiveBox = await box;
    await hiveBox.deleteAll(keys);
  }

  /// Close the box (call this when disposing)
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }
}
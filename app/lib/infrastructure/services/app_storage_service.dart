import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../service/storage_service.dart';

class AppStorageService extends StorageService {
  final FlutterSecureStorage _localStorage;

  AppStorageService([
    this._localStorage = const FlutterSecureStorage(
      //     aOptions: AndroidOptions(
      //   encryptedSharedPreferences: true,
      // )
    ),
  ]);

  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => _localStorage.containsKey(
    key: key,
    iOptions: iOptions,
    aOptions: aOptions,
    lOptions: lOptions,
    webOptions: webOptions,
    mOptions: mOptions,
    wOptions: wOptions,
  );

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => _localStorage.delete(
    key: key,
    iOptions: iOptions,
    aOptions: aOptions,
    lOptions: lOptions,
    webOptions: webOptions,
    mOptions: mOptions,
    wOptions: wOptions,
  );

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => _localStorage.deleteAll(
    iOptions: iOptions,
    aOptions: aOptions,
    lOptions: lOptions,
    webOptions: webOptions,
    mOptions: mOptions,
    wOptions: wOptions,
  );

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => _localStorage.read(
    key: key,
    iOptions: iOptions,
    aOptions: aOptions,
    lOptions: lOptions,
    webOptions: webOptions,
    mOptions: mOptions,
    wOptions: wOptions,
  );

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => _localStorage.write(
    key: key,
    value: value,
    iOptions: iOptions,
    aOptions: aOptions,
    lOptions: lOptions,
    webOptions: webOptions,
    mOptions: mOptions,
    wOptions: wOptions,
  );
}

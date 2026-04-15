import '../../service/storage_service.dart';
import '../../service/wallet_service.dart';

const _kWalletKey = 'solana_wallet_pubkey';

class AppWalletService extends WalletService {
  final StorageService _storage;

  AppWalletService({required StorageService storage}) : _storage = storage;

  @override
  Future<String?> getWalletPubkey() => _storage.read(key: _kWalletKey);

  @override
  Future<void> saveWalletPubkey(String pubkey) =>
      _storage.write(key: _kWalletKey, value: pubkey);

  @override
  Future<void> clearWalletPubkey() =>
      _storage.write(key: _kWalletKey, value: null);
}

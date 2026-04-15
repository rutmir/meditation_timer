abstract class WalletService {
  /// Returns the stored Solana wallet public key, or null if not set.
  Future<String?> getWalletPubkey();

  /// Persists the wallet public key.
  Future<void> saveWalletPubkey(String pubkey);

  /// Removes the stored wallet public key.
  Future<void> clearWalletPubkey();
}

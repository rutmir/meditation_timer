import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ai_logic.dart';
import '../entities/app_style.dart';
import '../infrastructure/l10n/generated/app_localizations.dart';
import '../service/theme_service.dart';
import 'common/constants.dart';
import 'common/go_back_button.dart';

/// Regular expression for a valid Solana base58 public key (32–44 chars).
final _pubkeyRegex = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');

class WalletConnectView {
  final AiLogic logic;
  final ThemeService theme;
  final VoidCallback onSaved;
  final VoidCallback onBack;

  final TextEditingController _controller = TextEditingController();
  String? _validationError;
  bool _isSaving = false;

  WalletConnectView({
    required this.logic,
    required this.theme,
    required this.onSaved,
    required this.onBack,
  });

  bool _isValidPubkey(String value) => _pubkeyRegex.hasMatch(value.trim());

  Future<void> _onSave(BuildContext context, StateSetter setState) async {
    final pubkey = _controller.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (!_isValidPubkey(pubkey)) {
      setState(() => _validationError = l10n.wallet_invalid_pubkey);
      return;
    }

    setState(() {
      _validationError = null;
      _isSaving = true;
    });

    await logic.saveWallet(pubkey);

    setState(() => _isSaving = false);
    onSaved();
  }

  Future<void> _onDisconnect(StateSetter setState) async {
    await logic.clearWallet();
    _controller.clear();
    setState(() {});
    onSaved();
  }

  Future<void> _openJupiter() async {
    final mint = dotenv.env['ROEX_MINT'] ?? '';
    final path = mint.isNotEmpty ? 'swap/SOL-$mint' : 'swap';
    final uri = Uri.parse('https://jup.ag/$path');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildRequiredRoexBanner(AppLocalizations l10n, AppStyle style) {
    final roex = logic.requiredRoex;
    final price = logic.priceUsd;

    if (roex <= 0) return const SizedBox.shrink();

    final roexFormatted = roex >= 1000
        ? '${(roex / 1000).toStringAsFixed(1)}K'
        : roex.toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.inversePrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.inversePrimary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.wallet_required_title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: kFormFontSize,
              color: style.inversePrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.wallet_required_amount(roexFormatted),
            style: TextStyle(fontSize: kFormFontSize, color: style.formText),
          ),
          if (price > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.wallet_current_price('\$${price.toStringAsFixed(8)}'),
              style: TextStyle(
                fontSize: kFormFontSize - 2,
                color: style.formTextDisabled,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget getView(BuildContext context, {required EdgeInsets safeArea}) {
    final l10n = AppLocalizations.of(context)!;
    final style = theme.currentAppStyle;

    // Pre-fill with stored pubkey if switching to wallet screen manually.
    if (_controller.text.isEmpty && logic.walletPubkey != null) {
      _controller.text = logic.walletPubkey!;
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(top: safeArea.top, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GoBackButton(themeService: theme, onTap: onBack),
                  Expanded(
                    child: Text(
                      l10n.wallet_title,
                      style: TextStyle(
                        fontSize: kTitleFontSize,
                        color: style.inversePrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // balance spacer to match GoBackButton width
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              _buildRequiredRoexBanner(l10n, style),

              // Current wallet chip
              if (logic.hasWallet) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: style.inversePrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: style.inversePrimary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _abbrev(logic.walletPubkey!),
                          style: TextStyle(
                            fontSize: kFormFontSize,
                            color: style.formText,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, color: style.formTextDisabled,
                            size: 18),
                        tooltip: l10n.wallet_copy_tooltip,
                        onPressed: () => Clipboard.setData(
                          ClipboardData(text: logic.walletPubkey!),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pubkey input
              TextField(
                controller: _controller,
                style: TextStyle(
                  fontSize: kFormFontSize,
                  color: style.formText,
                ),
                decoration: InputDecoration(
                  labelText: l10n.wallet_pubkey_label,
                  labelStyle: TextStyle(color: style.formTextDisabled),
                  hintText: l10n.wallet_pubkey_hint,
                  hintStyle: TextStyle(color: style.formTextDisabled),
                  errorText: _validationError,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: style.inversePrimary.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: style.inversePrimary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: style.formTextDisabled),
                          onPressed: () => setState(() => _controller.clear()),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() => _validationError = null),
                autocorrect: false,
                enableSuggestions: false,
              ),
              const SizedBox(height: 16),

              // Save button
              ElevatedButton(
                onPressed:
                    _isSaving ? null : () => _onSave(context, setState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: style.inversePrimary,
                  foregroundColor: style.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: style.primary,
                        ),
                      )
                    : Text(
                        l10n.wallet_save,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
              const SizedBox(height: 12),

              // Disconnect button (shown only when a wallet is connected)
              if (logic.hasWallet)
                OutlinedButton(
                  onPressed: () => _onDisconnect(setState),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: style.inversePrimary,
                    side: BorderSide(
                      color: style.inversePrimary.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.wallet_disconnect),
                ),

              const Spacer(),

              // Buy ROEX on Jupiter
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: OutlinedButton.icon(
                  onPressed: _openJupiter,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.wallet_buy_roex),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: style.inversePrimary,
                    side: BorderSide(
                      color: style.inversePrimary.withOpacity(0.4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Abbreviates a long pubkey: first 6 … last 6 characters.
  String _abbrev(String pubkey) {
    if (pubkey.length <= 16) return pubkey;
    return '${pubkey.substring(0, 6)}…${pubkey.substring(pubkey.length - 6)}';
  }
}

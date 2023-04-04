import 'package:kadena_dart_sdk/kadena_dart_sdk.dart';
import 'package:kadena_dart_sdk/models/walletconnect_models.dart';

enum WalletProviderType {
  walletConnect,
}

abstract class IWalletProvider {
  /// Initialize the wallet provider with the given information.
  /// This is mostly used when the wallet provider is [WalletConnectProvider].
  Future<void> init({
    required String name,
    required String description,
    required String url,
    required String icon,
  });

  /// Connect to the wallet provider. Returns the list of public keys or accounts
  /// that are available to the user.
  Future<List<String>> connect({dynamic info});

  /// Disconnect from the wallet provider.
  Future<void> disconnect({dynamic reason});

  /// Used with the
  Future<GetAccountsResponse> getAccounts({
    required GetAccountsRequest request,
    dynamic info,
  });
  Future<QuicksignResult> quicksign({
    required QuicksignRequest request,
    dynamic info,
  });
}

import 'package:flutter/material.dart';
import 'package:kadena_dart_sdk/kadena_dart_sdk.dart';
import 'package:pact_certification_site/models/pact_transaction_response.dart';
import 'package:pact_certification_site/services/kadena/wallets/i_wallet_provider.dart';

abstract class IKadenaService {
  /// Initializes the kadena service with the given node url.
  /// This will initialize the pact api and fetch the network id of the node.
  /// Example [nodeUrl] -> https://api.chainweb.com
  Future<void> init({
    required String nodeUrl,
  });

  /// The pact api used to interact with the kadena network
  abstract IPactApiV1 pactApi;

  /// The URL of the node the pact api will send requests to.
  /// When you set this, it will update the pactApi with the new url.
  /// Example [nodeUrl] -> https://api.chainweb.com
  abstract ValueNotifier<String> nodeUrl;

  /// Returns the network id of the connected node.
  /// Generally retrieved from the pact api.
  // String getNetworkId();

  /// The list of transactions that have been sent to and received from the pact api.
  abstract ValueNotifier<List<PactTransactionResponse>> transactions;

  /// The wallet that is currently connected to the kadena service.
  /// This will be null if no wallet is connected.
  /// Options: [WalletConnectProvider]
  abstract IWalletProvider? walletProvider;

  /// The account that was retrieved from the connected wallet.
  abstract ValueNotifier<String?> account;

  /// Connects to a wallet of the given type.
  Future<void> connect({
    required WalletProviderType providerType,
  });

  /// Disconnects from the currently connected wallet.
  /// This will also clear the account.
  /// This will not clear the transactions, nor node url.
  ///
  /// If the wallet is not connected, this will do nothing.
  Future<void> disconnect();

  /// Signs a QuicksignRequest with the connected wallet.
  /// Tests each transaction locally using [PactApiV1.local] and if the local call succeeds,
  /// then it commits the [PactCommand] to the blockchain using [PactApiV1.send].
  Future<List<PactTransactionResponse>> localAndSend({
    required QuicksignRequest request,
  });
}

import 'package:flutter/foundation.dart';
import 'package:kadena_dart_sdk/kadena_dart_sdk.dart';
import 'package:kadena_dart_sdk/models/walletconnect_models.dart';
import 'package:pact_certification_site/models/pact_transaction_response.dart';
import 'package:pact_certification_site/services/kadena/i_kadena_service.dart';
import 'package:pact_certification_site/services/kadena/wallets/i_wallet_provider.dart';
import 'package:pact_certification_site/services/kadena/wallets/wallet_connect_provider.dart';

// Import other necessary libraries or files.

class KadenaService implements IKadenaService {
  @override
  IPactApiV1 pactApi = PactApiV1();

  @override
  ValueNotifier<String> nodeUrl = ValueNotifier<String>('');

  @override
  ValueNotifier<String?> account = ValueNotifier<String?>(null);

  @override
  ValueNotifier<List<PactTransactionResponse>> transactions =
      ValueNotifier<List<PactTransactionResponse>>([]);

  @override
  IWalletProvider? walletProvider;

  @override
  Future<void> init({required String nodeUrl}) async {
    // Implement the init method logic here.
    await pactApi.setNodeUrl(nodeUrl: nodeUrl);
  }

  @override
  Future<void> connect({required WalletProviderType providerType}) async {
    // Depending on the type provided, create a new instance of the wallet provider
    // and connect to it.
    walletProvider = WalletConnectProvider();

    await walletProvider!.connect();

    // If the provider is WalletConnect, get the accounts
    if (providerType == WalletProviderType.walletConnect) {
      final accounts = await walletProvider!.getAccounts(
        request: GetAccountsRequest(accounts: [
          AccountRequest(account: account.value!),
        ]),
      );
      account.value = accounts.accounts.first.account;
    }
  }

  @override
  Future<void> disconnect() async {
    await walletProvider!.disconnect();
  }

  @override
  Future<List<PactTransactionResponse>> localAndSend({
    required QuicksignRequest request,
  }) async {
    final List<PactTransactionResponse> responses = [];

    final QuicksignResult signed = await walletProvider!.quicksign(
      request: request,
    );

    if (signed.error != null) {
      throw Exception('Quicksign failed');
    }

    for (final response in signed.responses!) {
      if (response.outcome.result != QuicksignOutcome.success) {
        responses.add(
          PactTransactionResponse(
            message: response.outcome.msg,
          ),
        );
        continue;
      }

      final command = PactCommand(
        cmd: response.commandSigData.cmd,
        hash: response.outcome.hash!,
        sigs: response.commandSigData.sigs
            .map(
              (e) => Signer(
                sig: e.sig,
              ),
            )
            .toList(),
      );
      final localResult = await pactApi.local(
        command: command,
        preflight: true,
      );

      // If this local call failed, add the pact transaction response and go to the next command
      if (localResult.result.status != 'success') {
        responses.add(
          PactTransactionResponse(pactResult: localResult),
        );
        continue;
      }

      // Commit the TX to the blockchain
      final PactSendResponse sendResult = await pactApi.send(
        commands: PactSendRequest(
          cmds: [command],
        ),
      );

      // Add the response to the list of responses
      responses.add(
        PactTransactionResponse(
          requestKey: sendResult.requestKeys.first,
        ),
      );
    }

    return responses;
  }
}

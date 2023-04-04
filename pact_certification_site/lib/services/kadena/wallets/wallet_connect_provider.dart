import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:kadena_dart_sdk/kadena_dart_sdk.dart';
import 'package:kadena_dart_sdk/models/walletconnect_models.dart';
import 'package:pact_certification_site/services/i_alert_service.dart';
import 'package:pact_certification_site/services/kadena/wallets/i_wallet_provider.dart';
import 'package:walletconnect_flutter_v2/apis/core/store/i_generic_store.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/i_sessions.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/i_sign_client.dart';
import 'package:walletconnect_flutter_v2/apis/utils/namespace_utils.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectProvider implements IWalletProvider, Disposable {
  late ISignClient _signClient;

  static const String projectId = String.fromEnvironment('projectId');

  WalletConnectProvider();

  @override
  Future<void> init({
    required String name,
    required String description,
    required String url,
    required String icon,
  }) async {
    ICore core = Core(
      projectId: projectId,
    );
    _signClient = SignClient(
      core: core,
      metadata: PairingMetadata(
        name: name,
        description: description,
        url: url,
        icons: [icon],
      ),
    );

    await _signClient.init();
  }

  @override
  Future<void> onDispose() async {}

  @override
  Future<List<String>> connect({dynamic info}) async {
    if (info is Map<String, dynamic>) {
      final ConnectResponse response = await _signClient.connect(
        requiredNamespaces: info['requiredNamespaces'],
        optionalNamespaces: info['optionalNamespaces'],
        sessionProperties: info['sessionProperties'],
        pairingTopic: info['pairingTopic'],
      );

      if (response.uri != null) {
        GetIt.I<IAlertService>().showQrCode(
          title: 'Scan QR Code',
          message: 'Scan this QR code to connect to your wallet',
          qrCode: response.uri!.toString(),
        );
      }

      SessionData session = await response.session.future;

      return session.namespaces.values.first.accounts
          .map(
            (e) => NamespaceUtils.getAccount(
              e,
            ),
          )
          .toList();
    } else {
      throw ArgumentError('Invalid connection info. Expected a Uri instance.');
    }
  }

  @override
  Future<void> disconnect({dynamic reason}) async {
    await _signClient.disconnect(
      topic: _signClient.pairings.getAll().first.topic,
      reason: WalletConnectError(
        code: -1,
        message: reason.toString(),
      ),
    );
  }

  @override
  Future<GetAccountsResponse> getAccounts({
    required GetAccountsRequest request,
    dynamic info,
  }) async {
    final activeSessions = _signClient.getActiveSessions();
    if (activeSessions.isNotEmpty) {
      final topic = activeSessions.keys.first;
      return await _signClient.request(
        topic: topic,
        chainId: 'kadena:$info',
        request: SessionRequestParams(
          method: 'kadena_getAccounts_v1',
          params: request,
        ),
      );
    } else {
      throw Exception('No active session available.');
    }
  }

  @override
  Future<QuicksignResult> quicksign({
    required QuicksignRequest request,
    dynamic info,
  }) async {
    final activeSessions = _signClient.getActiveSessions();
    if (activeSessions.isNotEmpty) {
      final topic = activeSessions.keys.first;
      return await _signClient.request(
        topic: topic,
        chainId: 'kadena:$info',
        request: SessionRequestParams(
          method: 'kadena_quicksign_v1',
          params: request,
        ),
      );
    } else {
      throw Exception('No active session available.');
    }
  }
}

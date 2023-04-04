import 'package:flutter/material.dart';
import 'package:kadena_dart_sdk/kadena_dart_sdk.dart';

class PactTransactionResponse {
  final String? message;
  final ValueNotifier<PactResponse?> pactResult;
  final String? requestKey;

  PactTransactionResponse({
    this.message,
    PactResponse? pactResult,
    this.requestKey,
  }) : pactResult = ValueNotifier(pactResult);

  Future<void> getFinishedRequest(
    IPactApiV1 pactApi,
  ) async {
    if (requestKey == null) {
      return;
    }

    pactResult.value = await pactApi.listen(
      request: PactListenRequest(
        listen: requestKey!,
      ),
    );
  }

  @override
  String toString() {
    return 'PactTransactionResponse{pactResult: $pactResult, requestKey: $requestKey}';
  }
}

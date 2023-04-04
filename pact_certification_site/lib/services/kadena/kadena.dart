import 'dart:convert';

import 'package:kadena_dart_sdk/kadena_dart_sdk.dart';
import 'package:kadena_dart_sdk/models/walletconnect_models.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

enum KadenaMethods {
  kadenaQuicksignV1,
  kadenaGetAccountsV1,
}

enum KadenaEvents {
  none,
}

extension KadenaMethodsX on KadenaMethods {
  String? get value => Kadena.methods[this];
}

extension KadenaMethodsStringX on String {
  KadenaMethods? toKadenaMethod() {
    final entries = Kadena.methods.entries.where(
      (element) => element.value == this,
    );
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}

extension KadenaEventsX on KadenaEvents {
  String? get value => Kadena.events[this];
}

extension KadenaEventsStringX on String {
  KadenaEvents? toKadenaEvent() {
    final entries = Kadena.events.entries.where(
      (element) => element.value == this,
    );
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}

class Kadena {
  static final Map<KadenaMethods, String> methods = {
    KadenaMethods.kadenaQuicksignV1: 'kadena_quicksign_v1',
    KadenaMethods.kadenaGetAccountsV1: 'kadena_getAccounts_v1'
  };

  static final Map<KadenaEvents, String> events = {};

  // static Future<dynamic> callMethod({
  //   required Web3App web3App,
  //   required String topic,
  //   required KadenaMethods method,
  //   required String chainId,
  //   required String address,
  // }) {
  //   final String addressActual =
  //       address.startsWith('k**') ? address.substring(3) : address;

  //   switch (method) {
  //     case KadenaMethods.kadenaQuicksignV1:
  //       return kadenaQuicksignV1(
  //         web3App: web3App,
  //         topic: topic,
  //         chainId: chainId,
  //         data: createQuicksignRequest(
  //           cmd: jsonEncode(
  //             createPactCommandPayload(
  //               networkId: chainId.split(':')[1],
  //               sender: 'k:$addressActual',
  //             ).toJson(),
  //           ),
  //         ),
  //       );
  //     case KadenaMethods.kadenaGetAccountsV1:
  //       return kadenaGetAccountsV1(
  //         web3App: web3App,
  //         topic: topic,
  //         chainId: chainId,
  //         data: createGetAccountsRequest(account: '$chainId:$addressActual'),
  //       );
  //   }
  // }
}

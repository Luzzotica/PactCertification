import 'package:flutter/material.dart';

abstract class IAlertService {
  void setBuildContext(BuildContext context);

  Future<void> showQrCode({
    required String title,
    required String message,
    required String qrCode,
  });

  Future<void> showTextToast({required String message});
}

import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pact_certification_site/services/i_alert_service.dart';
import 'package:pact_certification_site/utils/string_constants.dart';
import 'package:pact_certification_site/widgets/custom_button_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AlertServiceImpl implements IAlertService {
  BuildContext context;

  AlertServiceImpl(this.context);

  @override
  void setBuildContext(BuildContext context) {
    this.context = context;
  }

  @override
  Future<void> showQrCode({
    required String title,
    required String message,
    required String qrCode,
  }) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImage(
              data: qrCode,
              size: 200,
              gapless: false,
            ),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
        actions: [
          CustomButtonWidget(
            type: CustomButtonType.primary,
            child: const Text(StringConstants.copyToClipboard),
            onTap: () async {
              await Clipboard.setData(
                ClipboardData(
                  text: qrCode,
                ),
              );
              showTextToast(message: StringConstants.copiedToClipboard);
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Future<void> showTextToast({required String message}) async {
    showPlatformToast(
      child: Text(message),
      context: context,
    );
  }
}

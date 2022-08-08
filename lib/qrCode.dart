import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCode {
    MobileScanner scanQrCode(Function(String encodedString) onSuccess) {
    
      return MobileScanner(
          allowDuplicates: false,
          onDetect: (qrcode, args) {
            if (qrcode.rawValue == null) {
              //TODO: throw
            } else {
              final String state = qrcode.rawValue!;
              onSuccess(state);
            }
          });
  }

  QrImage getQrCode(String encodedString) {
    return QrImage(
      data: encodedString,
      version: QrVersions.auto,
      size: 320,
      gapless: false,
      errorStateBuilder: (cxt, err) {
        return const Center(
          child: Text(
            "Something went wrong... Try again",
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }


}
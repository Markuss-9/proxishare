import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import 'toast.dart';

class ServerQrWidget extends StatelessWidget {
  final String url;
  final String? imageAsset;
  final VoidCallback? onCopy;

  const ServerQrWidget({
    super.key,
    required this.url,
    this.imageAsset,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final webuiURL = "$url/webui";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Server running at:'),
        SelectableText(url, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 50),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: webuiURL));
            showToast(context, 'Webpage link copied to clipboard!');
            onCopy?.call();
          },
          child: SizedBox(
            height: 300,
            width: 300,
            child: PrettyQrView.data(
              data: webuiURL,
              errorCorrectLevel: QrErrorCorrectLevel.H,
              decoration: PrettyQrDecoration(
                background: Colors.transparent,
                shape: const PrettyQrShape.custom(
                  PrettyQrSquaresSymbol(color: Colors.white),
                ),
                image: imageAsset != null
                    ? PrettyQrDecorationImage(image: AssetImage(imageAsset!))
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

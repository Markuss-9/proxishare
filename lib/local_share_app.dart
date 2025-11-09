import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:proxishare/components/toast.dart';
import 'package:proxishare/server/local_server.dart';

class LocalShareApp extends StatefulWidget {
  const LocalShareApp({super.key});
  @override
  State<LocalShareApp> createState() => LocalShareAppState();
}

class LocalShareAppState extends State<LocalShareApp> {
  LocalServer? server;

  @override
  void initState() {
    super.initState();
  }

  Future<void> startServer({int? port}) async {
    LocalServer s = LocalServer(port: port);
    await s.start();
    setState(() {
      server = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (server == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              startServer();
            },
            child: Text("Start the server"),
          ),
        ],
      );
    }

    final LocalServer s = server!;

    if (s.loading) {
      return CircularProgressIndicator();
    }

    final url = s.url!;
    final webuiURL = "$url/webui";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Server running at:'),
        SelectableText(url, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 50),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: webuiURL));
            showToast(context, 'Webpage link copied to clipboard!');
          },
          child: SizedBox(
            height: 300,
            width: 300,
            child: PrettyQrView.data(
              data: webuiURL,
              errorCorrectLevel: QrErrorCorrectLevel.H,
              decoration: const PrettyQrDecoration(
                background: Colors.transparent,
                shape: PrettyQrShape.custom(
                  PrettyQrSquaresSymbol(
                    // color: Colors.red,
                    color: Colors.white,
                  ),
                ),
                image: PrettyQrDecorationImage(
                  image: AssetImage('assets/cervino.png'),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 50),
        TextButton(
          onPressed: () {
            server?.stop();
            setState(() {
              server = null;
            });
          },
          child: Text("Stop the server"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    server?.stop();
    super.dispose();
  }
}

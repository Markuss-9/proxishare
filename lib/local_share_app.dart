import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:proxishare/components/toast.dart';
import 'package:proxishare/server/local_server.dart';

class LocalShareApp extends StatefulWidget {
  const LocalShareApp({super.key});
  @override
  State<LocalShareApp> createState() => _LocalShareAppState();
}

class _LocalShareAppState extends State<LocalShareApp> {
  LocalServer? _server;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startServer({int? port}) async {
    LocalServer server = LocalServer(port: port);
    await server.start();
    setState(() {
      _server = server;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_server == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              _startServer();
            },
            child: Text("Start the server"),
          ),
        ],
      );
    }

    final LocalServer server = _server!;

    if (server.loading) {
      return CircularProgressIndicator();
    }

    final url = server.url!;
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
            _server?.stop();
            setState(() {
              _server = null;
            });
          },
          child: Text("Stop the server"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _server?.stop();
    super.dispose();
  }
}

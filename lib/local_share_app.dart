import 'package:flutter/material.dart';

import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:proxishare/server/local_server.dart';

class LocalShareApp extends StatefulWidget {
  const LocalShareApp({super.key});
  @override
  State<LocalShareApp> createState() => _LocalShareAppState();
}

const port = 8080;

class _LocalShareAppState extends State<LocalShareApp> {
  final LocalServer _server = LocalServer(port: port);
  String? _url;

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    await _server.start();
    setState(() => _url = _server.url);
  }

  @override
  Widget build(BuildContext context) {
    final url = _url;

    if (url == null) {
      return CircularProgressIndicator();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Server running at:'),
        SelectableText(url, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          width: 300,
          child: PrettyQrView.data(
            data: url,
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
      ],
    );
  }

  @override
  void dispose() {
    _server.stop();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:proxishare/components/toast.dart';
import 'package:proxishare/server/local_server.dart';
import 'package:proxishare/server/events.dart';
import 'package:proxishare/components/upload_dialog.dart';
import 'package:proxishare/logger.dart';

const commonPorts = [8080, 5173, 3000];

class LocalShareApp extends StatefulWidget {
  const LocalShareApp({super.key});
  @override
  State<LocalShareApp> createState() => LocalShareAppState();
}

class LocalShareAppState extends State<LocalShareApp> {
  LocalServer? server;

  final TextEditingController portController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void handleServerEvents(event) {
    logger.info("SERVER EVENT: $event");
    if (event is UploadMediaEvent) {
      showUploadDialog(context, event.files);
    } else {
      logger.warn("Unhandled server event: $event");
    }
  }

  Future<void> startServer({int? port}) async {
    try {
      LocalServer s = LocalServer(port: port);

      await s.getBestIPAddress();

      await s.start();
      setState(() {
        server = s;
      });

      s.events.listen(handleServerEvents);
    } catch (e, st) {
      logger.error('Failed to start server: $e', error: e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (server == null) {
      return ValueListenableBuilder(
        valueListenable: portController,
        builder: (_, __, ___) {
          final text = portController.text;
          int? textPort = int.tryParse(text);
          bool isAutomatic = text.isEmpty;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ChoiceChip(
                      label: const Text('Automatic'),
                      selected: isAutomatic,
                      onSelected: (sel) {
                        if (sel) {
                          setState(() {
                            portController.clear();
                          });
                        }
                      },
                    ),
                  ),
                  ...commonPorts.map(
                    (p) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ChoiceChip(
                        label: Text('$p'),
                        selected: textPort == p,
                        onSelected: (sel) {
                          if (sel) {
                            setState(() {
                              portController.text = p.toString();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: portController,
                  keyboardType: TextInputType.numberWithOptions(
                    signed: false,
                    decimal: false,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Port (optional)',
                    helperText: 'Leave blank for automatic port selection',
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final text = portController.text;
                  final port = (text.isEmpty) ? null : int.tryParse(text);
                  await startServer(
                    port: (port != null && port > 0) ? port : null,
                  );
                },
                child: const Text("Start the server"),
              ),
              TextButton(
                onPressed: () async {
                  final path = await LogService.exportLogs();
                  if (path != null) {
                    showToast(context, 'Logs exported to:\n$path');
                  } else {
                    showToast(
                      context,
                      'Failed to export logs. Check storage permissions.',
                    );
                  }
                },
                child: const Text('Export logs'),
              ),
            ],
          );
        },
      );
    }

    final LocalServer s = server!;

    if (s.loading) {
      return const CircularProgressIndicator();
    }

    final url = s.url!;
    final webuiURL = "$url/webui";

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Server running at:'),
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
              portController.clear();
            });
          },
          child: const Text("Stop the server"),
        ),
        TextButton(
          onPressed: () async {
            final path = await LogService.exportLogs();
            if (path != null) {
              showToast(context, 'Logs exported to:\n$path');
            } else {
              showToast(
                context,
                'Failed to export logs. Check storage permissions.',
              );
            }
          },
          child: const Text('Export logs'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    server?.stop();
    portController.dispose();
    super.dispose();
  }
}

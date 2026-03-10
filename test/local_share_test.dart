import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proxishare/local_share_app.dart';

import 'package:proxishare/server/local_server.dart';

import 'package:proxishare/components/start_stop_button.dart';
import 'package:proxishare/components/port_selector_widget.dart';
import 'package:proxishare/components/received_file.dart';
import 'package:proxishare/components/received_files_grid.dart';
import 'package:proxishare/views/server_not_running.dart';

class MockServer extends LocalServer {
  MockServer({int? port});

  @override
  Future<void> start() async {
    await Future.delayed(Duration(milliseconds: 100));
    loading = false;
    url = 'http://localhost:8080';
  }
}

class TestLocalShareApp extends LocalShareApp {
  const TestLocalShareApp({super.key});
  @override
  State<LocalShareApp> createState() => _TestLocalShareAppState();
}

class _TestLocalShareAppState extends LocalShareAppState {
  @override
  Future<void> startServer({int? port}) async {
    final s = MockServer(port: port);
    await s.start();
    setState(() {
      server = s;
    });
  }
}

class TestLocalShareAppRunning extends LocalShareApp {
  const TestLocalShareAppRunning({super.key});
  @override
  State<LocalShareApp> createState() => _TestLocalShareAppStateRunning();
}

class _TestLocalShareAppStateRunning extends LocalShareAppState {
  @override
  void initState() {
    super.initState();
    var s = MockServer();
    s.loading = false;
    s.url = "http://localhost:8080";
    server = s;
  }
}

class TestLocalShareAppLoading extends LocalShareApp {
  const TestLocalShareAppLoading({super.key});
  @override
  State<LocalShareApp> createState() => _TestLocalShareAppStateLoading();
}

class _TestLocalShareAppStateLoading extends LocalShareAppState {
  @override
  void initState() {
    super.initState();
    var s = MockServer();
    s.loading = true;
    server = s;
  }
}

void main() {
  group('StartStopButton', () {
    testWidgets('shows "Start the server" when not running', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartStopButton(isServerRunning: false, onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Start the server'), findsOneWidget);
      expect(find.text('Stop the server'), findsNothing);
    });

    testWidgets('shows "Stop the server" when running', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartStopButton(isServerRunning: true, onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Stop the server'), findsOneWidget);
      expect(find.text('Start the server'), findsNothing);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartStopButton(
              isServerRunning: false,
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Start the server'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool wasPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartStopButton(
              isServerRunning: false,
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start the server'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });
  });

  group('PortSelectorWidget', () {
    testWidgets('shows Automatic chip selected by default', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PortSelectorWidget(portController: controller)),
        ),
      );

      expect(find.text('Automatic'), findsOneWidget);
      expect(find.text('8080'), findsOneWidget);
      expect(find.text('5173'), findsOneWidget);
      expect(find.text('3000'), findsOneWidget);
    });

    testWidgets('selecting port chip updates controller', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PortSelectorWidget(portController: controller)),
        ),
      );

      await tester.tap(find.text('8080'));
      await tester.pump();

      expect(controller.text, '8080');
    });

    testWidgets('selecting Automatic clears controller', (tester) async {
      final controller = TextEditingController(text: '8080');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PortSelectorWidget(portController: controller)),
        ),
      );

      await tester.tap(find.text('Automatic'));
      await tester.pump();

      expect(controller.text, '');
    });

    testWidgets('typing in text field updates controller', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PortSelectorWidget(portController: controller)),
        ),
      );

      await tester.enterText(find.byType(TextField), '9000');
      await tester.pump();

      expect(controller.text, '9000');
    });

    testWidgets('text field only accepts digits', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PortSelectorWidget(portController: controller)),
        ),
      );

      await tester.enterText(find.byType(TextField), 'abc123');
      await tester.pump();

      expect(controller.text, '123');
    });
  });

  group('ReceivedFile', () {
    test('formattedSize returns correct format for bytes', () {
      final file = ReceivedFile(
        filename: 'test.txt',
        path: '/path',
        mime: 'text/plain',
        size: 500,
        isMedia: false,
      );
      expect(file.formattedSize, '500 B');
    });

    test('formattedSize returns correct format for KB', () {
      final file = ReceivedFile(
        filename: 'test.txt',
        path: '/path',
        mime: 'text/plain',
        size: 2048,
        isMedia: false,
      );
      expect(file.formattedSize, '2.0 KB');
    });

    test('formattedSize returns correct format for MB', () {
      final file = ReceivedFile(
        filename: 'test.txt',
        path: '/path',
        mime: 'text/plain',
        size: 5 * 1024 * 1024,
        isMedia: false,
      );
      expect(file.formattedSize, '5.0 MB');
    });

    test('formattedSize returns correct format for GB', () {
      final file = ReceivedFile(
        filename: 'test.txt',
        path: '/path',
        mime: 'text/plain',
        size: 2 * 1024 * 1024 * 1024,
        isMedia: false,
      );
      expect(file.formattedSize, '2.0 GB');
    });

    test('isImage returns true for image mime types', () {
      final file = ReceivedFile(
        filename: 'test.jpg',
        path: '/path',
        mime: 'image/jpeg',
        size: 100,
        isMedia: true,
      );
      expect(file.isImage, isTrue);
    });

    test('isImage returns false for non-image mime types', () {
      final file = ReceivedFile(
        filename: 'test.txt',
        path: '/path',
        mime: 'text/plain',
        size: 100,
        isMedia: false,
      );
      expect(file.isImage, isFalse);
    });

    test('isVideo returns true for video mime types', () {
      final file = ReceivedFile(
        filename: 'test.mp4',
        path: '/path',
        mime: 'video/mp4',
        size: 100,
        isMedia: true,
      );
      expect(file.isVideo, isTrue);
    });

    test('isPdf returns true for pdf mime types', () {
      final file = ReceivedFile(
        filename: 'test.pdf',
        path: '/path',
        mime: 'application/pdf',
        size: 100,
        isMedia: false,
      );
      expect(file.isPdf, isTrue);
    });

    test('ext returns file extension in uppercase', () {
      final file = ReceivedFile(
        filename: 'test.jpg',
        path: '/path',
        mime: 'image/jpeg',
        size: 100,
        isMedia: true,
      );
      expect(file.ext, 'JPG');
    });
  });

  group('ReceivedFilesGrid', () {
    testWidgets('shows empty state when no files', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceivedFilesGrid(files: const [], onClear: () {}),
          ),
        ),
      );

      expect(find.text('No files received yet'), findsOneWidget);
      expect(
        find.text('Files sent to this device will appear here'),
        findsOneWidget,
      );
    });

    testWidgets('shows file count in header', (tester) async {
      final files = [
        ReceivedFile(
          filename: 'test1.jpg',
          path: '/path',
          mime: 'image/jpeg',
          size: 100,
          isMedia: true,
        ),
        ReceivedFile(
          filename: 'test2.txt',
          path: '/path',
          mime: 'text/plain',
          size: 100,
          isMedia: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceivedFilesGrid(files: files, onClear: () {}),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows clear button when files exist', (tester) async {
      final files = [
        ReceivedFile(
          filename: 'test1.jpg',
          path: '/path',
          mime: 'image/jpeg',
          size: 100,
          isMedia: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceivedFilesGrid(files: files, onClear: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });
  });

  group('ServerNotRunning', () {
    testWidgets('shows correct UI elements', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServerNotRunning(
              portController: controller,
              onStartPressed: () {},
              onExportLogs: () {},
            ),
          ),
        ),
      );

      expect(find.text('Start Sharing'), findsOneWidget);
      expect(find.text('Start the server'), findsOneWidget);
      expect(find.text('Export logs'), findsOneWidget);
      expect(find.text('Port (optional)'), findsOneWidget);
    });

    testWidgets('calls onStartPressed when start button tapped', (
      tester,
    ) async {
      bool started = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServerNotRunning(
              portController: controller,
              onStartPressed: () {
                started = true;
              },
              onExportLogs: () {},
            ),
          ),
        ),
      );

      final startButton = find.text('Start the server');
      await tester.ensureVisible(startButton);
      await tester.pumpAndSettle();
      await tester.tap(startButton, warnIfMissed: false);

      expect(started, isTrue);
    });

    testWidgets('calls onExportLogs when export logs tapped', (tester) async {
      bool exported = false;
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ServerNotRunning(
              portController: controller,
              onStartPressed: () {},
              onExportLogs: () {
                exported = true;
              },
            ),
          ),
        ),
      );

      final exportButton = find.text('Export logs');
      await tester.ensureVisible(exportButton);
      await tester.pumpAndSettle();
      await tester.tap(exportButton, warnIfMissed: false);

      expect(exported, isTrue);
    });
  });

  group('Stop server', () {
    testWidgets('Stop server', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: TestLocalShareAppRunning())),
        ),
      );

      searchStartButton() => find.text("Start the server");
      searchStopButton() => find.textContaining("Stop");

      expect(searchStartButton(), findsNothing);
      expect(searchStopButton(), findsOneWidget);

      await tester.tap(searchStopButton());
      await tester.pump();

      expect(searchStartButton(), findsOneWidget);
      expect(searchStopButton(), findsNothing);
    });
  });

  group('Loading state', () {
    testWidgets('shows loading indicator when server is loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Center(child: TestLocalShareAppLoading())),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

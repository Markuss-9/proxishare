import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proxishare/local_share_app.dart';

import 'package:proxishare/server/local_server.dart';

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

void main() {
  testWidgets('Start server', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: TestLocalShareApp())),
      ),
    );

    searchStartButton() => find.text("Start the server");
    searchStopButton() => find.textContaining("Stop");

    expect(searchStartButton(), findsOne);
    expect(searchStopButton(), findsNothing);

    await tester.tap(searchStartButton());
    await tester.pump(Duration(seconds: 1));

    expect(searchStartButton(), findsNothing);
    expect(searchStopButton(), findsOne);
  });
  testWidgets('Stop server', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: TestLocalShareAppRunning())),
      ),
    );

    searchStartButton() => find.text("Start the server");
    searchStopButton() => find.textContaining("Stop");

    expect(searchStartButton(), findsNothing);
    expect(searchStopButton(), findsOne);

    await tester.tap(searchStopButton());
    await tester.pump();

    expect(searchStartButton(), findsOne);
    expect(searchStopButton(), findsNothing);
  });
}

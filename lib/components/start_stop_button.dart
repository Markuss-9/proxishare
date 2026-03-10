import 'package:flutter/material.dart';

class StartStopButton extends StatelessWidget {
  final bool isServerRunning;
  final VoidCallback? onPressed;
  final bool isLoading;

  const StartStopButton({
    super.key,
    required this.isServerRunning,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    return TextButton(
      onPressed: onPressed,
      child: Text(isServerRunning ? 'Stop the server' : 'Start the server'),
    );
  }
}

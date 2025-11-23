import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/services/notifications/notification_channels.dart';
import 'package:proxishare/services/notifications/notification_service.dart';

class NotificationInitialization {
  static Future<void> initialize() async {
    final plugin = NotificationService.plugin;

    // ---------------- PLATFORM SETTINGS ----------------

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const windowsSettings = WindowsInitializationSettings(
      appName: 'ProxiShare',
      appUserModelId: 'com.example.proxishare',
      guid: '23e6b3d0-8f4a-4f2a-9b3a-1a2b3c4d5e6f',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
      windows: windowsSettings,
    );

    // ---------------- INITIALIZE ----------------

    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        NotificationService.onTap(response);
      },
    );

    // ---------------- ANDROID ONLY ----------------

    if (Platform.isAndroid) {
      await _configureAndroidChannels();
      await _requestAndroidNotificationPermission();
    }
  }

  static Future<void> _configureAndroidChannels() async {
    const uploadsChannel = AndroidNotificationChannel(
      AppNotificationChannels.uploads,
      'Uploads',
      description: 'New uploads and background tasks',
      importance: Importance.high,
    );

    final android = NotificationService.plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(uploadsChannel);
  }

  static Future<void> _requestAndroidNotificationPermission() async {
    try {
      await Permission.notification.request();
    } catch (e) {
      logger.warn('Failed to request notification permission on Android : $e');
    }
  }
}

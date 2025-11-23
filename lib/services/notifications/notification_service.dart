import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:proxishare/logger.dart';
import 'package:proxishare/services/notifications/notification_channels.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  static Future<void> showNewMediaReceived(Iterable<String> fileNames) async {
    await _plugin.show(
      1,
      'New media received',
      'Files: ${fileNames.join(', ')}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppNotificationChannels.uploads,
          'Uploads',
          channelDescription: 'New uploads',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: 'new_media_received: ${fileNames.join(', ')}',
    );
  }

  static void onTap(NotificationResponse response) {
    logger.info('Notification tapped with payload: ${response.payload}');
  }
}

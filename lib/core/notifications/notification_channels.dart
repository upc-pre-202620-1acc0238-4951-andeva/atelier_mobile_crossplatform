import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Canales de Android, los mismos ids que la app nativa. En iOS no existen.
class NotificationChannels {
  static AndroidNotificationChannel channelFor(
    PushChannel channel,
    AppLocalizations strings,
  ) {
    return switch (channel) {
      PushChannel.tasks => AndroidNotificationChannel(
        'tasks',
        strings.notificationChannelTasks,
        importance: Importance.high,
      ),
      PushChannel.attendance => AndroidNotificationChannel(
        'attendance',
        strings.notificationChannelAttendance,
      ),
      PushChannel.inventory => AndroidNotificationChannel(
        'inventory',
        strings.notificationChannelInventory,
      ),
    };
  }

  static Future<void> create(
    FlutterLocalNotificationsPlugin plugin,
    AppLocalizations strings,
  ) async {
    final android = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    for (final channel in PushChannel.values) {
      await android?.createNotificationChannel(channelFor(channel, strings));
    }
  }
}

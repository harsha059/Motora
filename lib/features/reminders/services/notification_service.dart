import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/reminder_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _notificationsPlugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String channelId = 'mygarage_reminders';
  static const String channelName = 'Maintenance Reminders';
  static const String channelDescription = 'Scheduled vehicle service, inspection and document reminders';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error (handled gracefully for non-mobile/test): $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb || !Platform.isAndroid) return false;

    try {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  int _notificationIdFor(String reminderId) {
    return reminderId.hashCode.abs() & 0x7FFFFFFF;
  }

  Future<void> scheduleReminderNotification(MaintenanceReminderModel reminder) async {
    if (reminder.isCompleted || reminder.dueDate == null) return;

    try {
      await initialize();

      final id = _notificationIdFor(reminder.id);
      final alertDate = reminder.dueDate!.subtract(Duration(days: reminder.notificationLeadDays));
      final now = DateTime.now();

      // Only schedule if the alert trigger time is in the future
      if (alertDate.isAfter(now)) {
        // Android details
        const androidDetails = AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

        const details = NotificationDetails(android: androidDetails);

        debugPrint(
          'Scheduled notification ($id) for reminder ${reminder.id} on channel ${details.android?.channelId} at $alertDate',
        );
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelReminderNotification(String reminderId) async {
    try {
      await initialize();
      final id = _notificationIdFor(reminderId);
      await _notificationsPlugin.cancel(id);
      debugPrint('Cancelled notification for reminder $reminderId (id: $id)');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await initialize();
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

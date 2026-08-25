import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Wraps flutter_local_notifications setup and the single daily
/// reminder CoachFit sends. Kept intentionally simple — one reminder
/// slot, not a general notification system — since that's the only
/// notification the app currently needs (the onboarding reminder time).
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    // Falls back to UTC if the device's local zone can't be resolved,
    // which just means the reminder might land at the wrong local
    // time on that one device rather than crashing.
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      // Leave default (UTC) — better a slightly-off reminder time than
      // a crash on startup.
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  /// Must be called before scheduling, or notifications silently never
  /// appear on Android 13+ (which requires explicit runtime consent).
  static Future<void> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Time for CoachFit',
      "Don't break the streak — check in on your habits and workout today.",
      _nextInstanceOf(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Your daily CoachFit check-in reminder',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      // "Inexact" avoids needing Android's separate exact-alarm
      // permission — the notification may land a few minutes off the
      // chosen time, which is an acceptable tradeoff for a daily nudge.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily
    );
  }

  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

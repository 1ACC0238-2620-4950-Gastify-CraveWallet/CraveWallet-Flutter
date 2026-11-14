import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import 'models.dart';

class ReminderDeviceService {
  ReminderDeviceService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  static const _channelId = 'cravewallet_charges';
  static const _channelName = 'Subscription Charge Reminders';
  static const _channelDescription =
      'Notifications before upcoming subscription charges';

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (_initialized || !isSupported) return;
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('America/Lima'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    try {
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (_) {
      // Ignore in headless test environments where platform channels are absent.
    }
  }

  Future<bool> requestNotificationPermission() async {
    if (!isSupported) return false;
    await initialize();
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await androidPlugin?.requestNotificationsPermission();
        return granted ?? true;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosPlugin?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? true;
      }
    } catch (_) {
      return true;
    }
    return true;
  }

  Future<int> syncScheduledNotifications({
    required List<Subscription> subscriptions,
    required ReminderSettings settings,
    required AppLocalizations l10n,
  }) async {
    if (!isSupported) return 0;
    await initialize();
    if (!_initialized) return 0;
    try {
      await _plugin.cancelAll();
    } catch (_) {
      return 0;
    }
    if (!settings.pushEnabled) return 0;

    final now = DateTime.now();
    var scheduledCount = 0;
    for (final sub in subscriptions) {
      if (!sub.active) continue;
      final chargeDate = DateTime(
        sub.nextCharge.year,
        sub.nextCharge.month,
        sub.nextCharge.day,
        settings.hour,
      );
      var notifyAt = chargeDate.subtract(Duration(days: settings.daysBefore));
      if (notifyAt.isBefore(now)) {
        if (chargeDate.isAfter(now)) {
          notifyAt = now.add(const Duration(minutes: 1));
        } else {
          continue;
        }
      }
      final tzDate = tz.TZDateTime.from(notifyAt, tz.local);
      final id = sub.id.hashCode & 0x7fffffff;
      final formattedAmount =
          '${sub.currency.symbol} ${sub.amount.toStringAsFixed(2)}';
      final formattedDate =
          '${sub.nextCharge.day.toString().padLeft(2, '0')}/${sub.nextCharge.month.toString().padLeft(2, '0')}/${sub.nextCharge.year}';
      final title = l10n.notificationChargeTitle(sub.name);
      final body = l10n.notificationChargeBody(formattedAmount, formattedDate);

      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          tzDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduledCount++;
      } catch (_) {
        // Ignore individual platform channel errors in test environments.
      }
    }
    return scheduledCount;
  }

  Future<bool> addSubscriptionToCalendar({
    required Subscription subscription,
    required ReminderSettings settings,
    required AppLocalizations l10n,
  }) async {
    if (!isSupported) return false;
    final startDate = DateTime(
      subscription.nextCharge.year,
      subscription.nextCharge.month,
      subscription.nextCharge.day,
      settings.hour,
    );
    final endDate = startDate.add(const Duration(hours: 1));
    final formattedAmount =
        '${subscription.currency.symbol} ${subscription.amount.toStringAsFixed(2)}';
    final formattedDate =
        '${subscription.nextCharge.day.toString().padLeft(2, '0')}/${subscription.nextCharge.month.toString().padLeft(2, '0')}/${subscription.nextCharge.year}';
    final event = Event(
      title: l10n.notificationChargeTitle(subscription.name),
      description:
          '${l10n.notificationChargeBody(formattedAmount, formattedDate)}'
          '${subscription.notes.isNotEmpty ? '\n${subscription.notes}' : ''}',
      startDate: startDate,
      endDate: endDate,
    );
    try {
      return await Add2Calendar.addEvent2Cal(event);
    } catch (_) {
      return false;
    }
  }
}

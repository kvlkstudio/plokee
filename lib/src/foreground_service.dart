import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'localization.dart';

/// Keeps the app process alive on Android while it's in the background so
/// sync connections don't drop and history keeps accumulating.
///
/// Android 10+ still forbids reading/writing the system clipboard from the
/// background, so received clips are stored and applied to the clipboard the
/// next time the app is in the foreground — but the device stays reachable
/// and nothing is lost. No-op on every non-Android platform.
class ForegroundService {
  static bool get _supported => Platform.isAndroid;

  static Future<void> init() async {
    if (!_supported) return;
    final l10n = await loadAppLocalizations();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'plokee_sync',
        channelName: l10n.notificationChannelName,
        channelDescription: l10n.notificationChannelDescription,
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        // Pure keep-alive: no periodic isolate callback, just hold the
        // process. The sync engine keeps running in the main isolate.
        eventAction: ForegroundTaskEventAction.nothing(),
        allowWakeLock: true,
        allowWifiLock: true,
        autoRunOnBoot: false,
      ),
    );
  }

  /// Ensures the notification permission is granted (Android 13+).
  static Future<bool> ensurePermissions() async {
    if (!_supported) return false;
    final status = await FlutterForegroundTask.checkNotificationPermission();
    if (status == NotificationPermission.granted) return true;
    final requested =
        await FlutterForegroundTask.requestNotificationPermission();
    return requested == NotificationPermission.granted;
  }

  static Future<void> start() async {
    if (!_supported) return;
    if (await FlutterForegroundTask.isRunningService) return;
    await ensurePermissions();
    final l10n = await loadAppLocalizations();
    await FlutterForegroundTask.startService(
      serviceId: 4576,
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: l10n.notificationTitle,
      notificationText: l10n.notificationText,
    );
  }

  static Future<void> stop() async {
    if (!_supported) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

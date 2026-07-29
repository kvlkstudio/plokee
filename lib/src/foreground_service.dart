import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'localization.dart';

/// Ids of the notification action buttons, as sent to the main isolate.
const String notificationActionPause = 'pause';
const String notificationActionResume = 'resume';

/// Entry point for the service's own isolate.
///
/// The keep-alive service does no work of its own — sync runs in the main
/// isolate — but Android delivers a notification button press to whichever
/// isolate the service was started with, so there has to be one to receive it
/// and hand it on.
@pragma('vm:entry-point')
void plokeeServiceCallback() {
  FlutterForegroundTask.setTaskHandler(_RelayTaskHandler());
}

class _RelayTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) =>
      FlutterForegroundTask.sendDataToMain(id);

  @override
  void onNotificationPressed() => FlutterForegroundTask.launchApp();
}

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

  static Future<void> start({bool syncEnabled = true, String? status}) async {
    if (!_supported) return;
    if (await FlutterForegroundTask.isRunningService) {
      await update(syncEnabled: syncEnabled, status: status);
      return;
    }
    await ensurePermissions();
    final l10n = await loadAppLocalizations();
    await FlutterForegroundTask.startService(
      serviceId: 4576,
      serviceTypes: [ForegroundServiceTypes.dataSync],
      notificationTitle: l10n.notificationTitle,
      notificationText: status ?? l10n.notificationText,
      notificationButtons: await _buttons(syncEnabled),
      callback: plokeeServiceCallback,
    );
  }

  /// Keeps the notification honest while the service runs: how many devices
  /// are actually connected, and whether the button offers pause or resume.
  ///
  /// A permanent notification that says "syncing" while sync is paused, or
  /// "connected" with nothing connected, is worse than no notification.
  static Future<void> update({
    required bool syncEnabled,
    String? status,
  }) async {
    if (!_supported) return;
    if (!await FlutterForegroundTask.isRunningService) return;
    final l10n = await loadAppLocalizations();
    await FlutterForegroundTask.updateService(
      notificationTitle: l10n.notificationTitle,
      notificationText: syncEnabled
          ? (status ?? l10n.notificationText)
          : l10n.notificationPaused,
      notificationButtons: await _buttons(syncEnabled),
    );
  }

  static Future<List<NotificationButton>> _buttons(bool syncEnabled) async {
    final l10n = await loadAppLocalizations();
    return [
      NotificationButton(
        id: syncEnabled ? notificationActionPause : notificationActionResume,
        text:
            syncEnabled ? l10n.notificationPause : l10n.notificationResume,
      ),
    ];
  }

  static Future<void> stop() async {
    if (!_supported) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }
}

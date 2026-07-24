// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusConnecting => 'Connecting…';

  @override
  String get statusIdle => 'Idle';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusPaired => 'Paired';

  @override
  String connectedDevices(int count) {
    return '$count connected';
  }

  @override
  String get sync => 'Sync';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get devices => 'Devices';

  @override
  String get history => 'History';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get done => 'Done';

  @override
  String get pair => 'Pair';

  @override
  String get unpair => 'Unpair';

  @override
  String get decline => 'Decline';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get lookingForDevices => 'Looking for devices…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Open Plokee on another device\non the same network.';

  @override
  String newDeviceAt(String address) {
    return 'New · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Pairing with “$name”';
  }

  @override
  String get pairingRequest => 'Pairing request';

  @override
  String get pairingFailed => 'Pairing failed';

  @override
  String get confirmOnOtherDevice =>
      'Confirm on the other device. Both devices should show this code:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) wants to pair.';
  }

  @override
  String nowConnected(String name) {
    return '“$name” is now connected. Your clipboard will sync automatically.';
  }

  @override
  String get makeSureSameCode => 'Make sure both devices show the same code:';

  @override
  String get requestDeclinedOrTimedOut =>
      'The request was declined or timed out.';

  @override
  String get nothingCopiedYet => 'Nothing copied yet';

  @override
  String get copiesShowUpHere =>
      'Copies show up here and sync\nto your paired devices.';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryQuestion => 'Clear history?';

  @override
  String get clearHistoryExplanation =>
      'This removes all saved clips on this device. Paired devices keep their own history.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'From $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Image ($size)';
  }

  @override
  String get openInBrowser => 'Open in browser';

  @override
  String get writeEmail => 'Write email';

  @override
  String get saveImage => 'Save image';

  @override
  String get showInFolder => 'Show in folder';

  @override
  String get imageSaved => 'Image saved';

  @override
  String get couldNotSaveImage => 'Could not save the image';

  @override
  String get couldNotOpenLink => 'Could not open the link';

  @override
  String get couldNotOpenFolder => 'Could not open the folder';

  @override
  String get imageNoLongerAvailable => 'This image is no longer available';

  @override
  String get filesNoLongerAvailable => 'These files are no longer available';

  @override
  String get sendClipboard => 'Send clipboard';

  @override
  String get clipboardSent => 'Clipboard sent';

  @override
  String get nothingNewToSend => 'Nothing new to send';

  @override
  String get deviceName => 'Device name';

  @override
  String get deviceNameExplanation => 'How this device appears to others.';

  @override
  String get syncClipboard => 'Sync clipboard';

  @override
  String get syncClipboardExplanation =>
      'Send and receive clips with paired devices.';

  @override
  String get readClipboardOnOpen => 'Read clipboard on open';

  @override
  String get readClipboardOnOpenExplanation =>
      'Check the clipboard automatically when the app comes to the front.';

  @override
  String get keepSyncingInBackground => 'Keep syncing in background';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Stay connected when Plokee is minimized. Shows a permanent notification.';

  @override
  String get couldNotStart => 'Couldn’t start';

  @override
  String get trayOpenPlokee => 'Open Plokee';

  @override
  String get trayCheckClipboardNow => 'Check clipboard now';

  @override
  String get trayRecentClipboard => 'Recent clipboard';

  @override
  String get traySyncClipboard => 'Sync clipboard';

  @override
  String get trayQuit => 'Quit';

  @override
  String get traySyncIsOn => 'Sync is on';

  @override
  String get traySyncIsPaused => 'Sync is paused';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online of $total devices online';
  }

  @override
  String get notificationChannelName => 'Clipboard sync';

  @override
  String get notificationChannelDescription =>
      'Keeps Plokee connected to your paired devices.';

  @override
  String get notificationTitle => 'Plokee is syncing';

  @override
  String get notificationText => 'Connected to your paired devices';
}

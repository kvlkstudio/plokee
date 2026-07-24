// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Verbunden';

  @override
  String get statusConnecting => 'Verbinden…';

  @override
  String get statusIdle => 'Bereit';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusPaired => 'Gekoppelt';

  @override
  String connectedDevices(int count) {
    return '$count verbunden';
  }

  @override
  String get sync => 'Sync';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get devices => 'Geräte';

  @override
  String get history => 'Verlauf';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get clear => 'Löschen';

  @override
  String get done => 'Fertig';

  @override
  String get pair => 'Koppeln';

  @override
  String get unpair => 'Entkoppeln';

  @override
  String get decline => 'Ablehnen';

  @override
  String get save => 'Speichern';

  @override
  String get share => 'Teilen';

  @override
  String get copy => 'Kopieren';

  @override
  String get copied => 'Kopiert';

  @override
  String get lookingForDevices => 'Suche nach Geräten…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Öffne Plokee auf einem anderen Gerät\nim selben Netzwerk.';

  @override
  String newDeviceAt(String address) {
    return 'Neu · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Koppeln mit „$name“';
  }

  @override
  String get pairingRequest => 'Kopplungsanfrage';

  @override
  String get pairingFailed => 'Kopplung fehlgeschlagen';

  @override
  String get confirmOnOtherDevice =>
      'Bestätige auf dem anderen Gerät. Beide Geräte sollten diesen Code zeigen:';

  @override
  String wantsToPair(String name, String platform) {
    return '„$name“ ($platform) möchte sich koppeln.';
  }

  @override
  String nowConnected(String name) {
    return '„$name“ ist jetzt verbunden. Deine Zwischenablage wird automatisch synchronisiert.';
  }

  @override
  String get makeSureSameCode =>
      'Stelle sicher, dass beide Geräte denselben Code zeigen:';

  @override
  String get requestDeclinedOrTimedOut =>
      'Die Anfrage wurde abgelehnt oder ist abgelaufen.';

  @override
  String get nothingCopiedYet => 'Noch nichts kopiert';

  @override
  String get copiesShowUpHere =>
      'Kopiertes erscheint hier und wird\nmit deinen gekoppelten Geräten synchronisiert.';

  @override
  String get clearHistory => 'Verlauf löschen';

  @override
  String get clearHistoryQuestion => 'Verlauf löschen?';

  @override
  String get clearHistoryExplanation =>
      'Das entfernt alle gespeicherten Einträge auf diesem Gerät. Gekoppelte Geräte behalten ihren eigenen Verlauf.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'Von $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Bild ($size)';
  }

  @override
  String get openInBrowser => 'Im Browser öffnen';

  @override
  String get writeEmail => 'E-Mail schreiben';

  @override
  String get saveImage => 'Bild speichern';

  @override
  String get showInFolder => 'Im Ordner zeigen';

  @override
  String get imageSaved => 'Bild gespeichert';

  @override
  String get couldNotSaveImage => 'Bild konnte nicht gespeichert werden';

  @override
  String get couldNotOpenLink => 'Link konnte nicht geöffnet werden';

  @override
  String get couldNotOpenFolder => 'Ordner konnte nicht geöffnet werden';

  @override
  String get imageNoLongerAvailable => 'Dieses Bild ist nicht mehr verfügbar';

  @override
  String get filesNoLongerAvailable =>
      'Diese Dateien sind nicht mehr verfügbar';

  @override
  String get sendClipboard => 'Zwischenablage senden';

  @override
  String get clipboardSent => 'Zwischenablage gesendet';

  @override
  String get nothingNewToSend => 'Nichts Neues zu senden';

  @override
  String get deviceName => 'Gerätename';

  @override
  String get deviceNameExplanation => 'So erscheint dieses Gerät bei anderen.';

  @override
  String get syncClipboard => 'Zwischenablage synchronisieren';

  @override
  String get syncClipboardExplanation =>
      'Einträge mit gekoppelten Geräten senden und empfangen.';

  @override
  String get readClipboardOnOpen => 'Zwischenablage beim Öffnen lesen';

  @override
  String get readClipboardOnOpenExplanation =>
      'Die Zwischenablage automatisch prüfen, wenn die App in den Vordergrund kommt.';

  @override
  String get keepSyncingInBackground => 'Im Hintergrund weiter synchronisieren';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Verbunden bleiben, wenn Plokee minimiert ist. Zeigt eine dauerhafte Benachrichtigung.';

  @override
  String get couldNotStart => 'Start fehlgeschlagen';

  @override
  String get trayOpenPlokee => 'Plokee öffnen';

  @override
  String get trayCheckClipboardNow => 'Zwischenablage jetzt prüfen';

  @override
  String get trayRecentClipboard => 'Zuletzt kopiert';

  @override
  String get traySyncClipboard => 'Zwischenablage synchronisieren';

  @override
  String get trayQuit => 'Beenden';

  @override
  String get traySyncIsOn => 'Sync ist an';

  @override
  String get traySyncIsPaused => 'Sync pausiert';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online von $total Geräten online';
  }

  @override
  String get notificationChannelName => 'Zwischenablage-Sync';

  @override
  String get notificationChannelDescription =>
      'Hält Plokee mit deinen gekoppelten Geräten verbunden.';

  @override
  String get notificationTitle => 'Plokee synchronisiert';

  @override
  String get notificationText => 'Mit deinen gekoppelten Geräten verbunden';
}

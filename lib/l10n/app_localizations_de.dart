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
  String get addByIp => 'Gerät wird nicht angezeigt? Per IP hinzufügen';

  @override
  String get addByIpTitle => 'Gerät per IP hinzufügen';

  @override
  String get addByIpExplanation =>
      'Manche Netzwerke verbergen Geräte voreinander. Gib die IP-Adresse des anderen Geräts ein, um direkt zu koppeln.';

  @override
  String get ipAddress => 'IP-Adresse';

  @override
  String get add => 'Hinzufügen';

  @override
  String get searching => 'Suche…';

  @override
  String thisDeviceAddress(String address) {
    return 'Dieses Gerät: $address';
  }

  @override
  String noDeviceAtIp(String address) {
    return 'Kein Plokee-Gerät unter $address gefunden';
  }

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

  @override
  String notificationConnected(int count, int total) {
    return '$count von $total Geräten verbunden';
  }

  @override
  String get notificationPaused => 'Sync pausiert';

  @override
  String get notificationPause => 'Pausieren';

  @override
  String get notificationResume => 'Fortsetzen';

  @override
  String get syncRules => 'Sync-Regeln';

  @override
  String syncRulesFor(String name) {
    return 'Was dieses Gerät mit „$name“ synchronisiert';
  }

  @override
  String get ruleSendTo => 'Dorthin senden';

  @override
  String get ruleSendToExplanation =>
      'Hier Kopiertes an dieses Gerät schicken.';

  @override
  String get ruleReceiveFrom => 'Von dort empfangen';

  @override
  String get ruleReceiveFromExplanation =>
      'Dort Kopiertes in diese Zwischenablage übernehmen.';

  @override
  String get ruleKinds => 'Arten';

  @override
  String get ruleText => 'Text';

  @override
  String get ruleImages => 'Bilder';

  @override
  String get ruleFiles => 'Dateien';

  @override
  String get ruleSummaryNothing => 'Nichts';

  @override
  String get ruleSummaryReceiveOnly => 'Nur empfangen';

  @override
  String get ruleSummarySendOnly => 'Nur senden';

  @override
  String get ruleSummaryCustom => 'Angepasst';

  @override
  String get transfers => 'Übertragungen';

  @override
  String transferSendingTo(String name) {
    return 'Senden an $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return 'Empfangen von $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done von $total';
  }

  @override
  String get transferText => 'Text';

  @override
  String get transferImage => 'Bild';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Verbonden';

  @override
  String get statusConnecting => 'Verbinden…';

  @override
  String get statusIdle => 'Inactief';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusPaired => 'Gekoppeld';

  @override
  String connectedDevices(int count) {
    return '$count verbonden';
  }

  @override
  String get sync => 'Sync';

  @override
  String get settings => 'Instellingen';

  @override
  String get language => 'Taal';

  @override
  String get languageSystem => 'Systeem';

  @override
  String get devices => 'Apparaten';

  @override
  String get history => 'Geschiedenis';

  @override
  String get cancel => 'Annuleren';

  @override
  String get clear => 'Wissen';

  @override
  String get done => 'Klaar';

  @override
  String get pair => 'Koppelen';

  @override
  String get unpair => 'Ontkoppelen';

  @override
  String get decline => 'Weigeren';

  @override
  String get save => 'Opslaan';

  @override
  String get share => 'Delen';

  @override
  String get copy => 'Kopiëren';

  @override
  String get copied => 'Gekopieerd';

  @override
  String get lookingForDevices => 'Apparaten zoeken…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Open Plokee op een ander apparaat\nin hetzelfde netwerk.';

  @override
  String newDeviceAt(String address) {
    return 'Nieuw · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Koppelen met “$name”';
  }

  @override
  String get pairingRequest => 'Koppelverzoek';

  @override
  String get pairingFailed => 'Koppelen mislukt';

  @override
  String get confirmOnOtherDevice =>
      'Bevestig op het andere apparaat. Beide moeten deze code tonen:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) wil koppelen.';
  }

  @override
  String nowConnected(String name) {
    return '“$name” is nu verbonden. Je klembord wordt automatisch gesynchroniseerd.';
  }

  @override
  String get makeSureSameCode =>
      'Zorg dat beide apparaten dezelfde code tonen:';

  @override
  String get requestDeclinedOrTimedOut =>
      'Het verzoek is geweigerd of verlopen.';

  @override
  String get addByIp => 'Apparaat niet zichtbaar? Toevoegen via IP';

  @override
  String get addByIpTitle => 'Apparaat toevoegen via IP';

  @override
  String get addByIpExplanation =>
      'Sommige netwerken verbergen apparaten voor elkaar. Voer het IP-adres van het andere apparaat in om direct te koppelen.';

  @override
  String get ipAddress => 'IP-adres';

  @override
  String get add => 'Toevoegen';

  @override
  String get searching => 'Zoeken…';

  @override
  String thisDeviceAddress(String address) {
    return 'Dit apparaat: $address';
  }

  @override
  String noDeviceAtIp(String address) {
    return 'Geen Plokee-apparaat gevonden op $address';
  }

  @override
  String get nothingCopiedYet => 'Nog niets gekopieerd';

  @override
  String get copiesShowUpHere =>
      'Wat je kopieert verschijnt hier en synchroniseert\nmet je gekoppelde apparaten.';

  @override
  String get clearHistory => 'Geschiedenis wissen';

  @override
  String get clearHistoryQuestion => 'Geschiedenis wissen?';

  @override
  String get clearHistoryExplanation =>
      'Dit verwijdert alle bewaarde items op dit apparaat. Gekoppelde apparaten houden hun eigen geschiedenis.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'Van $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Afbeelding ($size)';
  }

  @override
  String get openInBrowser => 'Openen in browser';

  @override
  String get writeEmail => 'E-mail schrijven';

  @override
  String get saveImage => 'Afbeelding opslaan';

  @override
  String get showInFolder => 'Toon in map';

  @override
  String get imageSaved => 'Afbeelding opgeslagen';

  @override
  String get couldNotSaveImage => 'Kon de afbeelding niet opslaan';

  @override
  String get couldNotOpenLink => 'Kon de link niet openen';

  @override
  String get couldNotOpenFolder => 'Kon de map niet openen';

  @override
  String get imageNoLongerAvailable =>
      'Deze afbeelding is niet meer beschikbaar';

  @override
  String get filesNoLongerAvailable =>
      'Deze bestanden zijn niet meer beschikbaar';

  @override
  String get sendClipboard => 'Klembord versturen';

  @override
  String get clipboardSent => 'Klembord verstuurd';

  @override
  String get nothingNewToSend => 'Niets nieuws om te versturen';

  @override
  String get deviceName => 'Apparaatnaam';

  @override
  String get deviceNameExplanation =>
      'Hoe dit apparaat er voor anderen uitziet.';

  @override
  String get syncClipboard => 'Klembord synchroniseren';

  @override
  String get syncClipboardExplanation =>
      'Items versturen en ontvangen met gekoppelde apparaten.';

  @override
  String get readClipboardOnOpen => 'Klembord lezen bij openen';

  @override
  String get readClipboardOnOpenExplanation =>
      'Controleer het klembord automatisch wanneer de app op de voorgrond komt.';

  @override
  String get keepSyncingInBackground =>
      'Blijf synchroniseren op de achtergrond';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Blijf verbonden wanneer Plokee geminimaliseerd is. Toont een permanente melding.';

  @override
  String get couldNotStart => 'Kon niet starten';

  @override
  String get trayOpenPlokee => 'Plokee openen';

  @override
  String get trayCheckClipboardNow => 'Klembord nu controleren';

  @override
  String get trayRecentClipboard => 'Recent klembord';

  @override
  String get traySyncClipboard => 'Klembord synchroniseren';

  @override
  String get trayQuit => 'Afsluiten';

  @override
  String get traySyncIsOn => 'Sync staat aan';

  @override
  String get traySyncIsPaused => 'Sync gepauzeerd';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online van $total apparaten online';
  }

  @override
  String get notificationChannelName => 'Klembordsynchronisatie';

  @override
  String get notificationChannelDescription =>
      'Houdt Plokee verbonden met je gekoppelde apparaten.';

  @override
  String get notificationTitle => 'Plokee synchroniseert';

  @override
  String get notificationText => 'Verbonden met je gekoppelde apparaten';

  @override
  String notificationConnected(int count, int total) {
    return '$count van $total apparaten verbonden';
  }

  @override
  String get notificationPaused => 'Sync gepauzeerd';

  @override
  String get notificationPause => 'Pauzeren';

  @override
  String get notificationResume => 'Hervatten';

  @override
  String get syncRules => 'Syncregels';

  @override
  String syncRulesFor(String name) {
    return 'Wat dit apparaat synchroniseert met “$name”';
  }

  @override
  String get ruleSendTo => 'Ernaartoe sturen';

  @override
  String get ruleSendToExplanation =>
      'Stuur wat je hier kopieert naar dat apparaat.';

  @override
  String get ruleReceiveFrom => 'Ervan ontvangen';

  @override
  String get ruleReceiveFromExplanation =>
      'Pas toe op dit klembord wat daar wordt gekopieerd.';

  @override
  String get ruleKinds => 'Soorten';

  @override
  String get ruleText => 'Tekst';

  @override
  String get ruleImages => 'Afbeeldingen';

  @override
  String get ruleFiles => 'Bestanden';

  @override
  String get ruleSummaryNothing => 'Niets';

  @override
  String get ruleSummaryReceiveOnly => 'Alleen ontvangen';

  @override
  String get ruleSummarySendOnly => 'Alleen verzenden';

  @override
  String get ruleSummaryCustom => 'Aangepast';

  @override
  String get transfers => 'Overdrachten';

  @override
  String transferSendingTo(String name) {
    return 'Verzenden naar $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return 'Ontvangen van $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done van $total';
  }

  @override
  String get transferText => 'Tekst';

  @override
  String get transferImage => 'Afbeelding';
}

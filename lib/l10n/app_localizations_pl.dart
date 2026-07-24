// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Połączono';

  @override
  String get statusConnecting => 'Łączenie…';

  @override
  String get statusIdle => 'Bezczynny';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusPaired => 'Sparowano';

  @override
  String connectedDevices(int count) {
    return '$count połączonych';
  }

  @override
  String get sync => 'Sync';

  @override
  String get settings => 'Ustawienia';

  @override
  String get language => 'Język';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get devices => 'Urządzenia';

  @override
  String get history => 'Historia';

  @override
  String get cancel => 'Anuluj';

  @override
  String get clear => 'Wyczyść';

  @override
  String get done => 'Gotowe';

  @override
  String get pair => 'Sparuj';

  @override
  String get unpair => 'Rozparuj';

  @override
  String get decline => 'Odrzuć';

  @override
  String get save => 'Zapisz';

  @override
  String get share => 'Udostępnij';

  @override
  String get copy => 'Kopiuj';

  @override
  String get copied => 'Skopiowano';

  @override
  String get lookingForDevices => 'Szukanie urządzeń…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Otwórz Plokee na innym urządzeniu\nw tej samej sieci.';

  @override
  String newDeviceAt(String address) {
    return 'Nowe · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Parowanie z „$name”';
  }

  @override
  String get pairingRequest => 'Prośba o sparowanie';

  @override
  String get pairingFailed => 'Parowanie nieudane';

  @override
  String get confirmOnOtherDevice =>
      'Potwierdź na drugim urządzeniu. Oba powinny pokazywać ten kod:';

  @override
  String wantsToPair(String name, String platform) {
    return '„$name” ($platform) chce się sparować.';
  }

  @override
  String nowConnected(String name) {
    return '„$name” jest połączone. Twój schowek będzie synchronizowany automatycznie.';
  }

  @override
  String get makeSureSameCode =>
      'Upewnij się, że oba urządzenia pokazują ten sam kod:';

  @override
  String get requestDeclinedOrTimedOut =>
      'Prośba została odrzucona lub wygasła.';

  @override
  String get nothingCopiedYet => 'Nic jeszcze nie skopiowano';

  @override
  String get copiesShowUpHere =>
      'Skopiowane elementy pojawią się tutaj i zsynchronizują\nz Twoimi sparowanymi urządzeniami.';

  @override
  String get clearHistory => 'Wyczyść historię';

  @override
  String get clearHistoryQuestion => 'Wyczyścić historię?';

  @override
  String get clearHistoryExplanation =>
      'Usunie to wszystkie zapisane elementy na tym urządzeniu. Sparowane urządzenia zachowają własną historię.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'Od $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Obraz ($size)';
  }

  @override
  String get openInBrowser => 'Otwórz w przeglądarce';

  @override
  String get writeEmail => 'Napisz e-mail';

  @override
  String get saveImage => 'Zapisz obraz';

  @override
  String get showInFolder => 'Pokaż w folderze';

  @override
  String get imageSaved => 'Obraz zapisany';

  @override
  String get couldNotSaveImage => 'Nie udało się zapisać obrazu';

  @override
  String get couldNotOpenLink => 'Nie udało się otworzyć linku';

  @override
  String get couldNotOpenFolder => 'Nie udało się otworzyć folderu';

  @override
  String get imageNoLongerAvailable => 'Ten obraz nie jest już dostępny';

  @override
  String get filesNoLongerAvailable => 'Te pliki nie są już dostępne';

  @override
  String get sendClipboard => 'Wyślij schowek';

  @override
  String get clipboardSent => 'Schowek wysłany';

  @override
  String get nothingNewToSend => 'Nie ma nic nowego do wysłania';

  @override
  String get deviceName => 'Nazwa urządzenia';

  @override
  String get deviceNameExplanation => 'Tak to urządzenie widzą inni.';

  @override
  String get syncClipboard => 'Synchronizuj schowek';

  @override
  String get syncClipboardExplanation =>
      'Wysyłaj i odbieraj elementy ze sparowanymi urządzeniami.';

  @override
  String get readClipboardOnOpen => 'Czytaj schowek przy otwarciu';

  @override
  String get readClipboardOnOpenExplanation =>
      'Automatycznie sprawdzaj schowek, gdy aplikacja wraca na pierwszy plan.';

  @override
  String get keepSyncingInBackground => 'Synchronizuj w tle';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Pozostań połączony, gdy Plokee jest zminimalizowany. Pokazuje stałe powiadomienie.';

  @override
  String get couldNotStart => 'Nie udało się uruchomić';

  @override
  String get trayOpenPlokee => 'Otwórz Plokee';

  @override
  String get trayCheckClipboardNow => 'Sprawdź schowek teraz';

  @override
  String get trayRecentClipboard => 'Ostatnie elementy';

  @override
  String get traySyncClipboard => 'Synchronizuj schowek';

  @override
  String get trayQuit => 'Zakończ';

  @override
  String get traySyncIsOn => 'Synchronizacja włączona';

  @override
  String get traySyncIsPaused => 'Synchronizacja wstrzymana';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online z $total urządzeń online';
  }

  @override
  String get notificationChannelName => 'Synchronizacja schowka';

  @override
  String get notificationChannelDescription =>
      'Utrzymuje połączenie Plokee ze sparowanymi urządzeniami.';

  @override
  String get notificationTitle => 'Plokee synchronizuje';

  @override
  String get notificationText => 'Połączono ze sparowanymi urządzeniami';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Connesso';

  @override
  String get statusConnecting => 'Connessione…';

  @override
  String get statusIdle => 'Inattivo';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusPaired => 'Associato';

  @override
  String connectedDevices(int count) {
    return '$count connessi';
  }

  @override
  String get sync => 'Sync';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get devices => 'Dispositivi';

  @override
  String get history => 'Cronologia';

  @override
  String get cancel => 'Annulla';

  @override
  String get clear => 'Cancella';

  @override
  String get done => 'Fatto';

  @override
  String get pair => 'Associa';

  @override
  String get unpair => 'Dissocia';

  @override
  String get decline => 'Rifiuta';

  @override
  String get save => 'Salva';

  @override
  String get share => 'Condividi';

  @override
  String get copy => 'Copia';

  @override
  String get copied => 'Copiato';

  @override
  String get lookingForDevices => 'Ricerca dispositivi…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Apri Plokee su un altro dispositivo\nnella stessa rete.';

  @override
  String newDeviceAt(String address) {
    return 'Nuovo · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Associazione con “$name”';
  }

  @override
  String get pairingRequest => 'Richiesta di associazione';

  @override
  String get pairingFailed => 'Associazione non riuscita';

  @override
  String get confirmOnOtherDevice =>
      'Conferma sull’altro dispositivo. Entrambi devono mostrare questo codice:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) vuole associarsi.';
  }

  @override
  String nowConnected(String name) {
    return '“$name” è ora connesso. I tuoi appunti si sincronizzeranno automaticamente.';
  }

  @override
  String get makeSureSameCode =>
      'Assicurati che entrambi i dispositivi mostrino lo stesso codice:';

  @override
  String get requestDeclinedOrTimedOut =>
      'La richiesta è stata rifiutata o è scaduta.';

  @override
  String get addByIp => 'Dispositivo non visibile? Aggiungi tramite IP';

  @override
  String get addByIpTitle => 'Aggiungi dispositivo tramite IP';

  @override
  String get addByIpExplanation =>
      'Alcune reti nascondono i dispositivi l’uno all’altro. Inserisci l’indirizzo IP dell’altro dispositivo per associarlo direttamente.';

  @override
  String get ipAddress => 'Indirizzo IP';

  @override
  String get add => 'Aggiungi';

  @override
  String get searching => 'Ricerca…';

  @override
  String thisDeviceAddress(String address) {
    return 'Questo dispositivo: $address';
  }

  @override
  String noDeviceAtIp(String address) {
    return 'Nessun dispositivo Plokee trovato a $address';
  }

  @override
  String get nothingCopiedYet => 'Non hai ancora copiato nulla';

  @override
  String get copiesShowUpHere =>
      'Ciò che copi appare qui e si sincronizza\ncon i dispositivi associati.';

  @override
  String get clearHistory => 'Cancella cronologia';

  @override
  String get clearHistoryQuestion => 'Cancellare la cronologia?';

  @override
  String get clearHistoryExplanation =>
      'Rimuove tutti gli elementi salvati su questo dispositivo. Quelli associati mantengono la propria.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'Da $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Immagine ($size)';
  }

  @override
  String get openInBrowser => 'Apri nel browser';

  @override
  String get writeEmail => 'Scrivi email';

  @override
  String get saveImage => 'Salva immagine';

  @override
  String get showInFolder => 'Mostra nella cartella';

  @override
  String get imageSaved => 'Immagine salvata';

  @override
  String get couldNotSaveImage => 'Impossibile salvare l’immagine';

  @override
  String get couldNotOpenLink => 'Impossibile aprire il link';

  @override
  String get couldNotOpenFolder => 'Impossibile aprire la cartella';

  @override
  String get imageNoLongerAvailable => 'Questa immagine non è più disponibile';

  @override
  String get filesNoLongerAvailable => 'Questi file non sono più disponibili';

  @override
  String get sendClipboard => 'Invia appunti';

  @override
  String get clipboardSent => 'Appunti inviati';

  @override
  String get nothingNewToSend => 'Niente di nuovo da inviare';

  @override
  String get deviceName => 'Nome dispositivo';

  @override
  String get deviceNameExplanation =>
      'Come appare questo dispositivo agli altri.';

  @override
  String get syncClipboard => 'Sincronizza appunti';

  @override
  String get syncClipboardExplanation =>
      'Invia e ricevi elementi con i dispositivi associati.';

  @override
  String get readClipboardOnOpen => 'Leggi appunti all’apertura';

  @override
  String get readClipboardOnOpenExplanation =>
      'Controlla automaticamente gli appunti quando l’app torna in primo piano.';

  @override
  String get keepSyncingInBackground =>
      'Continua a sincronizzare in background';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Resta connesso quando Plokee è ridotto a icona. Mostra una notifica permanente.';

  @override
  String get couldNotStart => 'Avvio non riuscito';

  @override
  String get trayOpenPlokee => 'Apri Plokee';

  @override
  String get trayCheckClipboardNow => 'Controlla appunti ora';

  @override
  String get trayRecentClipboard => 'Appunti recenti';

  @override
  String get traySyncClipboard => 'Sincronizza appunti';

  @override
  String get trayQuit => 'Esci';

  @override
  String get traySyncIsOn => 'Sync attiva';

  @override
  String get traySyncIsPaused => 'Sync in pausa';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online di $total dispositivi online';
  }

  @override
  String get notificationChannelName => 'Sincronizzazione appunti';

  @override
  String get notificationChannelDescription =>
      'Mantiene Plokee connesso ai dispositivi associati.';

  @override
  String get notificationTitle => 'Plokee è in sincronizzazione';

  @override
  String get notificationText => 'Connesso ai tuoi dispositivi associati';

  @override
  String notificationConnected(int count, int total) {
    return '$count di $total dispositivi connessi';
  }

  @override
  String get notificationPaused => 'Sync in pausa';

  @override
  String get notificationPause => 'Pausa';

  @override
  String get notificationResume => 'Riprendi';

  @override
  String get syncRules => 'Regole di sincronizzazione';

  @override
  String syncRulesFor(String name) {
    return 'Cosa sincronizza questo dispositivo con “$name”';
  }

  @override
  String get ruleSendTo => 'Invia a esso';

  @override
  String get ruleSendToExplanation =>
      'Invia a quel dispositivo ciò che copi qui.';

  @override
  String get ruleReceiveFrom => 'Ricevi da esso';

  @override
  String get ruleReceiveFromExplanation =>
      'Applica a questi appunti ciò che copia là.';

  @override
  String get ruleKinds => 'Tipi';

  @override
  String get ruleText => 'Testo';

  @override
  String get ruleImages => 'Immagini';

  @override
  String get ruleFiles => 'File';

  @override
  String get ruleSummaryNothing => 'Niente';

  @override
  String get ruleSummaryReceiveOnly => 'Solo ricezione';

  @override
  String get ruleSummarySendOnly => 'Solo invio';

  @override
  String get ruleSummaryCustom => 'Personalizzato';

  @override
  String get transfers => 'Trasferimenti';

  @override
  String transferSendingTo(String name) {
    return 'Invio a $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return 'Ricezione da $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done di $total';
  }

  @override
  String get transferText => 'Testo';

  @override
  String get transferImage => 'Immagine';
}

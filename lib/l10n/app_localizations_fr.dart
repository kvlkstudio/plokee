// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Connecté';

  @override
  String get statusConnecting => 'Connexion…';

  @override
  String get statusIdle => 'Inactif';

  @override
  String get statusOffline => 'Hors ligne';

  @override
  String get statusPaired => 'Appairé';

  @override
  String connectedDevices(int count) {
    return '$count connecté(s)';
  }

  @override
  String get sync => 'Sync';

  @override
  String get settings => 'Réglages';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get devices => 'Appareils';

  @override
  String get history => 'Historique';

  @override
  String get cancel => 'Annuler';

  @override
  String get clear => 'Effacer';

  @override
  String get done => 'Terminé';

  @override
  String get pair => 'Appairer';

  @override
  String get unpair => 'Dissocier';

  @override
  String get decline => 'Refuser';

  @override
  String get save => 'Enregistrer';

  @override
  String get share => 'Partager';

  @override
  String get copy => 'Copier';

  @override
  String get copied => 'Copié';

  @override
  String get lookingForDevices => 'Recherche d’appareils…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Ouvrez Plokee sur un autre appareil\ndu même réseau.';

  @override
  String newDeviceAt(String address) {
    return 'Nouveau · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Appairage avec « $name »';
  }

  @override
  String get pairingRequest => 'Demande d’appairage';

  @override
  String get pairingFailed => 'Échec de l’appairage';

  @override
  String get confirmOnOtherDevice =>
      'Confirmez sur l’autre appareil. Les deux appareils doivent afficher ce code :';

  @override
  String wantsToPair(String name, String platform) {
    return '« $name » ($platform) souhaite s’appairer.';
  }

  @override
  String nowConnected(String name) {
    return '« $name » est maintenant connecté. Votre presse-papiers se synchronisera automatiquement.';
  }

  @override
  String get makeSureSameCode =>
      'Vérifiez que les deux appareils affichent le même code :';

  @override
  String get requestDeclinedOrTimedOut =>
      'La demande a été refusée ou a expiré.';

  @override
  String get nothingCopiedYet => 'Rien de copié pour l’instant';

  @override
  String get copiesShowUpHere =>
      'Vos copies apparaissent ici et se synchronisent\navec vos appareils appairés.';

  @override
  String get clearHistory => 'Effacer l’historique';

  @override
  String get clearHistoryQuestion => 'Effacer l’historique ?';

  @override
  String get clearHistoryExplanation =>
      'Cela supprime tous les éléments enregistrés sur cet appareil. Les appareils appairés conservent le leur.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'De $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Image ($size)';
  }

  @override
  String get openInBrowser => 'Ouvrir dans le navigateur';

  @override
  String get writeEmail => 'Écrire un e-mail';

  @override
  String get saveImage => 'Enregistrer l’image';

  @override
  String get showInFolder => 'Afficher dans le dossier';

  @override
  String get imageSaved => 'Image enregistrée';

  @override
  String get couldNotSaveImage => 'Impossible d’enregistrer l’image';

  @override
  String get couldNotOpenLink => 'Impossible d’ouvrir le lien';

  @override
  String get couldNotOpenFolder => 'Impossible d’ouvrir le dossier';

  @override
  String get imageNoLongerAvailable => 'Cette image n’est plus disponible';

  @override
  String get filesNoLongerAvailable => 'Ces fichiers ne sont plus disponibles';

  @override
  String get sendClipboard => 'Envoyer le presse-papiers';

  @override
  String get clipboardSent => 'Presse-papiers envoyé';

  @override
  String get nothingNewToSend => 'Rien de nouveau à envoyer';

  @override
  String get deviceName => 'Nom de l’appareil';

  @override
  String get deviceNameExplanation => 'Nom sous lequel cet appareil apparaît.';

  @override
  String get syncClipboard => 'Synchroniser le presse-papiers';

  @override
  String get syncClipboardExplanation =>
      'Envoyer et recevoir des éléments avec les appareils appairés.';

  @override
  String get readClipboardOnOpen => 'Lire le presse-papiers à l’ouverture';

  @override
  String get readClipboardOnOpenExplanation =>
      'Vérifier automatiquement le presse-papiers quand l’app passe au premier plan.';

  @override
  String get keepSyncingInBackground => 'Continuer la sync en arrière-plan';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Rester connecté quand Plokee est réduit. Affiche une notification permanente.';

  @override
  String get couldNotStart => 'Démarrage impossible';

  @override
  String get trayOpenPlokee => 'Ouvrir Plokee';

  @override
  String get trayCheckClipboardNow => 'Vérifier le presse-papiers';

  @override
  String get trayRecentClipboard => 'Presse-papiers récent';

  @override
  String get traySyncClipboard => 'Synchroniser le presse-papiers';

  @override
  String get trayQuit => 'Quitter';

  @override
  String get traySyncIsOn => 'Sync activée';

  @override
  String get traySyncIsPaused => 'Sync en pause';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online sur $total appareils en ligne';
  }

  @override
  String get notificationChannelName => 'Synchronisation du presse-papiers';

  @override
  String get notificationChannelDescription =>
      'Garde Plokee connecté à vos appareils appairés.';

  @override
  String get notificationTitle => 'Plokee synchronise';

  @override
  String get notificationText => 'Connecté à vos appareils appairés';
}

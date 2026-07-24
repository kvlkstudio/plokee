// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Conectado';

  @override
  String get statusConnecting => 'Conectando…';

  @override
  String get statusIdle => 'Ocioso';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusPaired => 'Emparelhado';

  @override
  String connectedDevices(int count) {
    return '$count conectados';
  }

  @override
  String get sync => 'Sinc.';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get devices => 'Dispositivos';

  @override
  String get history => 'Histórico';

  @override
  String get cancel => 'Cancelar';

  @override
  String get clear => 'Limpar';

  @override
  String get done => 'Concluído';

  @override
  String get pair => 'Emparelhar';

  @override
  String get unpair => 'Desemparelhar';

  @override
  String get decline => 'Recusar';

  @override
  String get save => 'Salvar';

  @override
  String get share => 'Compartilhar';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get lookingForDevices => 'Procurando dispositivos…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Abra o Plokee em outro dispositivo\nna mesma rede.';

  @override
  String newDeviceAt(String address) {
    return 'Novo · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Emparelhando com “$name”';
  }

  @override
  String get pairingRequest => 'Pedido de emparelhamento';

  @override
  String get pairingFailed => 'Falha no emparelhamento';

  @override
  String get confirmOnOtherDevice =>
      'Confirme no outro dispositivo. Ambos devem mostrar este código:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) quer emparelhar.';
  }

  @override
  String nowConnected(String name) {
    return '“$name” está conectado. Sua área de transferência será sincronizada automaticamente.';
  }

  @override
  String get makeSureSameCode =>
      'Confirme que ambos os dispositivos mostram o mesmo código:';

  @override
  String get requestDeclinedOrTimedOut => 'O pedido foi recusado ou expirou.';

  @override
  String get nothingCopiedYet => 'Nada copiado ainda';

  @override
  String get copiesShowUpHere =>
      'O que você copiar aparece aqui e sincroniza\ncom seus dispositivos emparelhados.';

  @override
  String get clearHistory => 'Limpar histórico';

  @override
  String get clearHistoryQuestion => 'Limpar histórico?';

  @override
  String get clearHistoryExplanation =>
      'Isso remove todos os itens salvos neste dispositivo. Os emparelhados mantêm o próprio histórico.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'De $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Imagem ($size)';
  }

  @override
  String get openInBrowser => 'Abrir no navegador';

  @override
  String get writeEmail => 'Escrever e-mail';

  @override
  String get saveImage => 'Salvar imagem';

  @override
  String get showInFolder => 'Mostrar na pasta';

  @override
  String get imageSaved => 'Imagem salva';

  @override
  String get couldNotSaveImage => 'Não foi possível salvar a imagem';

  @override
  String get couldNotOpenLink => 'Não foi possível abrir o link';

  @override
  String get couldNotOpenFolder => 'Não foi possível abrir a pasta';

  @override
  String get imageNoLongerAvailable => 'Esta imagem não está mais disponível';

  @override
  String get filesNoLongerAvailable =>
      'Estes arquivos não estão mais disponíveis';

  @override
  String get sendClipboard => 'Enviar área de transferência';

  @override
  String get clipboardSent => 'Área de transferência enviada';

  @override
  String get nothingNewToSend => 'Nada novo para enviar';

  @override
  String get deviceName => 'Nome do dispositivo';

  @override
  String get deviceNameExplanation =>
      'Como este dispositivo aparece para os outros.';

  @override
  String get syncClipboard => 'Sincronizar área de transferência';

  @override
  String get syncClipboardExplanation =>
      'Enviar e receber itens com dispositivos emparelhados.';

  @override
  String get readClipboardOnOpen => 'Ler área de transferência ao abrir';

  @override
  String get readClipboardOnOpenExplanation =>
      'Verificar a área de transferência automaticamente quando o app vier para frente.';

  @override
  String get keepSyncingInBackground =>
      'Continuar sincronizando em segundo plano';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Fica conectado quando o Plokee está minimizado. Mostra uma notificação permanente.';

  @override
  String get couldNotStart => 'Não foi possível iniciar';

  @override
  String get trayOpenPlokee => 'Abrir Plokee';

  @override
  String get trayCheckClipboardNow => 'Verificar área de transferência';

  @override
  String get trayRecentClipboard => 'Itens recentes';

  @override
  String get traySyncClipboard => 'Sincronizar área de transferência';

  @override
  String get trayQuit => 'Sair';

  @override
  String get traySyncIsOn => 'Sinc. ativada';

  @override
  String get traySyncIsPaused => 'Sinc. pausada';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online de $total dispositivos online';
  }

  @override
  String get notificationChannelName =>
      'Sincronização da área de transferência';

  @override
  String get notificationChannelDescription =>
      'Mantém o Plokee conectado aos seus dispositivos emparelhados.';

  @override
  String get notificationTitle => 'Plokee está sincronizando';

  @override
  String get notificationText => 'Conectado aos seus dispositivos emparelhados';
}

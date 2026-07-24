// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Conectado';

  @override
  String get statusConnecting => 'Conectando…';

  @override
  String get statusIdle => 'Inactivo';

  @override
  String get statusOffline => 'Sin conexión';

  @override
  String get statusPaired => 'Vinculado';

  @override
  String connectedDevices(int count) {
    return '$count conectados';
  }

  @override
  String get sync => 'Sinc.';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get devices => 'Dispositivos';

  @override
  String get history => 'Historial';

  @override
  String get cancel => 'Cancelar';

  @override
  String get clear => 'Borrar';

  @override
  String get done => 'Listo';

  @override
  String get pair => 'Vincular';

  @override
  String get unpair => 'Desvincular';

  @override
  String get decline => 'Rechazar';

  @override
  String get save => 'Guardar';

  @override
  String get share => 'Compartir';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get lookingForDevices => 'Buscando dispositivos…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Abre Plokee en otro dispositivo\nde la misma red.';

  @override
  String newDeviceAt(String address) {
    return 'Nuevo · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Vinculando con «$name»';
  }

  @override
  String get pairingRequest => 'Solicitud de vinculación';

  @override
  String get pairingFailed => 'Vinculación fallida';

  @override
  String get confirmOnOtherDevice =>
      'Confirma en el otro dispositivo. Ambos deben mostrar este código:';

  @override
  String wantsToPair(String name, String platform) {
    return '«$name» ($platform) quiere vincularse.';
  }

  @override
  String nowConnected(String name) {
    return '«$name» ya está conectado. Tu portapapeles se sincronizará automáticamente.';
  }

  @override
  String get makeSureSameCode =>
      'Asegúrate de que ambos dispositivos muestren el mismo código:';

  @override
  String get requestDeclinedOrTimedOut =>
      'La solicitud fue rechazada o expiró.';

  @override
  String get nothingCopiedYet => 'Aún no has copiado nada';

  @override
  String get copiesShowUpHere =>
      'Lo que copies aparecerá aquí y se sincronizará\ncon tus dispositivos vinculados.';

  @override
  String get clearHistory => 'Borrar historial';

  @override
  String get clearHistoryQuestion => '¿Borrar historial?';

  @override
  String get clearHistoryExplanation =>
      'Esto elimina todos los elementos guardados en este dispositivo. Los vinculados conservan el suyo.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'De $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Imagen ($size)';
  }

  @override
  String get openInBrowser => 'Abrir en el navegador';

  @override
  String get writeEmail => 'Escribir correo';

  @override
  String get saveImage => 'Guardar imagen';

  @override
  String get showInFolder => 'Mostrar en la carpeta';

  @override
  String get imageSaved => 'Imagen guardada';

  @override
  String get couldNotSaveImage => 'No se pudo guardar la imagen';

  @override
  String get couldNotOpenLink => 'No se pudo abrir el enlace';

  @override
  String get couldNotOpenFolder => 'No se pudo abrir la carpeta';

  @override
  String get imageNoLongerAvailable => 'Esta imagen ya no está disponible';

  @override
  String get filesNoLongerAvailable => 'Estos archivos ya no están disponibles';

  @override
  String get sendClipboard => 'Enviar portapapeles';

  @override
  String get clipboardSent => 'Portapapeles enviado';

  @override
  String get nothingNewToSend => 'Nada nuevo que enviar';

  @override
  String get deviceName => 'Nombre del dispositivo';

  @override
  String get deviceNameExplanation => 'Cómo ven este dispositivo los demás.';

  @override
  String get syncClipboard => 'Sincronizar portapapeles';

  @override
  String get syncClipboardExplanation =>
      'Enviar y recibir elementos con dispositivos vinculados.';

  @override
  String get readClipboardOnOpen => 'Leer portapapeles al abrir';

  @override
  String get readClipboardOnOpenExplanation =>
      'Comprobar el portapapeles automáticamente cuando la app pase a primer plano.';

  @override
  String get keepSyncingInBackground => 'Seguir sincronizando en segundo plano';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Sigue conectado cuando Plokee está minimizado. Muestra una notificación permanente.';

  @override
  String get couldNotStart => 'No se pudo iniciar';

  @override
  String get trayOpenPlokee => 'Abrir Plokee';

  @override
  String get trayCheckClipboardNow => 'Comprobar portapapeles ahora';

  @override
  String get trayRecentClipboard => 'Portapapeles reciente';

  @override
  String get traySyncClipboard => 'Sincronizar portapapeles';

  @override
  String get trayQuit => 'Salir';

  @override
  String get traySyncIsOn => 'Sinc. activada';

  @override
  String get traySyncIsPaused => 'Sinc. en pausa';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online de $total dispositivos en línea';
  }

  @override
  String get notificationChannelName => 'Sincronización del portapapeles';

  @override
  String get notificationChannelDescription =>
      'Mantiene Plokee conectado a tus dispositivos vinculados.';

  @override
  String get notificationTitle => 'Plokee está sincronizando';

  @override
  String get notificationText => 'Conectado a tus dispositivos vinculados';
}

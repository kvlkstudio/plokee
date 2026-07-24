// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Подключено';

  @override
  String get statusConnecting => 'Подключение…';

  @override
  String get statusIdle => 'Ожидание';

  @override
  String get statusOffline => 'Не в сети';

  @override
  String get statusPaired => 'Сопряжено';

  @override
  String connectedDevices(int count) {
    return '$count на связи';
  }

  @override
  String get sync => 'Синх.';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get languageSystem => 'Системный';

  @override
  String get devices => 'Устройства';

  @override
  String get history => 'История';

  @override
  String get cancel => 'Отмена';

  @override
  String get clear => 'Очистить';

  @override
  String get done => 'Готово';

  @override
  String get pair => 'Связать';

  @override
  String get unpair => 'Разорвать';

  @override
  String get decline => 'Отклонить';

  @override
  String get save => 'Сохранить';

  @override
  String get share => 'Поделиться';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get lookingForDevices => 'Поиск устройств…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Откройте Plokee на другом устройстве\nв той же сети.';

  @override
  String newDeviceAt(String address) {
    return 'Новое · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Связывание с «$name»';
  }

  @override
  String get pairingRequest => 'Запрос на связывание';

  @override
  String get pairingFailed => 'Не удалось связать';

  @override
  String get confirmOnOtherDevice =>
      'Подтвердите на другом устройстве. На обоих должен быть этот код:';

  @override
  String wantsToPair(String name, String platform) {
    return '«$name» ($platform) хочет связаться.';
  }

  @override
  String nowConnected(String name) {
    return '«$name» подключено. Буфер обмена будет синхронизироваться автоматически.';
  }

  @override
  String get makeSureSameCode =>
      'Убедитесь, что на обоих устройствах один и тот же код:';

  @override
  String get requestDeclinedOrTimedOut => 'Запрос отклонён или истёк.';

  @override
  String get nothingCopiedYet => 'Пока ничего не скопировано';

  @override
  String get copiesShowUpHere =>
      'Скопированное появится здесь и синхронизируется\nсо связанными устройствами.';

  @override
  String get clearHistory => 'Очистить историю';

  @override
  String get clearHistoryQuestion => 'Очистить историю?';

  @override
  String get clearHistoryExplanation =>
      'Будут удалены все сохранённые записи на этом устройстве. У связанных устройств своя история.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'От $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Изображение ($size)';
  }

  @override
  String get openInBrowser => 'Открыть в браузере';

  @override
  String get writeEmail => 'Написать письмо';

  @override
  String get saveImage => 'Сохранить изображение';

  @override
  String get showInFolder => 'Показать в папке';

  @override
  String get imageSaved => 'Изображение сохранено';

  @override
  String get couldNotSaveImage => 'Не удалось сохранить изображение';

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get couldNotOpenFolder => 'Не удалось открыть папку';

  @override
  String get imageNoLongerAvailable => 'Это изображение больше недоступно';

  @override
  String get filesNoLongerAvailable => 'Эти файлы больше недоступны';

  @override
  String get sendClipboard => 'Отправить буфер';

  @override
  String get clipboardSent => 'Буфер отправлен';

  @override
  String get nothingNewToSend => 'Нечего отправлять';

  @override
  String get deviceName => 'Имя устройства';

  @override
  String get deviceNameExplanation => 'Так это устройство видят другие.';

  @override
  String get syncClipboard => 'Синхронизация буфера';

  @override
  String get syncClipboardExplanation =>
      'Отправлять и получать записи со связанными устройствами.';

  @override
  String get readClipboardOnOpen => 'Читать буфер при открытии';

  @override
  String get readClipboardOnOpenExplanation =>
      'Автоматически проверять буфер обмена, когда приложение выходит на передний план.';

  @override
  String get keepSyncingInBackground => 'Синхронизировать в фоне';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Оставаться на связи, когда Plokee свёрнут. Показывает постоянное уведомление.';

  @override
  String get couldNotStart => 'Не удалось запустить';

  @override
  String get trayOpenPlokee => 'Открыть Plokee';

  @override
  String get trayCheckClipboardNow => 'Проверить буфер сейчас';

  @override
  String get trayRecentClipboard => 'Недавние записи';

  @override
  String get traySyncClipboard => 'Синхронизация буфера';

  @override
  String get trayQuit => 'Выйти';

  @override
  String get traySyncIsOn => 'Синхронизация включена';

  @override
  String get traySyncIsPaused => 'Синхронизация на паузе';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online из $total устройств на связи';
  }

  @override
  String get notificationChannelName => 'Синхронизация буфера обмена';

  @override
  String get notificationChannelDescription =>
      'Держит Plokee на связи со связанными устройствами.';

  @override
  String get notificationTitle => 'Plokee синхронизирует';

  @override
  String get notificationText => 'На связи со связанными устройствами';
}

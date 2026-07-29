// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'З’єднано';

  @override
  String get statusConnecting => 'З’єднання…';

  @override
  String get statusIdle => 'Очікування';

  @override
  String get statusOffline => 'Не в мережі';

  @override
  String get statusPaired => 'Сполучено';

  @override
  String connectedDevices(int count) {
    return '$count на зв’язку';
  }

  @override
  String get sync => 'Синх.';

  @override
  String get settings => 'Налаштування';

  @override
  String get language => 'Мова';

  @override
  String get languageSystem => 'Системна';

  @override
  String get devices => 'Пристрої';

  @override
  String get history => 'Історія';

  @override
  String get cancel => 'Скасувати';

  @override
  String get clear => 'Очистити';

  @override
  String get done => 'Готово';

  @override
  String get pair => 'Сполучити';

  @override
  String get unpair => 'Роз’єднати';

  @override
  String get decline => 'Відхилити';

  @override
  String get save => 'Зберегти';

  @override
  String get share => 'Поділитися';

  @override
  String get copy => 'Копіювати';

  @override
  String get copied => 'Скопійовано';

  @override
  String get lookingForDevices => 'Пошук пристроїв…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Відкрийте Plokee на іншому пристрої\nу цій же мережі.';

  @override
  String newDeviceAt(String address) {
    return 'Новий · $address';
  }

  @override
  String pairingWith(String name) {
    return 'Сполучення з «$name»';
  }

  @override
  String get pairingRequest => 'Запит на сполучення';

  @override
  String get pairingFailed => 'Не вдалося сполучити';

  @override
  String get confirmOnOtherDevice =>
      'Підтвердьте на іншому пристрої. На обох має бути цей код:';

  @override
  String wantsToPair(String name, String platform) {
    return '«$name» ($platform) хоче сполучитися.';
  }

  @override
  String nowConnected(String name) {
    return '«$name» під’єднано. Ваш буфер обміну синхронізуватиметься автоматично.';
  }

  @override
  String get makeSureSameCode =>
      'Переконайтеся, що на обох пристроях однаковий код:';

  @override
  String get requestDeclinedOrTimedOut => 'Запит відхилено або час вичерпано.';

  @override
  String get addByIp => 'Пристрій не видно? Додати за IP';

  @override
  String get addByIpTitle => 'Додати пристрій за IP';

  @override
  String get addByIpExplanation =>
      'Деякі мережі приховують пристрої один від одного. Введіть IP-адресу іншого пристрою, щоб сполучитися напряму.';

  @override
  String get ipAddress => 'IP-адреса';

  @override
  String get add => 'Додати';

  @override
  String get searching => 'Пошук…';

  @override
  String thisDeviceAddress(String address) {
    return 'Цей пристрій: $address';
  }

  @override
  String noDeviceAtIp(String address) {
    return 'За адресою $address пристрій Plokee не знайдено';
  }

  @override
  String get nothingCopiedYet => 'Ще нічого не скопійовано';

  @override
  String get copiesShowUpHere =>
      'Скопійоване з’явиться тут і синхронізується\nз вашими сполученими пристроями.';

  @override
  String get clearHistory => 'Очистити історію';

  @override
  String get clearHistoryQuestion => 'Очистити історію?';

  @override
  String get clearHistoryExplanation =>
      'Це вилучить усі збережені записи на цьому пристрої. Сполучені пристрої мають власну історію.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'Від $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Зображення ($size)';
  }

  @override
  String get openInBrowser => 'Відкрити у браузері';

  @override
  String get writeEmail => 'Написати листа';

  @override
  String get saveImage => 'Зберегти зображення';

  @override
  String get showInFolder => 'Показати в теці';

  @override
  String get imageSaved => 'Зображення збережено';

  @override
  String get couldNotSaveImage => 'Не вдалося зберегти зображення';

  @override
  String get couldNotOpenLink => 'Не вдалося відкрити посилання';

  @override
  String get couldNotOpenFolder => 'Не вдалося відкрити теку';

  @override
  String get imageNoLongerAvailable => 'Це зображення більше недоступне';

  @override
  String get filesNoLongerAvailable => 'Ці файли більше недоступні';

  @override
  String get sendClipboard => 'Надіслати буфер';

  @override
  String get clipboardSent => 'Буфер надіслано';

  @override
  String get nothingNewToSend => 'Немає нічого нового';

  @override
  String get deviceName => 'Назва пристрою';

  @override
  String get deviceNameExplanation => 'Так цей пристрій бачать інші.';

  @override
  String get syncClipboard => 'Синхронізація буфера';

  @override
  String get syncClipboardExplanation =>
      'Надсилати й отримувати записи зі сполученими пристроями.';

  @override
  String get readClipboardOnOpen => 'Читати буфер під час відкриття';

  @override
  String get readClipboardOnOpenExplanation =>
      'Автоматично перевіряти буфер обміну, коли застосунок виходить на передній план.';

  @override
  String get keepSyncingInBackground => 'Синхронізувати у фоні';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Залишатися на зв’язку, коли Plokee згорнуто. Показує постійне сповіщення.';

  @override
  String get couldNotStart => 'Не вдалося запустити';

  @override
  String get trayOpenPlokee => 'Відкрити Plokee';

  @override
  String get trayCheckClipboardNow => 'Перевірити буфер зараз';

  @override
  String get trayRecentClipboard => 'Нещодавні записи';

  @override
  String get traySyncClipboard => 'Синхронізація буфера';

  @override
  String get trayQuit => 'Вийти';

  @override
  String get traySyncIsOn => 'Синхронізацію ввімкнено';

  @override
  String get traySyncIsPaused => 'Синхронізацію призупинено';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online з $total пристроїв на зв’язку';
  }

  @override
  String get notificationChannelName => 'Синхронізація буфера обміну';

  @override
  String get notificationChannelDescription =>
      'Тримає Plokee на зв’язку зі сполученими пристроями.';

  @override
  String get notificationTitle => 'Plokee синхронізує';

  @override
  String get notificationText => 'На зв’язку зі сполученими пристроями';

  @override
  String notificationConnected(int count, int total) {
    return 'На зв’язку $count з $total пристроїв';
  }

  @override
  String get notificationPaused => 'Синхронізацію призупинено';

  @override
  String get notificationPause => 'Пауза';

  @override
  String get notificationResume => 'Продовжити';

  @override
  String get syncRules => 'Правила синхронізації';

  @override
  String syncRulesFor(String name) {
    return 'Що цей пристрій синхронізує з «$name»';
  }

  @override
  String get ruleSendTo => 'Надсилати йому';

  @override
  String get ruleSendToExplanation =>
      'Передавати скопійоване тут на цей пристрій.';

  @override
  String get ruleReceiveFrom => 'Отримувати від нього';

  @override
  String get ruleReceiveFromExplanation =>
      'Застосовувати скопійоване там до цього буфера обміну.';

  @override
  String get ruleKinds => 'Типи';

  @override
  String get ruleText => 'Текст';

  @override
  String get ruleImages => 'Зображення';

  @override
  String get ruleFiles => 'Файли';

  @override
  String get ruleSummaryNothing => 'Нічого';

  @override
  String get ruleSummaryReceiveOnly => 'Лише приймання';

  @override
  String get ruleSummarySendOnly => 'Лише надсилання';

  @override
  String get ruleSummaryCustom => 'Власні правила';

  @override
  String get transfers => 'Передавання';

  @override
  String transferSendingTo(String name) {
    return 'Надсилання на $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return 'Отримання від $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done з $total';
  }

  @override
  String get transferText => 'Текст';

  @override
  String get transferImage => 'Зображення';
}

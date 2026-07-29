// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'متصل';

  @override
  String get statusConnecting => 'جارٍ الاتصال…';

  @override
  String get statusIdle => 'خامل';

  @override
  String get statusOffline => 'غير متصل';

  @override
  String get statusPaired => 'مقترن';

  @override
  String connectedDevices(int count) {
    return '$count متصل';
  }

  @override
  String get sync => 'مزامنة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'النظام';

  @override
  String get devices => 'الأجهزة';

  @override
  String get history => 'السجل';

  @override
  String get cancel => 'إلغاء';

  @override
  String get clear => 'مسح';

  @override
  String get done => 'تم';

  @override
  String get pair => 'اقتران';

  @override
  String get unpair => 'إلغاء الاقتران';

  @override
  String get decline => 'رفض';

  @override
  String get save => 'حفظ';

  @override
  String get share => 'مشاركة';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get lookingForDevices => 'جارٍ البحث عن الأجهزة…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'افتح Plokee على جهاز آخر\nعلى الشبكة نفسها.';

  @override
  String newDeviceAt(String address) {
    return 'جديد · $address';
  }

  @override
  String pairingWith(String name) {
    return 'الاقتران بـ ”$name“';
  }

  @override
  String get pairingRequest => 'طلب اقتران';

  @override
  String get pairingFailed => 'فشل الاقتران';

  @override
  String get confirmOnOtherDevice =>
      'أكّد على الجهاز الآخر. يجب أن يعرض كلا الجهازين هذا الرمز:';

  @override
  String wantsToPair(String name, String platform) {
    return '”$name“ ($platform) يريد الاقتران.';
  }

  @override
  String nowConnected(String name) {
    return '”$name“ متصل الآن. ستتم مزامنة الحافظة تلقائيًا.';
  }

  @override
  String get makeSureSameCode => 'تأكّد من أن كلا الجهازين يعرضان الرمز نفسه:';

  @override
  String get requestDeclinedOrTimedOut => 'تم رفض الطلب أو انتهت مهلته.';

  @override
  String get addByIp => 'الجهاز لا يظهر؟ أضِفه عبر IP';

  @override
  String get addByIpTitle => 'إضافة جهاز عبر IP';

  @override
  String get addByIpExplanation =>
      'بعض الشبكات تخفي الأجهزة عن بعضها. أدخل عنوان IP للجهاز الآخر للاقتران مباشرة.';

  @override
  String get ipAddress => 'عنوان IP';

  @override
  String get add => 'إضافة';

  @override
  String get searching => 'جارٍ البحث…';

  @override
  String thisDeviceAddress(String address) {
    return 'هذا الجهاز: $address';
  }

  @override
  String noDeviceAtIp(String address) {
    return 'لم يُعثر على جهاز Plokee على $address';
  }

  @override
  String get nothingCopiedYet => 'لم يتم نسخ أي شيء بعد';

  @override
  String get copiesShowUpHere =>
      'يظهر ما تنسخه هنا وتتم مزامنته\nمع أجهزتك المقترنة.';

  @override
  String get clearHistory => 'مسح السجل';

  @override
  String get clearHistoryQuestion => 'مسح السجل؟';

  @override
  String get clearHistoryExplanation =>
      'سيؤدي هذا إلى حذف كل العناصر المحفوظة على هذا الجهاز. تحتفظ الأجهزة المقترنة بسجلها الخاص.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return 'من $name · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'صورة ($size)';
  }

  @override
  String get openInBrowser => 'فتح في المتصفح';

  @override
  String get writeEmail => 'كتابة بريد';

  @override
  String get saveImage => 'حفظ الصورة';

  @override
  String get showInFolder => 'إظهار في المجلد';

  @override
  String get imageSaved => 'تم حفظ الصورة';

  @override
  String get couldNotSaveImage => 'تعذّر حفظ الصورة';

  @override
  String get couldNotOpenLink => 'تعذّر فتح الرابط';

  @override
  String get couldNotOpenFolder => 'تعذّر فتح المجلد';

  @override
  String get imageNoLongerAvailable => 'لم تعد هذه الصورة متوفرة';

  @override
  String get filesNoLongerAvailable => 'لم تعد هذه الملفات متوفرة';

  @override
  String get sendClipboard => 'إرسال الحافظة';

  @override
  String get clipboardSent => 'تم إرسال الحافظة';

  @override
  String get nothingNewToSend => 'لا جديد لإرساله';

  @override
  String get deviceName => 'اسم الجهاز';

  @override
  String get deviceNameExplanation => 'الاسم الذي يظهر به هذا الجهاز للآخرين.';

  @override
  String get syncClipboard => 'مزامنة الحافظة';

  @override
  String get syncClipboardExplanation =>
      'إرسال العناصر واستقبالها مع الأجهزة المقترنة.';

  @override
  String get readClipboardOnOpen => 'قراءة الحافظة عند الفتح';

  @override
  String get readClipboardOnOpenExplanation =>
      'فحص الحافظة تلقائيًا عند عودة التطبيق إلى الواجهة.';

  @override
  String get keepSyncingInBackground => 'متابعة المزامنة في الخلفية';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'ابقَ متصلًا عندما يكون Plokee مصغّرًا. يعرض إشعارًا دائمًا.';

  @override
  String get couldNotStart => 'تعذّر البدء';

  @override
  String get trayOpenPlokee => 'فتح Plokee';

  @override
  String get trayCheckClipboardNow => 'فحص الحافظة الآن';

  @override
  String get trayRecentClipboard => 'الحافظة الأخيرة';

  @override
  String get traySyncClipboard => 'مزامنة الحافظة';

  @override
  String get trayQuit => 'إنهاء';

  @override
  String get traySyncIsOn => 'المزامنة مفعّلة';

  @override
  String get traySyncIsPaused => 'المزامنة متوقفة مؤقتًا';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $online من $total أجهزة متصلة';
  }

  @override
  String get notificationChannelName => 'مزامنة الحافظة';

  @override
  String get notificationChannelDescription =>
      'تُبقي Plokee متصلًا بأجهزتك المقترنة.';

  @override
  String get notificationTitle => 'Plokee يقوم بالمزامنة';

  @override
  String get notificationText => 'متصل بأجهزتك المقترنة';

  @override
  String notificationConnected(int count, int total) {
    return '$count من $total أجهزة متصلة';
  }

  @override
  String get notificationPaused => 'المزامنة متوقفة مؤقتًا';

  @override
  String get notificationPause => 'إيقاف مؤقت';

  @override
  String get notificationResume => 'استئناف';

  @override
  String get syncRules => 'قواعد المزامنة';

  @override
  String syncRulesFor(String name) {
    return 'ما يزامنه هذا الجهاز مع ”$name“';
  }

  @override
  String get ruleSendTo => 'الإرسال إليه';

  @override
  String get ruleSendToExplanation => 'إرسال ما تنسخه هنا إلى ذلك الجهاز.';

  @override
  String get ruleReceiveFrom => 'الاستقبال منه';

  @override
  String get ruleReceiveFromExplanation =>
      'تطبيق ما يُنسخ هناك على هذه الحافظة.';

  @override
  String get ruleKinds => 'الأنواع';

  @override
  String get ruleText => 'نص';

  @override
  String get ruleImages => 'صور';

  @override
  String get ruleFiles => 'ملفات';

  @override
  String get ruleSummaryNothing => 'لا شيء';

  @override
  String get ruleSummaryReceiveOnly => 'الاستقبال فقط';

  @override
  String get ruleSummarySendOnly => 'الإرسال فقط';

  @override
  String get ruleSummaryCustom => 'مخصص';

  @override
  String get transfers => 'عمليات النقل';

  @override
  String transferSendingTo(String name) {
    return 'جارٍ الإرسال إلى $name';
  }

  @override
  String transferReceivingFrom(String name) {
    return 'جارٍ الاستقبال من $name';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done من $total';
  }

  @override
  String get transferText => 'نص';

  @override
  String get transferImage => 'صورة';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'Bağlandı';

  @override
  String get statusConnecting => 'Bağlanıyor…';

  @override
  String get statusIdle => 'Boşta';

  @override
  String get statusOffline => 'Çevrimdışı';

  @override
  String get statusPaired => 'Eşleşti';

  @override
  String connectedDevices(int count) {
    return '$count bağlı';
  }

  @override
  String get sync => 'Eşitleme';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get devices => 'Cihazlar';

  @override
  String get history => 'Geçmiş';

  @override
  String get cancel => 'İptal';

  @override
  String get clear => 'Temizle';

  @override
  String get done => 'Tamam';

  @override
  String get pair => 'Eşleştir';

  @override
  String get unpair => 'Eşleştirmeyi kaldır';

  @override
  String get decline => 'Reddet';

  @override
  String get save => 'Kaydet';

  @override
  String get share => 'Paylaş';

  @override
  String get copy => 'Kopyala';

  @override
  String get copied => 'Kopyalandı';

  @override
  String get lookingForDevices => 'Cihazlar aranıyor…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'Aynı ağdaki başka bir cihazda\nPlokee’yi açın.';

  @override
  String newDeviceAt(String address) {
    return 'Yeni · $address';
  }

  @override
  String pairingWith(String name) {
    return '“$name” ile eşleştiriliyor';
  }

  @override
  String get pairingRequest => 'Eşleştirme isteği';

  @override
  String get pairingFailed => 'Eşleştirme başarısız';

  @override
  String get confirmOnOtherDevice =>
      'Diğer cihazda onaylayın. Her iki cihaz da bu kodu göstermeli:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) eşleşmek istiyor.';
  }

  @override
  String nowConnected(String name) {
    return '“$name” artık bağlı. Panonuz otomatik olarak eşitlenecek.';
  }

  @override
  String get makeSureSameCode =>
      'Her iki cihazın da aynı kodu gösterdiğinden emin olun:';

  @override
  String get requestDeclinedOrTimedOut =>
      'İstek reddedildi veya zaman aşımına uğradı.';

  @override
  String get addByIp => 'Cihaz görünmüyor mu? IP ile ekle';

  @override
  String get addByIpTitle => 'IP ile cihaz ekle';

  @override
  String get addByIpExplanation =>
      'Bazı ağlar cihazları birbirinden gizler. Doğrudan eşleştirmek için diğer cihazın IP adresini girin.';

  @override
  String get ipAddress => 'IP adresi';

  @override
  String get add => 'Ekle';

  @override
  String get searching => 'Aranıyor…';

  @override
  String thisDeviceAddress(String address) {
    return 'Bu cihaz: $address';
  }

  @override
  String noDeviceAtIp(String address) {
    return '$address adresinde Plokee cihazı bulunamadı';
  }

  @override
  String get nothingCopiedYet => 'Henüz bir şey kopyalanmadı';

  @override
  String get copiesShowUpHere =>
      'Kopyaladıklarınız burada görünür ve eşleştirilmiş\ncihazlarınızla eşitlenir.';

  @override
  String get clearHistory => 'Geçmişi temizle';

  @override
  String get clearHistoryQuestion => 'Geçmiş temizlensin mi?';

  @override
  String get clearHistoryExplanation =>
      'Bu, bu cihazdaki tüm kayıtlı öğeleri siler. Eşleştirilmiş cihazlar kendi geçmişlerini korur.';

  @override
  String fromDeviceAtTime(String name, String time) {
    return '$name cihazından · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'Görsel ($size)';
  }

  @override
  String get openInBrowser => 'Tarayıcıda aç';

  @override
  String get writeEmail => 'E-posta yaz';

  @override
  String get saveImage => 'Görseli kaydet';

  @override
  String get showInFolder => 'Klasörde göster';

  @override
  String get imageSaved => 'Görsel kaydedildi';

  @override
  String get couldNotSaveImage => 'Görsel kaydedilemedi';

  @override
  String get couldNotOpenLink => 'Bağlantı açılamadı';

  @override
  String get couldNotOpenFolder => 'Klasör açılamadı';

  @override
  String get imageNoLongerAvailable => 'Bu görsel artık kullanılamıyor';

  @override
  String get filesNoLongerAvailable => 'Bu dosyalar artık kullanılamıyor';

  @override
  String get sendClipboard => 'Panoyu gönder';

  @override
  String get clipboardSent => 'Pano gönderildi';

  @override
  String get nothingNewToSend => 'Gönderilecek yeni bir şey yok';

  @override
  String get deviceName => 'Cihaz adı';

  @override
  String get deviceNameExplanation => 'Bu cihazın başkalarına nasıl göründüğü.';

  @override
  String get syncClipboard => 'Panoyu eşitle';

  @override
  String get syncClipboardExplanation =>
      'Eşleştirilmiş cihazlarla öğe gönderin ve alın.';

  @override
  String get readClipboardOnOpen => 'Açılışta panoyu oku';

  @override
  String get readClipboardOnOpenExplanation =>
      'Uygulama öne geldiğinde panoyu otomatik olarak kontrol et.';

  @override
  String get keepSyncingInBackground => 'Arka planda eşitlemeye devam et';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Plokee simge durumundayken bağlı kalın. Kalıcı bir bildirim gösterir.';

  @override
  String get couldNotStart => 'Başlatılamadı';

  @override
  String get trayOpenPlokee => 'Plokee’yi aç';

  @override
  String get trayCheckClipboardNow => 'Panoyu şimdi kontrol et';

  @override
  String get trayRecentClipboard => 'Son panolar';

  @override
  String get traySyncClipboard => 'Panoyu eşitle';

  @override
  String get trayQuit => 'Çık';

  @override
  String get traySyncIsOn => 'Eşitleme açık';

  @override
  String get traySyncIsPaused => 'Eşitleme duraklatıldı';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $total cihazdan $online tanesi çevrimiçi';
  }

  @override
  String get notificationChannelName => 'Pano eşitleme';

  @override
  String get notificationChannelDescription =>
      'Plokee’yi eşleştirilmiş cihazlarınıza bağlı tutar.';

  @override
  String get notificationTitle => 'Plokee eşitleniyor';

  @override
  String get notificationText => 'Eşleştirilmiş cihazlarınıza bağlı';

  @override
  String notificationConnected(int count, int total) {
    return '$total cihazdan $count tanesi bağlı';
  }

  @override
  String get notificationPaused => 'Eşitleme duraklatıldı';

  @override
  String get notificationPause => 'Duraklat';

  @override
  String get notificationResume => 'Sürdür';

  @override
  String get syncRules => 'Eşitleme kuralları';

  @override
  String syncRulesFor(String name) {
    return 'Bu cihazın “$name” ile eşitledikleri';
  }

  @override
  String get ruleSendTo => 'Ona gönder';

  @override
  String get ruleSendToExplanation =>
      'Burada kopyaladıklarını o cihaza gönder.';

  @override
  String get ruleReceiveFrom => 'Ondan al';

  @override
  String get ruleReceiveFromExplanation =>
      'Orada kopyalananları bu panoya uygula.';

  @override
  String get ruleKinds => 'Türler';

  @override
  String get ruleText => 'Metin';

  @override
  String get ruleImages => 'Görseller';

  @override
  String get ruleFiles => 'Dosyalar';

  @override
  String get ruleSummaryNothing => 'Hiçbiri';

  @override
  String get ruleSummaryReceiveOnly => 'Yalnızca alma';

  @override
  String get ruleSummarySendOnly => 'Yalnızca gönderme';

  @override
  String get ruleSummaryCustom => 'Özel';

  @override
  String get transfers => 'Aktarımlar';

  @override
  String transferSendingTo(String name) {
    return '$name cihazına gönderiliyor';
  }

  @override
  String transferReceivingFrom(String name) {
    return '$name cihazından alınıyor';
  }

  @override
  String transferProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get transferText => 'Metin';

  @override
  String get transferImage => 'Görsel';
}

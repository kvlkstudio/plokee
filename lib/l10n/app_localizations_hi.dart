// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Plokee';

  @override
  String get statusConnected => 'कनेक्टेड';

  @override
  String get statusConnecting => 'कनेक्ट हो रहा है…';

  @override
  String get statusIdle => 'निष्क्रिय';

  @override
  String get statusOffline => 'ऑफ़लाइन';

  @override
  String get statusPaired => 'पेयर किया गया';

  @override
  String connectedDevices(int count) {
    return '$count कनेक्टेड';
  }

  @override
  String get sync => 'सिंक';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get languageSystem => 'सिस्टम';

  @override
  String get devices => 'डिवाइस';

  @override
  String get history => 'इतिहास';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get done => 'हो गया';

  @override
  String get pair => 'पेयर करें';

  @override
  String get unpair => 'अनपेयर करें';

  @override
  String get decline => 'अस्वीकार करें';

  @override
  String get save => 'सहेजें';

  @override
  String get share => 'साझा करें';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get copied => 'कॉपी हो गया';

  @override
  String get lookingForDevices => 'डिवाइस खोजे जा रहे हैं…';

  @override
  String get openPlokeeOnAnotherDevice =>
      'उसी नेटवर्क के दूसरे डिवाइस पर\nPlokee खोलें।';

  @override
  String newDeviceAt(String address) {
    return 'नया · $address';
  }

  @override
  String pairingWith(String name) {
    return '“$name” के साथ पेयरिंग';
  }

  @override
  String get pairingRequest => 'पेयरिंग अनुरोध';

  @override
  String get pairingFailed => 'पेयरिंग विफल';

  @override
  String get confirmOnOtherDevice =>
      'दूसरे डिवाइस पर पुष्टि करें। दोनों डिवाइस पर यही कोड दिखना चाहिए:';

  @override
  String wantsToPair(String name, String platform) {
    return '“$name” ($platform) पेयर करना चाहता है।';
  }

  @override
  String nowConnected(String name) {
    return '“$name” अब कनेक्टेड है। आपका क्लिपबोर्ड अपने आप सिंक होगा।';
  }

  @override
  String get makeSureSameCode =>
      'सुनिश्चित करें कि दोनों डिवाइस पर एक ही कोड दिख रहा है:';

  @override
  String get requestDeclinedOrTimedOut =>
      'अनुरोध अस्वीकार कर दिया गया या समय समाप्त हो गया।';

  @override
  String get nothingCopiedYet => 'अभी तक कुछ कॉपी नहीं किया';

  @override
  String get copiesShowUpHere =>
      'आपकी कॉपी यहाँ दिखेगी और आपके\nपेयर किए गए डिवाइस से सिंक होगी।';

  @override
  String get clearHistory => 'इतिहास साफ़ करें';

  @override
  String get clearHistoryQuestion => 'इतिहास साफ़ करें?';

  @override
  String get clearHistoryExplanation =>
      'इससे इस डिवाइस पर सहेजी गई सभी प्रविष्टियाँ हट जाएँगी। पेयर किए गए डिवाइस अपना इतिहास रखते हैं।';

  @override
  String fromDeviceAtTime(String name, String time) {
    return '$name से · $time';
  }

  @override
  String imageWithSize(String size) {
    return 'छवि ($size)';
  }

  @override
  String get openInBrowser => 'ब्राउज़र में खोलें';

  @override
  String get writeEmail => 'ईमेल लिखें';

  @override
  String get saveImage => 'छवि सहेजें';

  @override
  String get showInFolder => 'फ़ोल्डर में दिखाएँ';

  @override
  String get imageSaved => 'छवि सहेजी गई';

  @override
  String get couldNotSaveImage => 'छवि सहेजी नहीं जा सकी';

  @override
  String get couldNotOpenLink => 'लिंक खोला नहीं जा सका';

  @override
  String get couldNotOpenFolder => 'फ़ोल्डर खोला नहीं जा सका';

  @override
  String get imageNoLongerAvailable => 'यह छवि अब उपलब्ध नहीं है';

  @override
  String get filesNoLongerAvailable => 'ये फ़ाइलें अब उपलब्ध नहीं हैं';

  @override
  String get sendClipboard => 'क्लिपबोर्ड भेजें';

  @override
  String get clipboardSent => 'क्लिपबोर्ड भेजा गया';

  @override
  String get nothingNewToSend => 'भेजने के लिए कुछ नया नहीं';

  @override
  String get deviceName => 'डिवाइस का नाम';

  @override
  String get deviceNameExplanation => 'दूसरों को यह डिवाइस इस नाम से दिखता है।';

  @override
  String get syncClipboard => 'क्लिपबोर्ड सिंक करें';

  @override
  String get syncClipboardExplanation =>
      'पेयर किए गए डिवाइस के साथ सामग्री भेजें और प्राप्त करें।';

  @override
  String get readClipboardOnOpen => 'खोलने पर क्लिपबोर्ड पढ़ें';

  @override
  String get readClipboardOnOpenExplanation =>
      'ऐप के सामने आने पर क्लिपबोर्ड अपने आप जाँचें।';

  @override
  String get keepSyncingInBackground => 'बैकग्राउंड में सिंक जारी रखें';

  @override
  String get keepSyncingInBackgroundExplanation =>
      'Plokee छोटा होने पर भी कनेक्टेड रहें। एक स्थायी सूचना दिखती है।';

  @override
  String get couldNotStart => 'शुरू नहीं हो सका';

  @override
  String get trayOpenPlokee => 'Plokee खोलें';

  @override
  String get trayCheckClipboardNow => 'अभी क्लिपबोर्ड जाँचें';

  @override
  String get trayRecentClipboard => 'हाल का क्लिपबोर्ड';

  @override
  String get traySyncClipboard => 'क्लिपबोर्ड सिंक करें';

  @override
  String get trayQuit => 'बंद करें';

  @override
  String get traySyncIsOn => 'सिंक चालू है';

  @override
  String get traySyncIsPaused => 'सिंक रोका गया';

  @override
  String trayStatusLine(String status, int online, int total) {
    return '$status · $total में से $online डिवाइस ऑनलाइन';
  }

  @override
  String get notificationChannelName => 'क्लिपबोर्ड सिंक';

  @override
  String get notificationChannelDescription =>
      'Plokee को आपके पेयर किए गए डिवाइस से जुड़ा रखता है।';

  @override
  String get notificationTitle => 'Plokee सिंक कर रहा है';

  @override
  String get notificationText => 'आपके पेयर किए गए डिवाइस से कनेक्टेड';
}

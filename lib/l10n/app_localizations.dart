import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Application name, shown in the window title and header.
  ///
  /// In en, this message translates to:
  /// **'Plokee'**
  String get appTitle;

  /// No description provided for @statusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get statusConnected;

  /// No description provided for @statusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get statusConnecting;

  /// No description provided for @statusIdle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get statusIdle;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @statusPaired.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get statusPaired;

  /// No description provided for @connectedDevices.
  ///
  /// In en, this message translates to:
  /// **'{count} connected'**
  String connectedDevices(int count);

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pair;

  /// No description provided for @unpair.
  ///
  /// In en, this message translates to:
  /// **'Unpair'**
  String get unpair;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @lookingForDevices.
  ///
  /// In en, this message translates to:
  /// **'Looking for devices…'**
  String get lookingForDevices;

  /// No description provided for @openPlokeeOnAnotherDevice.
  ///
  /// In en, this message translates to:
  /// **'Open Plokee on another device\non the same network.'**
  String get openPlokeeOnAnotherDevice;

  /// No description provided for @newDeviceAt.
  ///
  /// In en, this message translates to:
  /// **'New · {address}'**
  String newDeviceAt(String address);

  /// No description provided for @pairingWith.
  ///
  /// In en, this message translates to:
  /// **'Pairing with “{name}”'**
  String pairingWith(String name);

  /// No description provided for @pairingRequest.
  ///
  /// In en, this message translates to:
  /// **'Pairing request'**
  String get pairingRequest;

  /// No description provided for @pairingFailed.
  ///
  /// In en, this message translates to:
  /// **'Pairing failed'**
  String get pairingFailed;

  /// No description provided for @confirmOnOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Confirm on the other device. Both devices should show this code:'**
  String get confirmOnOtherDevice;

  /// No description provided for @wantsToPair.
  ///
  /// In en, this message translates to:
  /// **'“{name}” ({platform}) wants to pair.'**
  String wantsToPair(String name, String platform);

  /// No description provided for @nowConnected.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is now connected. Your clipboard will sync automatically.'**
  String nowConnected(String name);

  /// No description provided for @makeSureSameCode.
  ///
  /// In en, this message translates to:
  /// **'Make sure both devices show the same code:'**
  String get makeSureSameCode;

  /// No description provided for @requestDeclinedOrTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The request was declined or timed out.'**
  String get requestDeclinedOrTimedOut;

  /// No description provided for @nothingCopiedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing copied yet'**
  String get nothingCopiedYet;

  /// No description provided for @copiesShowUpHere.
  ///
  /// In en, this message translates to:
  /// **'Copies show up here and sync\nto your paired devices.'**
  String get copiesShowUpHere;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @clearHistoryQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get clearHistoryQuestion;

  /// No description provided for @clearHistoryExplanation.
  ///
  /// In en, this message translates to:
  /// **'This removes all saved clips on this device. Paired devices keep their own history.'**
  String get clearHistoryExplanation;

  /// No description provided for @fromDeviceAtTime.
  ///
  /// In en, this message translates to:
  /// **'From {name} · {time}'**
  String fromDeviceAtTime(String name, String time);

  /// No description provided for @imageWithSize.
  ///
  /// In en, this message translates to:
  /// **'Image ({size})'**
  String imageWithSize(String size);

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser'**
  String get openInBrowser;

  /// No description provided for @writeEmail.
  ///
  /// In en, this message translates to:
  /// **'Write email'**
  String get writeEmail;

  /// No description provided for @saveImage.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get saveImage;

  /// No description provided for @showInFolder.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get showInFolder;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved'**
  String get imageSaved;

  /// No description provided for @couldNotSaveImage.
  ///
  /// In en, this message translates to:
  /// **'Could not save the image'**
  String get couldNotSaveImage;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get couldNotOpenLink;

  /// No description provided for @couldNotOpenFolder.
  ///
  /// In en, this message translates to:
  /// **'Could not open the folder'**
  String get couldNotOpenFolder;

  /// No description provided for @imageNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This image is no longer available'**
  String get imageNoLongerAvailable;

  /// No description provided for @filesNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'These files are no longer available'**
  String get filesNoLongerAvailable;

  /// No description provided for @sendClipboard.
  ///
  /// In en, this message translates to:
  /// **'Send clipboard'**
  String get sendClipboard;

  /// No description provided for @clipboardSent.
  ///
  /// In en, this message translates to:
  /// **'Clipboard sent'**
  String get clipboardSent;

  /// No description provided for @nothingNewToSend.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to send'**
  String get nothingNewToSend;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// No description provided for @deviceNameExplanation.
  ///
  /// In en, this message translates to:
  /// **'How this device appears to others.'**
  String get deviceNameExplanation;

  /// No description provided for @syncClipboard.
  ///
  /// In en, this message translates to:
  /// **'Sync clipboard'**
  String get syncClipboard;

  /// No description provided for @syncClipboardExplanation.
  ///
  /// In en, this message translates to:
  /// **'Send and receive clips with paired devices.'**
  String get syncClipboardExplanation;

  /// No description provided for @readClipboardOnOpen.
  ///
  /// In en, this message translates to:
  /// **'Read clipboard on open'**
  String get readClipboardOnOpen;

  /// No description provided for @readClipboardOnOpenExplanation.
  ///
  /// In en, this message translates to:
  /// **'Check the clipboard automatically when the app comes to the front.'**
  String get readClipboardOnOpenExplanation;

  /// No description provided for @keepSyncingInBackground.
  ///
  /// In en, this message translates to:
  /// **'Keep syncing in background'**
  String get keepSyncingInBackground;

  /// No description provided for @keepSyncingInBackgroundExplanation.
  ///
  /// In en, this message translates to:
  /// **'Stay connected when Plokee is minimized. Shows a permanent notification.'**
  String get keepSyncingInBackgroundExplanation;

  /// No description provided for @couldNotStart.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t start'**
  String get couldNotStart;

  /// No description provided for @trayOpenPlokee.
  ///
  /// In en, this message translates to:
  /// **'Open Plokee'**
  String get trayOpenPlokee;

  /// No description provided for @trayCheckClipboardNow.
  ///
  /// In en, this message translates to:
  /// **'Check clipboard now'**
  String get trayCheckClipboardNow;

  /// No description provided for @trayRecentClipboard.
  ///
  /// In en, this message translates to:
  /// **'Recent clipboard'**
  String get trayRecentClipboard;

  /// No description provided for @traySyncClipboard.
  ///
  /// In en, this message translates to:
  /// **'Sync clipboard'**
  String get traySyncClipboard;

  /// No description provided for @trayQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get trayQuit;

  /// No description provided for @traySyncIsOn.
  ///
  /// In en, this message translates to:
  /// **'Sync is on'**
  String get traySyncIsOn;

  /// No description provided for @traySyncIsPaused.
  ///
  /// In en, this message translates to:
  /// **'Sync is paused'**
  String get traySyncIsPaused;

  /// No description provided for @trayStatusLine.
  ///
  /// In en, this message translates to:
  /// **'{status} · {online} of {total} devices online'**
  String trayStatusLine(String status, int online, int total);

  /// No description provided for @notificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Clipboard sync'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Keeps Plokee connected to your paired devices.'**
  String get notificationChannelDescription;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Plokee is syncing'**
  String get notificationTitle;

  /// No description provided for @notificationText.
  ///
  /// In en, this message translates to:
  /// **'Connected to your paired devices'**
  String get notificationText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

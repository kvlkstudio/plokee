import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// An explicit language chosen in Settings. `null` means "follow the system".
///
/// Kept as a module-level value so the tray menu and the Android notification —
/// which build their strings outside the widget tree — honour the same choice
/// as the UI. [AppState] keeps it in sync with the persisted setting.
Locale? localeOverride;

/// Locale used by code that has no [BuildContext].
///
/// Inside widgets use `AppLocalizations.of(context)` instead, so the strings
/// follow the locale and rebuild with it.
Locale resolveAppLocale() {
  final override = localeOverride;
  if (override != null) return override;

  final supported = AppLocalizations.supportedLocales;
  final preferred = WidgetsBinding.instance.platformDispatcher.locales;

  // Exact language + script (keeps zh-Hant from matching zh-Hans).
  for (final locale in preferred) {
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode &&
          candidate.scriptCode == locale.scriptCode) {
        return candidate;
      }
    }
  }
  // Then language alone.
  for (final locale in preferred) {
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode) return candidate;
    }
  }
  return const Locale('en');
}

Future<AppLocalizations> loadAppLocalizations() =>
    AppLocalizations.delegate.load(resolveAppLocale());

/// Stable string form of a locale, used as the persisted setting value.
String localeCodeOf(Locale locale) => locale.scriptCode != null
    ? '${locale.languageCode}_${locale.scriptCode}'
    : locale.languageCode;

/// Parses a code produced by [localeCodeOf]. Returns null for an unknown or
/// no-longer-supported code, which falls back to following the system.
Locale? parseLocaleCode(String? code) {
  if (code == null || code.isEmpty) return null;
  for (final locale in AppLocalizations.supportedLocales) {
    if (localeCodeOf(locale) == code) return locale;
  }
  return null;
}

/// Language names written in their own language, for the Settings picker.
/// Anything missing falls back to its locale code rather than an English name.
const Map<String, String> languageNames = {
  'en': 'English',
  'de': 'Deutsch',
  'es': 'Español',
  'fr': 'Français',
  'it': 'Italiano',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'pt': 'Português',
  'ru': 'Русский',
  'tr': 'Türkçe',
  'uk': 'Українська',
  'ar': 'العربية',
  'hi': 'हिन्दी',
  'id': 'Bahasa Indonesia',
  'ja': '日本語',
  'ko': '한국어',
  'th': 'ไทย',
  'vi': 'Tiếng Việt',
  'zh': '简体中文',
  'zh_Hant': '繁體中文',
};

String languageNameOf(Locale locale) {
  final code = localeCodeOf(locale);
  return languageNames[code] ?? code;
}

/// Supported locales ordered by their native name, so the picker isn't in
/// language-code order.
List<Locale> sortedSupportedLocales() {
  final locales = [...AppLocalizations.supportedLocales];
  locales.sort((a, b) => languageNameOf(a).compareTo(languageNameOf(b)));
  return locales;
}

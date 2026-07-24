import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'l10n/app_localizations.dart';
import 'src/app_state.dart';
import 'src/foreground_service.dart';
import 'src/localization.dart';
import 'src/models.dart';
import 'src/ui/design.dart';
import 'src/ui/home_page.dart';

bool get _isDesktop =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure the Android keep-alive service (no-op elsewhere).
  await ForegroundService.init();

  if (_isDesktop) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(480, 720),
      minimumSize: Size(380, 520),
      center: true,
      title: 'Plokee',
    );
    unawaited(windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    }));
  }

  final state = AppState();
  unawaited(state.init());
  runApp(PlokeeApp(state: state));
}

class PlokeeApp extends StatefulWidget {
  final AppState state;

  const PlokeeApp({super.key, required this.state});

  @override
  State<PlokeeApp> createState() => _PlokeeAppState();
}

class _PlokeeAppState extends State<PlokeeApp>
    with TrayListener, WindowListener {
  @override
  void initState() {
    super.initState();
    if (_isDesktop) {
      trayManager.addListener(this);
      windowManager.addListener(this);
      widget.state.addListener(_onAppStateChanged);
      _setupTray();
      windowManager.setPreventClose(true);
    }
  }

  @override
  void dispose() {
    if (_isDesktop) {
      trayManager.removeListener(this);
      windowManager.removeListener(this);
      widget.state.removeListener(_onAppStateChanged);
    }
    super.dispose();
  }

  void _onAppStateChanged() {
    // AppState finishes loading asynchronously. Refreshing here both avoids
    // building a menu from uninitialised settings and keeps its status/current
    // clipboard list accurate while the window is hidden.
    if (mounted) unawaited(_updateTrayMenu());
  }

  Future<void> _setupTray() async {
    try {
      await trayManager.setIcon(
        Platform.isWindows ? 'assets/tray_icon.ico' : 'assets/tray_icon.png',
        isTemplate: true,
      );
      if (widget.state.initialized) await _updateTrayMenu();
    } catch (_) {
      // Tray is a convenience; the app works without it.
    }
  }

  Future<void> _updateTrayMenu() async {
    if (!mounted || !widget.state.initialized) return;
    final peers = widget.state.settings.peers;
    final online = peers.where((peer) => widget.state.isPeerOnline(peer.id)).length;
    final recent = widget.state.history.take(5).toList();
    // The tray lives above MaterialApp, so resolve strings without a context.
    final l10n = await loadAppLocalizations();
    final status =
        widget.state.settings.syncEnabled ? l10n.traySyncIsOn : l10n.traySyncIsPaused;

    await trayManager.setContextMenu(Menu(items: [
      MenuItem(
        key: 'status',
        label: l10n.trayStatusLine(status, online, peers.length),
        disabled: true,
      ),
      MenuItem.separator(),
      MenuItem(key: 'show', label: l10n.trayOpenPlokee),
      MenuItem(
        key: 'checkClipboard',
        label: l10n.trayCheckClipboardNow,
        disabled: !widget.state.started,
      ),
      MenuItem.submenu(
        key: 'recent',
        label: l10n.trayRecentClipboard,
        disabled: recent.isEmpty,
        submenu: Menu(
          items: recent
              .asMap()
              .entries
              .map((entry) => MenuItem(
                    key: 'history:${entry.key}',
                    label: _trayHistoryLabel(
                        entry.value.kind == ClipKind.image
                            ? l10n.imageWithSize(entry.value.formattedImageSize)
                            : entry.value.preview),
                  ))
              .toList(),
        ),
      ),
      MenuItem.separator(),
      MenuItem.checkbox(
        key: 'sync',
        label: l10n.traySyncClipboard,
        checked: widget.state.settings.syncEnabled,
      ),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: l10n.trayQuit),
    ]));
  }

  String _trayHistoryLabel(String preview) {
    final compact = preview.replaceAll(RegExp(r'\s+'), ' ').trim();
    return compact.length > 48 ? '${compact.substring(0, 48)}…' : compact;
  }

  @override
  void onTrayIconMouseDown() async {
    if (Platform.isWindows) {
      await windowManager.show();
      await windowManager.focus();
    } else {
      await trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    final key = menuItem.key ?? '';
    if (key.startsWith('history:')) {
      final index = int.tryParse(key.substring('history:'.length));
      if (index != null && index < widget.state.history.length) {
        await widget.state.copyFromHistory(widget.state.history[index]);
      }
      return;
    }

    switch (key) {
      case 'show':
        await windowManager.show();
        await windowManager.focus();
      case 'checkClipboard':
        await widget.state.sendClipboardNow();
        await _updateTrayMenu();
      case 'sync':
        await widget.state.setSyncEnabled(!widget.state.settings.syncEnabled);
        await _updateTrayMenu();
      case 'quit':
        await windowManager.setPreventClose(false);
        await windowManager.destroy();
        exit(0);
    }
  }

  @override
  void onWindowClose() async {
    // Closing the window hides to tray; quit lives in the tray menu.
    await windowManager.hide();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the chosen language changes; `locale: null` means the
    // system language wins, which is Flutter's default resolution.
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) => MaterialApp(
        title: 'Plokee',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: widget.state.initialized
            ? parseLocaleCode(widget.state.settings.localeCode)
            : null,
        theme: buildAppTheme(Brightness.light),
        darkTheme: buildAppTheme(Brightness.dark),
        home: HomePage(state: widget.state),
      ),
    );
  }
}

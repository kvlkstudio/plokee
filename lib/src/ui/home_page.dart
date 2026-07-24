import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../app_state.dart';
import '../file_actions.dart';
import '../localization.dart';
import '../models.dart';
import 'design.dart';

class HomePage extends StatefulWidget {
  final AppState state;

  const HomePage({super.key, required this.state});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    state.pairRequestHandler = _showIncomingPairDialog;
  }

  @override
  void dispose() {
    if (state.pairRequestHandler == _showIncomingPairDialog) {
      state.pairRequestHandler = null;
    }
    super.dispose();
  }

  // ---- Dialogs ----

  Future<bool> _showIncomingPairDialog(PairRequest request) async {
    if (!mounted) return false;
    final l10n = AppLocalizations.of(context);
    final accepted = await showAppDialog<bool>(
      context: context,
      dismissible: false,
      builder: (context) => AppDialogLayout(
        title: l10n.pairingRequest,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.wantsToPair(
                request.requester.name, request.requester.platform)),
            const SizedBox(height: AppSpace.lg),
            Text(l10n.makeSureSameCode),
            const SizedBox(height: AppSpace.md),
            CodeDisplay(request.code),
          ],
        ),
        actions: [
          AppButton(
            label: l10n.decline,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: AppLocalizations.of(context).pair,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    return accepted ?? false;
  }

  Future<void> _startPairing(FoundDevice device) async {
    final (code, result) = await state.startPairing(device);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    showAppDialog<void>(
      context: context,
      dismissible: false,
      builder: (dialogContext) => FutureBuilder<bool>(
        future: result,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AppDialogLayout(
              title: l10n.pairingWith(device.info.name),
              body: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.confirmOnOtherDevice),
                  const SizedBox(height: AppSpace.md),
                  CodeDisplay(code),
                  const SizedBox(height: AppSpace.lg),
                  _WaitingBar(),
                ],
              ),
            );
          }
          final ok = snapshot.data!;
          return AppDialogLayout(
            title: ok ? l10n.statusPaired : l10n.pairingFailed,
            body: Text(ok
                ? l10n.nowConnected(device.info.name)
                : l10n.requestDeclinedOrTimedOut),
            actions: [
              AppButton(
                label: l10n.done,
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editDeviceName() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: state.settings.deviceName);
    final name = await showAppDialog<String>(
      context: context,
      builder: (context) => AppDialogLayout(
        title: l10n.deviceName,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deviceNameExplanation,
                style: TextStyle(color: context.palette.textSecondary)),
            const SizedBox(height: AppSpace.md),
            AppTextField(
              controller: controller,
              autofocus: true,
              hint: l10n.deviceName,
              onSubmitted: (v) => Navigator.of(context).pop(v),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: l10n.cancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: l10n.save,
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      await state.setDeviceName(name);
    }
  }

  Future<void> _openSettings() async {
    await showAppDialog<void>(
      context: context,
      builder: (context) => ListenableBuilder(
        listenable: state,
        builder: (context, _) {
          final p = context.palette;
          // Read inside the builder: picking a language rebuilds this dialog.
          final l10n = AppLocalizations.of(context);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settings,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: p.textPrimary)),
              const SizedBox(height: AppSpace.lg),
              _SettingRow(
                label: l10n.deviceName,
                trailing: AppButton(
                  label: state.settings.deviceName,
                  variant: AppButtonVariant.ghost,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editDeviceName();
                  },
                ),
              ),
              _SettingRow(
                label: l10n.language,
                trailing: AppButton(
                  label: state.settings.localeCode == null
                      ? l10n.languageSystem
                      : languageNames[state.settings.localeCode!] ??
                          state.settings.localeCode!,
                  variant: AppButtonVariant.ghost,
                  onPressed: _pickLanguage,
                ),
              ),
              _SettingRow(
                label: l10n.syncClipboard,
                description: l10n.syncClipboardExplanation,
                trailing: AppToggle(
                  value: state.settings.syncEnabled,
                  onChanged: (v) => state.setSyncEnabled(v),
                ),
              ),
              if (isMobilePlatform)
                _SettingRow(
                  label: l10n.readClipboardOnOpen,
                  description: l10n.readClipboardOnOpenExplanation,
                  trailing: AppToggle(
                    value: state.settings.autoReadOnResume,
                    onChanged: (v) => state.setAutoReadOnResume(v),
                  ),
                ),
              if (Platform.isAndroid)
                _SettingRow(
                  label: l10n.keepSyncingInBackground,
                  description: l10n.keepSyncingInBackgroundExplanation,
                  trailing: AppToggle(
                    value: state.settings.backgroundSync,
                    onChanged: (v) => state.setBackgroundSync(v),
                  ),
                ),
              const SizedBox(height: AppSpace.lg),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  label: l10n.done,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickLanguage() async {
    final l10n = AppLocalizations.of(context);
    final current = state.settings.localeCode;
    // A sentinel for "follow the system", since null is a valid pop() result.
    const systemValue = '\u0000system';

    final choice = await showAppDialog<String>(
      context: context,
      builder: (dialogContext) => AppDialogLayout(
        title: l10n.language,
        body: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 340),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LanguageOption(
                  label: l10n.languageSystem,
                  selected: current == null,
                  onTap: () =>
                      Navigator.of(dialogContext).pop(systemValue),
                ),
                for (final locale in sortedSupportedLocales())
                  _LanguageOption(
                    label: languageNameOf(locale),
                    selected: current == localeCodeOf(locale),
                    onTap: () => Navigator.of(dialogContext)
                        .pop(localeCodeOf(locale)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (choice == null) return; // dismissed
    await state.setLocale(choice == systemValue ? null : choice);
  }

  Future<void> _peerActions(Peer peer) async {
    final l10n = AppLocalizations.of(context);
    final action = await showAppSheet<String>(
      context: context,
      title: peer.name.toUpperCase(),
      actions: [
        AppSheetAction(
            value: 'unpair',
            label: l10n.unpair,
            icon: Icons.link_off,
            danger: true),
      ],
    );
    if (action == 'unpair') await state.unpair(peer.id);
  }

  // ---- Actions ----

  Future<void> _clearHistory() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppDialogLayout(
        title: l10n.clearHistoryQuestion,
        body: Text(l10n.clearHistoryExplanation),
        actions: [
          AppButton(
            label: l10n.cancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: l10n.clear,
            variant: AppButtonVariant.danger,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirm == true) await state.clearHistory();
  }

  Future<void> _sendClipboardNow() async {
    final sent = await state.sendClipboardNow();
    if (!mounted) return;
    showAppToast(context,
        sent
            ? AppLocalizations.of(context).clipboardSent
            : AppLocalizations.of(context).nothingNewToSend);
  }

  void _copy(ClipItem item) {
    state.copyFromHistory(item);
    showAppToast(context, AppLocalizations.of(context).copied);
  }

  Future<void> _share(ClipItem item) async {
    switch (item.kind) {
      case ClipKind.text:
        await SharePlus.instance.share(ShareParams(text: item.text));
      case ClipKind.image:
        final bytes = item.imageBytes;
        if (bytes == null) {
          if (!mounted) return;
          showAppToast(
              context, AppLocalizations.of(context).imageNoLongerAvailable);
          return;
        }
        final dir = await state.saveDir();
        await dir.create(recursive: true);
        final file = File(
            '${dir.path}${Platform.pathSeparator}clip_${item.time.millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
      case ClipKind.files:
        final files = item.filePaths
            .where((p) => File(p).existsSync())
            .map(XFile.new)
            .toList();
        if (files.isNotEmpty) {
          await SharePlus.instance.share(ShareParams(files: files));
        }
    }
  }

  Future<void> _openLink(ClipItem item) async {
    final uri = item.linkUri;
    if (uri == null) return;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!mounted || opened) return;
    showAppToast(context, AppLocalizations.of(context).couldNotOpenLink);
  }

  Future<void> _saveImage(ClipItem item) async {
    final bytes = item.imageBytes;
    if (bytes == null) {
      showAppToast(context, AppLocalizations.of(context).imageNoLongerAvailable);
      return;
    }
    try {
      final dir = await state.saveDir();
      await dir.create(recursive: true);
      final file = File('${dir.path}${Platform.pathSeparator}'
          'plokee_${item.time.millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      if (canRevealInFileManager) await revealInFileManager(file.path);
      if (!mounted) return;
      showAppToast(context, AppLocalizations.of(context).imageSaved);
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, AppLocalizations.of(context).couldNotSaveImage);
    }
  }

  Future<void> _revealFiles(ClipItem item) async {
    final existing =
        item.filePaths.where((path) => File(path).existsSync()).toList();
    if (existing.isEmpty) {
      showAppToast(context, AppLocalizations.of(context).filesNoLongerAvailable);
      return;
    }
    final ok = await revealInFileManager(existing.first);
    if (!mounted || ok) return;
    showAppToast(context, AppLocalizations.of(context).couldNotOpenFolder);
  }

  IconData _platformIcon(String platform) => switch (platform) {
        'macos' => Icons.laptop_mac,
        'windows' => Icons.desktop_windows_outlined,
        'linux' => Icons.computer_outlined,
        'ios' => Icons.phone_iphone,
        'android' => Icons.phone_android,
        _ => Icons.devices_other,
      };

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final p = context.palette;
        if (!state.initialized) {
          return Scaffold(
            backgroundColor: p.background,
            body: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: p.accent),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: p.background,
          body: Column(
            children: [
              _Header(
                connectedCount: state.engine.connectedCount,
                started: state.started,
                syncEnabled: state.settings.syncEnabled,
                onToggleSync: (v) => state.setSyncEnabled(v),
                onSettings: _openSettings,
              ),
              Expanded(
                child: state.startupError != null
                    ? _ErrorView(message: state.startupError!)
                    : _content(context),
              ),
              if (isMobilePlatform) _footer(context),
            ],
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    final peers = state.settings.peers;
    final foundDevices = state.unpairedFound;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.xl),
      children: [
        _SectionLabel(AppLocalizations.of(context).devices),
        const SizedBox(height: AppSpace.sm),
        _devicesPanel(context, peers, foundDevices),
        const SizedBox(height: AppSpace.xl),
        Row(
          children: [
            Expanded(child: _SectionLabel(AppLocalizations.of(context).history)),
            if (state.history.isNotEmpty) ...[
              Text('${state.history.length}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.palette.textTertiary)),
              const SizedBox(width: 2),
              AppIconButton(
                icon: Icons.delete_outline,
                tooltip: AppLocalizations.of(context).clearHistory,
                size: 17,
                onPressed: _clearHistory,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        if (state.history.isEmpty)
          _EmptyHistory()
        else
          ...state.history.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.sm),
                child: _HistoryRow(
                  item: item,
                  onCopy: () => _copy(item),
                  onShare: isMobilePlatform ? () => _share(item) : null,
                  // Contextual actions: only offered where they can do
                  // something useful for this clip on this platform.
                  onOpenLink:
                      item.linkUri != null ? () => _openLink(item) : null,
                  onSaveImage: item.kind == ClipKind.image && !isMobilePlatform
                      ? () => _saveImage(item)
                      : null,
                  onRevealFiles: item.kind == ClipKind.files &&
                          item.filePaths.isNotEmpty &&
                          canRevealInFileManager
                      ? () => _revealFiles(item)
                      : null,
                  platformIcon: _platformIcon,
                ),
              )),
      ],
    );
  }

  Widget _devicesPanel(
      BuildContext context, List<Peer> peers, List<FoundDevice> found) {
    final p = context.palette;
    if (peers.isEmpty && found.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.xl + 4),
        child: Column(
          children: [
            Icon(Icons.wifi_tethering, size: 26, color: p.textTertiary),
            const SizedBox(height: AppSpace.md),
            Text(AppLocalizations.of(context).lookingForDevices,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: p.textSecondary)),
            const SizedBox(height: 4),
            Text(AppLocalizations.of(context).openPlokeeOnAnotherDevice,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, height: 1.4, color: p.textTertiary)),
          ],
        ),
      );
    }

    final rows = <Widget>[];
    for (final peer in peers) {
      rows.add(_PeerRow(
        peer: peer,
        connected: state.engine.isConnected(peer.id),
        online: state.isPeerOnline(peer.id),
        icon: _platformIcon(peer.platform),
        onActions: () => _peerActions(peer),
      ));
    }
    for (final device in found) {
      rows.add(_FoundRow(
        device: device,
        icon: _platformIcon(device.info.platform),
        onPair: () => _startPairing(device),
      ));
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: p.border, indent: 14, endIndent: 14),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg,
          AppSpace.md + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: AppButton(
        label: AppLocalizations.of(context).sendClipboard,
        icon: Icons.upload_rounded,
        large: true,
        expand: true,
        onPressed: state.settings.syncEnabled ? _sendClipboardNow : null,
      ),
    );
  }
}

// ---- Header ----

class _Header extends StatelessWidget {
  final int connectedCount;
  final bool started;
  final bool syncEnabled;
  final ValueChanged<bool> onToggleSync;
  final VoidCallback onSettings;

  const _Header({
    required this.connectedCount,
    required this.started,
    required this.syncEnabled,
    required this.onToggleSync,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final connected = connectedCount > 0;
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpace.lg, MediaQuery.of(context).padding.top + AppSpace.md, AppSpace.md, AppSpace.md),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          Text(AppLocalizations.of(context).appTitle,
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: p.textPrimary)),
          const SizedBox(width: AppSpace.sm),
          if (started)
            AppPill(
              text: connected
                  ? AppLocalizations.of(context).connectedDevices(connectedCount)
                  : AppLocalizations.of(context).statusIdle,
              color: connected ? p.success : p.textTertiary,
              background: connected ? p.successSoft : p.surfaceAlt,
              leading: connected
                  ? StatusDot(color: p.success, glow: true, size: 7)
                  : null,
            ),
          const Spacer(),
          Text(AppLocalizations.of(context).sync, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: p.textSecondary)),
          const SizedBox(width: AppSpace.sm),
          AppToggle(value: syncEnabled, onChanged: onToggleSync),
          const SizedBox(width: AppSpace.xs),
          AppIconButton(
              icon: Icons.tune_rounded,
              onPressed: onSettings,
              tooltip: AppLocalizations.of(context).settings),
        ],
      ),
    );
  }
}

// ---- Rows ----

class _DeviceIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  const _DeviceIcon({required this.icon, this.active = true});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusSm + 1),
      ),
      child: Icon(icon, size: 20, color: active ? p.textSecondary : p.textTertiary),
    );
  }
}

class _PeerRow extends StatelessWidget {
  final Peer peer;
  final bool connected;
  final bool online;
  final IconData icon;
  final VoidCallback onActions;

  const _PeerRow({
    required this.peer,
    required this.connected,
    required this.online,
    required this.icon,
    required this.onActions,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final status = connected
        ? l10n.statusConnected
        : (online ? l10n.statusConnecting : l10n.statusOffline);
    final statusColor = connected ? p.success : p.textTertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          _DeviceIcon(icon: icon),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(peer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    StatusDot(
                        color: connected ? p.success : p.borderStrong,
                        glow: connected,
                        size: 7),
                    const SizedBox(width: 6),
                    Text(status,
                        style: TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w500, color: statusColor)),
                  ],
                ),
              ],
            ),
          ),
          AppIconButton(icon: Icons.more_horiz, onPressed: onActions),
        ],
      ),
    );
  }
}

class _FoundRow extends StatelessWidget {
  final FoundDevice device;
  final IconData icon;
  final VoidCallback onPair;

  const _FoundRow(
      {required this.device, required this.icon, required this.onPair});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          _DeviceIcon(icon: icon, active: false),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.info.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary)),
                const SizedBox(height: 2),
                Text(AppLocalizations.of(context).newDeviceAt(device.address),
                    style: TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w500, color: p.textTertiary)),
              ],
            ),
          ),
          AppButton(
            label: AppLocalizations.of(context).pair,
            variant: AppButtonVariant.tonal,
            onPressed: onPair,
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final ClipItem item;
  final VoidCallback onCopy;
  final VoidCallback? onShare;
  final VoidCallback? onOpenLink;
  final VoidCallback? onSaveImage;
  final VoidCallback? onRevealFiles;
  final IconData Function(String) platformIcon;

  const _HistoryRow({
    required this.item,
    required this.onCopy,
    required this.onShare,
    this.onOpenLink,
    this.onSaveImage,
    this.onRevealFiles,
    required this.platformIcon,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = AppLocalizations.of(context);
    final time = TimeOfDay.fromDateTime(item.time).format(context);
    final meta =
        item.remote ? l10n.fromDeviceAtTime(item.sourceName, time) : time;
    // The image label carries a formatted size, so it is built here rather
    // than in the model, which has no locale.
    final preview = item.kind == ClipKind.image
        ? l10n.imageWithSize(item.formattedImageSize)
        : item.preview;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _leading(context),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: p.textPrimary),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (item.remote) ...[
                      Icon(Icons.south_west, size: 11, color: p.textTertiary),
                      const SizedBox(width: 3),
                    ],
                    Flexible(
                      child: Text(meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: p.textTertiary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onOpenLink != null)
            AppIconButton(
                icon: Icons.open_in_new_rounded,
                onPressed: onOpenLink!,
                tooltip: item.linkUri?.scheme == 'mailto'
                    ? l10n.writeEmail
                    : l10n.openInBrowser,
                size: 17),
          if (onSaveImage != null)
            AppIconButton(
                icon: Icons.download_rounded,
                onPressed: onSaveImage!,
                tooltip: l10n.saveImage,
                size: 17),
          if (onRevealFiles != null)
            AppIconButton(
                icon: Icons.folder_open_rounded,
                onPressed: onRevealFiles!,
                tooltip: l10n.showInFolder,
                size: 17),
          if (onShare != null)
            AppIconButton(
                icon: Icons.ios_share,
                onPressed: onShare!,
                tooltip: l10n.share,
                size: 17),
          AppIconButton(
              icon: Icons.copy_rounded,
              onPressed: onCopy,
              tooltip: l10n.copy,
              size: 17),
        ],
      ),
    );
  }

  Widget _leading(BuildContext context) {
    final p = context.palette;
    switch (item.kind) {
      case ClipKind.image:
        final bytes = item.imageBytes;
        // Bytes are absent whenever the on-disk copy did not survive — the
        // save is debounced, so a kill right after the clip arrived loses it,
        // which iOS does routinely on suspend. ClipItem keeps imageSize for
        // exactly this case, so the row still reads "Image (40 KB)"; only the
        // thumbnail falls back. Rendering it with `!` threw during build, and
        // a release build paints a failed build as a blank grey rectangle.
        if (bytes == null) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(AppSpace.radiusSm),
            ),
            child: Icon(Icons.image_not_supported_outlined,
                size: 20, color: p.textTertiary),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSpace.radiusSm),
          child: Image.memory(bytes,
              width: 40, height: 40, fit: BoxFit.cover, gaplessPlayback: true),
        );
      case ClipKind.files:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: p.accentSoft,
            borderRadius: BorderRadius.circular(AppSpace.radiusSm),
          ),
          child: Icon(Icons.description_outlined, size: 20, color: p.accent),
        );
      case ClipKind.text:
        final link = item.linkUri;
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: link != null ? p.accentSoft : p.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpace.radiusSm),
          ),
          child: Icon(
            link == null
                ? Icons.notes_rounded
                : (link.scheme == 'mailto'
                    ? Icons.alternate_email_rounded
                    : Icons.link_rounded),
            size: 20,
            color: link != null ? p.accent : p.textTertiary,
          ),
        );
    }
  }
}

// ---- Small pieces ----

/// One row in the language picker: name on the left, check when selected.
class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpace.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? p.accent : p.textPrimary)),
            ),
            if (selected) Icon(Icons.check_rounded, size: 18, color: p.accent),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(text.toUpperCase(),
        style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: p.textTertiary));
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String? description;
  final Widget trailing;

  const _SettingRow(
      {required this.label, this.description, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fixed shares: translated labels are often much longer than the
          // English ones, so the label keeps its room instead of being
          // squeezed to a couple of characters by a wide value button.
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: p.textPrimary)),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(description!,
                      style: TextStyle(
                          fontSize: 12, height: 1.35, color: p.textTertiary)),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Flexible(
            flex: 4,
            child: Align(
                alignment: AlignmentDirectional.centerEnd, child: trailing),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.xl + 4),
      child: Column(
        children: [
          Icon(Icons.content_paste_outlined, size: 24, color: p.textTertiary),
          const SizedBox(height: AppSpace.md),
          Text(AppLocalizations.of(context).nothingCopiedYet,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: p.textSecondary)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).copiesShowUpHere,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: p.textTertiary)),
        ],
      ),
    );
  }
}

class _WaitingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpace.radiusPill),
      child: LinearProgressIndicator(
        minHeight: 4,
        backgroundColor: p.surfaceAlt,
        valueColor: AlwaysStoppedAnimation(p.accent),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: p.danger, size: 28),
            const SizedBox(height: AppSpace.md),
            Text(AppLocalizations.of(context).couldNotStart,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: p.textPrimary)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, height: 1.4, color: p.textTertiary)),
          ],
        ),
      ),
    );
  }
}

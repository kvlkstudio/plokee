import 'package:flutter/material.dart';

/// Plokee design system.
///
/// A deliberately platform-neutral visual language so the app feels at home
/// on macOS, Windows, Linux, iOS and Android alike: hairline borders instead
/// of Material elevation, one restrained accent, a compact type scale and a
/// small set of custom controls. Colors live in [AppPalette] (a theme
/// extension) and are reached with `context.palette`.

class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color overlay;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.overlay,
  });

  static const light = AppPalette(
    background: Color(0xFFF4F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEDEFF3),
    border: Color(0xFFE3E6EB),
    borderStrong: Color(0xFFD3D7DE),
    textPrimary: Color(0xFF1B1E23),
    textSecondary: Color(0xFF636B76),
    textTertiary: Color(0xFF9AA1AB),
    accent: Color(0xFF2E7DD1),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0x1A2E7DD1),
    success: Color(0xFF2F9E68),
    successSoft: Color(0x1A2F9E68),
    danger: Color(0xFFD5453B),
    dangerSoft: Color(0x1AD5453B),
    overlay: Color(0x33000000),
  );

  static const dark = AppPalette(
    background: Color(0xFF0F1113),
    surface: Color(0xFF191C20),
    surfaceAlt: Color(0xFF23272D),
    border: Color(0xFF2C3037),
    borderStrong: Color(0xFF3A3F47),
    textPrimary: Color(0xFFECEEF1),
    textSecondary: Color(0xFF9BA2AB),
    textTertiary: Color(0xFF6B727C),
    accent: Color(0xFF4C97E8),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0x264C97E8),
    success: Color(0xFF3DBE7C),
    successSoft: Color(0x263DBE7C),
    danger: Color(0xFFE5675E),
    dangerSoft: Color(0x26E5675E),
    overlay: Color(0x66000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accent,
    Color? onAccent,
    Color? accentSoft,
    Color? success,
    Color? successSoft,
    Color? danger,
    Color? dangerSoft,
    Color? overlay,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}

extension PaletteAccess on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Shared spacing / radius scale.
abstract final class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;
}

ThemeData buildAppTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: brightness,
  ).copyWith(
    surface: p.background,
    primary: p.accent,
    onPrimary: p.onAccent,
  );

  TextStyle t(double size, FontWeight w, Color c, {double? h, double? ls}) =>
      TextStyle(
          fontSize: size, fontWeight: w, color: c, height: h, letterSpacing: ls);

  return base.copyWith(
    scaffoldBackgroundColor: p.background,
    colorScheme: scheme,
    extensions: [p],
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: p.border,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.accent,
      selectionColor: p.accent.withValues(alpha: 0.25),
      selectionHandleColor: p.accent,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(p.textTertiary.withValues(alpha: 0.5)),
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(3),
    ),
    textTheme: base.textTheme.copyWith(
      titleLarge: t(20, FontWeight.w700, p.textPrimary, ls: -0.4),
      titleMedium: t(15, FontWeight.w600, p.textPrimary, ls: -0.2),
      bodyLarge: t(14.5, FontWeight.w500, p.textPrimary, h: 1.35),
      bodyMedium: t(13.5, FontWeight.w400, p.textSecondary, h: 1.35),
      labelLarge: t(13, FontWeight.w600, p.textPrimary),
      labelMedium: t(12, FontWeight.w500, p.textSecondary),
      labelSmall: t(11.5, FontWeight.w500, p.textTertiary, ls: 0.2),
    ),
  );
}

// ---- Custom controls ----

/// A small colored status dot with an optional soft halo.
class StatusDot extends StatelessWidget {
  final Color color;
  final bool glow;
  final double size;

  const StatusDot(
      {super.key, required this.color, this.glow = false, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: glow
            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)]
            : null,
      ),
    );
  }
}

/// A compact rounded label (status chip).
class AppPill extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? background;
  final Widget? leading;

  const AppPill(
      {super.key, required this.text, this.color, this.background, this.leading});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: leading == null ? 9 : 8, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 5)],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color ?? p.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom pill toggle — intentionally not a Material Switch.
class AppToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 42,
        height: 25,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: value ? p.accent : p.borderStrong,
          borderRadius: BorderRadius.circular(AppSpace.radiusPill),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x22000000), blurRadius: 2, offset: Offset(0, 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A bordered surface panel (replaces Material Card + elevation).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  const AppCard(
      {super.key, required this.child, this.padding, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: BorderRadius.circular(AppSpace.radiusMd),
        border: Border.all(color: p.border),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return _Pressable(onTap: onTap!, borderRadius: AppSpace.radiusMd, child: content);
  }
}

enum AppButtonVariant { filled, tonal, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool expand;
  final bool large;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.expand = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color bg, Color fg, Color? border) = switch (variant) {
      AppButtonVariant.filled => (p.accent, p.onAccent, null),
      AppButtonVariant.tonal => (p.accentSoft, p.accent, null),
      AppButtonVariant.ghost => (Colors.transparent, p.textPrimary, p.borderStrong),
      AppButtonVariant.danger => (p.dangerSoft, p.danger, null),
    };
    final disabled = onPressed == null;

    Widget child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: large ? 19 : 16, color: fg),
          const SizedBox(width: 7),
        ],
        // Flexible so a long label (a device name, a language) shrinks instead
        // of overflowing when the button sits in a constrained row.
        Flexible(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: large ? 15 : 13.5,
                  fontWeight: FontWeight.w600,
                  color: fg)),
        ),
      ],
    );

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: _Pressable(
        onTap: onPressed,
        borderRadius: AppSpace.radiusSm + 2,
        child: Container(
          height: large ? 48 : 36,
          padding: EdgeInsets.symmetric(horizontal: large ? 20 : 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpace.radiusSm + 2),
            border: border == null ? null : Border.all(color: border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;
  final Color? color;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 18,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget button = _Pressable(
      onTap: onPressed,
      borderRadius: AppSpace.radiusSm,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        child: Icon(icon, size: size, color: color ?? p.textSecondary),
      ),
    );
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// A minimal, hover/press-aware tap wrapper without Material ink.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;

  const _Pressable(
      {required this.child, required this.onTap, this.borderRadius = 8});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedOpacity(
            opacity: _hover && !_down ? 0.88 : 1,
            duration: const Duration(milliseconds: 120),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A single-line text field styled to match the design system.
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      onSubmitted: onSubmitted,
      cursorColor: p.accent,
      style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: p.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: p.textTertiary, fontWeight: FontWeight.w400),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        filled: true,
        fillColor: p.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.radiusSm),
          borderSide: BorderSide(color: p.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.radiusSm),
          borderSide: BorderSide(color: p.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpace.radiusSm),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
    );
  }
}

// ---- Overlays: toast, dialog, action sheet ----

/// A lightweight bottom toast that fades in and out (replaces SnackBar).
void showAppToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final p = context.palette;
  final entry = OverlayEntry(
    builder: (context) => _ToastWidget(message: message, palette: p),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1500), entry.remove);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final AppPalette palette;

  const _ToastWidget({required this.message, required this.palette});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _opacity = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: media.padding.bottom + 28,
      child: IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 220),
            child: AnimatedSlide(
              offset: Offset(0, _opacity == 1 ? 0 : 0.2),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.palette.textPrimary,
                  borderRadius: BorderRadius.circular(AppSpace.radiusPill),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: widget.palette.surface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom modal dialog with the app's rounded, hairline-bordered look.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool dismissible = true,
}) {
  final p = context.palette;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'dismiss',
    barrierColor: p.overlay,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, _, _) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(AppSpace.xl),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(AppSpace.radiusLg),
                border: Border.all(color: p.border),
                boxShadow: const [
                  BoxShadow(color: Color(0x1F000000), blurRadius: 32, offset: Offset(0, 12)),
                ],
              ),
              child: builder(context),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, anim, _, child) {
      final curved = Curves.easeOutCubic.transform(anim.value);
      return Opacity(
        opacity: anim.value,
        child: Transform.scale(scale: 0.96 + 0.04 * curved, child: child),
      );
    },
  );
}

/// A dialog title + body + actions convenience layout for [showAppDialog].
class AppDialogLayout extends StatelessWidget {
  final String title;
  final Widget? body;
  final List<Widget> actions;

  const AppDialogLayout(
      {super.key, required this.title, this.body, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: p.textPrimary)),
        if (body != null) ...[
          const SizedBox(height: AppSpace.md),
          DefaultTextStyle(
            style: TextStyle(
                fontSize: 13.5, height: 1.4, color: p.textSecondary),
            child: body!,
          ),
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: AppSpace.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpace.sm),
                actions[i],
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// A monospace-aligned verification code display.
class CodeDisplay extends StatelessWidget {
  final String code;
  const CodeDisplay(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpace.radiusMd),
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
          color: p.textPrimary,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// A styled bottom action sheet returning the selected value.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required String title,
  required List<AppSheetAction<T>> actions,
}) {
  final p = context.palette;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: p.overlay,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: p.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(AppSpace.radiusMd),
                border: Border.all(color: p.border),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: p.textTertiary,
                              letterSpacing: 0.3)),
                    ),
                  ),
                  for (final a in actions) ...[
                    Divider(height: 1, color: p.border),
                    _Pressable(
                      onTap: () => Navigator.of(context).pop(a.value),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 15),
                        child: Row(
                          children: [
                            Icon(a.icon,
                                size: 19,
                                color: a.danger ? p.danger : p.textSecondary),
                            const SizedBox(width: 12),
                            Text(a.label,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        a.danger ? p.danger : p.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class AppSheetAction<T> {
  final T value;
  final String label;
  final IconData icon;
  final bool danger;

  const AppSheetAction({
    required this.value,
    required this.label,
    required this.icon,
    this.danger = false,
  });
}

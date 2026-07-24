import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// A human-friendly default name for this device.
///
/// Plain hostnames are a poor default: behind many home routers every device
/// reports the same name (e.g. `Mac.fritz.box`), so the device list ends up
/// full of identical entries. Instead we pull the name the user actually set
/// in their OS (computer name / Bluetooth name), falling back to the model,
/// and only to the hostname as a last resort.
Future<String> defaultDeviceName() async {
  final info = DeviceInfoPlugin();
  try {
    if (Platform.isMacOS) {
      final mac = await info.macOsInfo;
      return _firstNonEmpty([mac.computerName, mac.modelName]);
    }
    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      // On iOS 16+ `name` is a generic "iPhone" without a special entitlement;
      // in that case the commercial model name ("iPhone 16 Pro") is clearer.
      final name = ios.name.trim();
      final generic = name.isEmpty || name == ios.model;
      return _firstNonEmpty(
          generic ? [ios.modelName, ios.name] : [ios.name, ios.modelName]);
    }
    if (Platform.isAndroid) {
      final a = await info.androidInfo;
      // Settings.Global.DEVICE_NAME is the user's chosen name when set.
      final name = a.name.trim();
      if (name.isNotEmpty) return name;
      return _titleCase('${a.manufacturer} ${a.model}'.trim());
    }
    if (Platform.isWindows) {
      final w = await info.windowsInfo;
      return _firstNonEmpty([w.computerName]);
    }
    // Linux and everything else: the hostname is usually user-set and unique.
  } catch (_) {
    // Fall through to the hostname.
  }
  return Platform.localHostname;
}

String _firstNonEmpty(List<String> candidates) {
  for (final c in candidates) {
    if (c.trim().isNotEmpty) return c.trim();
  }
  return Platform.localHostname;
}

String _titleCase(String s) => s
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

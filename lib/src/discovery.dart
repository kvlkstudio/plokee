import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/services.dart';

import 'models.dart';

/// LAN device discovery.
///
/// Two mechanisms run side by side and feed the same callback (duplicates
/// are collapsed by device id upstream):
///
/// * **UDP multicast** (everywhere except iOS) — self-contained, works even
///   where an mDNS daemon is unavailable. iOS is excluded because raw
///   multicast there needs a restricted Apple entitlement.
/// * **Bonjour/mDNS** (`_plokee._tcp`) via the platform APIs — the
///   sanctioned path on iOS/Android, also enabled on desktop so mixed
///   networks converge.
/// Usable IPv4 addresses for a host, best candidate first.
///
/// mDNS publishes one A record per interface, so a machine with a Thunderbolt
/// bridge, a VM adapter or a docking station advertises unroutable extras
/// (`0.0.0.0`, `127.0.0.1`, `169.254.x.x`) next to its real LAN address — and
/// the resolver hands them back in no particular order. Dialling whichever one
/// arrives first is a coin flip, so rank them instead:
///
/// * loopback and the unspecified address are dropped outright — from another
///   device they point at the wrong machine (or nothing at all);
/// * link-local (`169.254/16`) is kept but sorted last: it is the right answer
///   only on a direct cable with no DHCP;
/// * IPv6 is dropped because [WebSocket.connect] needs bracket syntax and
///   link-local forms carry a zone id that is meaningless across hosts.
///
/// Input order is preserved within a rank, so callers can put the freshest
/// address first and have it stay ahead of equally-good older ones.
List<String> rankLanAddresses(Iterable<String> addresses) {
  final kept = <String>[];
  for (final address in addresses) {
    if (address.contains(':')) continue; // IPv6
    if (address == '0.0.0.0' || address.startsWith('127.')) continue;
    if (InternetAddress.tryParse(address) == null) continue;
    if (kept.contains(address)) continue;
    kept.add(address);
  }
  // Decorated sort: List.sort is not stable, and ties must keep input order.
  final indexed = kept.indexed.toList()
    ..sort((a, b) {
      final byRank = _addressRank(a.$2).compareTo(_addressRank(b.$2));
      return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
    });
  return [for (final entry in indexed) entry.$2];
}

int _addressRank(String address) => address.startsWith('169.254.') ? 1 : 0;

class DiscoveryService {
  final DeviceInfo Function() localInfo;

  /// [addresses] is ranked best-first and never empty; every entry belongs to
  /// the same host, so a dialler may fall through the list.
  final void Function(DeviceInfo info, List<String> addresses) onDeviceSeen;

  late final _UdpDiscovery _udp = _UdpDiscovery(
    localInfo: localInfo,
    onDeviceSeen: onDeviceSeen,
  );
  late final _BonjourDiscovery _bonjour = _BonjourDiscovery(
    localInfo: localInfo,
    onDeviceSeen: onDeviceSeen,
  );

  DiscoveryService({required this.localInfo, required this.onDeviceSeen});

  /// Whether to run the UDP leg at all.
  ///
  /// iOS is excluded on purpose: joining a multicast group needs Apple's
  /// restricted `com.apple.developer.networking.multicast` entitlement, which
  /// has to be applied for and granted. Bonjour needs no entitlement, so the
  /// App Store build discovers over mDNS only. (Consequence: the iOS Simulator
  /// can no longer discover anything, because its Bonjour browse is broken by
  /// a known local-network-privacy limitation — NoAuth -65555. Use a real
  /// device to test iOS discovery.)
  static bool get _udpSupported => !Platform.isIOS;

  Future<void> start() async {
    if (_udpSupported) {
      try {
        await _udp.start();
      } catch (_) {}
    }
    try {
      await _bonjour.start();
    } catch (_) {
      // No mDNS daemon (e.g. Linux without Avahi); UDP still works there.
    }
  }

  /// Re-announces immediately (e.g. after a device rename).
  void announce() {
    if (_udpSupported) _udp.announce();
    _bonjour.restart();
  }

  void stop() {
    if (_udpSupported) _udp.stop();
    _bonjour.stop();
  }
}

class _UdpDiscovery {
  static final InternetAddress multicastGroup = InternetAddress('224.0.0.167');
  static const int discoveryPort = 45654;
  static const Duration announceInterval = Duration(seconds: 3);

  final DeviceInfo Function() localInfo;
  final void Function(DeviceInfo info, List<String> addresses) onDeviceSeen;

  RawDatagramSocket? _socket;
  Timer? _timer;

  _UdpDiscovery({required this.localInfo, required this.onDeviceSeen});

  /// Android needs a MulticastLock, or the Wi-Fi driver filters multicast out
  /// once the interface dozes. Held only while discovery runs.
  static const MethodChannel _multicastChannel = MethodChannel(
    'com.kvlkstudio.plokee/multicast',
  );

  Future<void> _setMulticastLock(bool held) async {
    if (!Platform.isAndroid) return;
    try {
      await _multicastChannel.invokeMethod(held ? 'acquire' : 'release');
    } catch (_) {
      // Old build without the channel, or Wi-Fi unavailable: UDP still works
      // on an awake interface, and Bonjour is unaffected.
    }
  }

  Future<void> start() async {
    await _setMulticastLock(true);
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
      reuseAddress: true,
      reusePort: !Platform.isWindows,
    );
    socket.multicastLoopback = true;
    try {
      socket.joinMulticast(multicastGroup);
    } catch (_) {
      // Some interfaces refuse multicast (e.g. no network); announcements
      // will still go out once a network appears.
    }
    socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = socket.receive();
      if (datagram == null) return;
      _handlePacket(datagram);
    });
    _socket = socket;
    _timer = Timer.periodic(announceInterval, (_) => announce());
    announce();
  }

  void _handlePacket(Datagram datagram) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final info = DeviceInfo.tryParse(json);
    if (info == null) return;
    final me = localInfo();
    if (info.id == me.id) return; // our own multicast echo
    // The datagram source address is authoritative: it is the interface the
    // peer actually reached us on, so there is nothing to rank.
    onDeviceSeen(info, [datagram.address.address]);
    // Reply unicast so the sender learns about us immediately.
    if (json['reply'] != true) {
      _send({...me.toJson(), 'reply': true}, datagram.address);
    }
  }

  void announce() => _send(localInfo().toJson(), multicastGroup);

  void _send(Map<String, dynamic> json, InternetAddress to) {
    try {
      _socket?.send(utf8.encode(jsonEncode(json)), to, discoveryPort);
    } catch (_) {
      // Network temporarily unavailable; next announce will retry.
    }
  }

  void stop() {
    _setMulticastLock(false);
    _timer?.cancel();
    _socket?.close();
    _socket = null;
  }
}

class _BonjourDiscovery {
  static const String serviceType = '_plokee._tcp';

  final DeviceInfo Function() localInfo;
  final void Function(DeviceInfo info, List<String> addresses) onDeviceSeen;

  BonsoirBroadcast? _broadcast;
  BonsoirDiscovery? _discovery;
  StreamSubscription? _sub;

  /// Addresses seen per device id, freshest first, capped.
  ///
  /// A resolve reports whatever the mDNS responder answered on one interface,
  /// and it is not always right: bonsoir keys its pending resolutions by a
  /// `DNSServiceRef` pointer the system reuses, so a busy network occasionally
  /// pairs one service with another's address. Remembering the candidates
  /// makes a single bad answer cost one failed dial instead of blackholing
  /// the peer until it is rediscovered.
  final Map<String, List<String>> _addressesById = {};
  static const int _maxAddressesPerDevice = 4;

  _BonjourDiscovery({required this.localInfo, required this.onDeviceSeen});

  Future<void> start() async {
    final me = localInfo();
    final broadcast = BonsoirBroadcast(
      service: BonsoirService(
        // Unique-per-device name avoids mDNS conflict renames colliding.
        name: '${me.name} [${me.id.substring(0, 6)}]',
        type: serviceType,
        port: me.port,
        attributes: {
          'v': '$protocolVersion',
          'id': me.id,
          'name': me.name,
          'platform': me.platform,
          'pk': me.publicKey,
        },
      ),
    );
    await broadcast.initialize();
    await broadcast.start();
    _broadcast = broadcast;

    final discovery = BonsoirDiscovery(type: serviceType);
    await discovery.initialize();
    _sub = discovery.eventStream?.listen(
      (event) {
        switch (event) {
          case BonsoirDiscoveryServiceFoundEvent(:final service):
            () async {
              try {
                await discovery.serviceResolver.resolveService(service);
              } catch (_) {}
            }();
          case BonsoirDiscoveryServiceResolvedEvent(:final service):
          case BonsoirDiscoveryServiceUpdatedEvent(:final service):
            _handleResolved(service);
          default:
            break;
        }
      },
      onError: (_) {
        // e.g. NoAuth in the iOS Simulator; UDP discovery covers that case.
      },
    );
    await discovery.start();
    _discovery = discovery;
  }

  void _handleResolved(BonsoirService service) {
    final attrs = service.attributes;
    final me = localInfo();
    final id = attrs['id'];
    if (id == null || id == me.id) return;
    if (attrs['v'] != '$protocolVersion') return;
    final pk = attrs['pk'];
    final name = attrs['name'];
    final platform = attrs['platform'];
    if (pk == null || name == null || platform == null) return;
    final fresh = rankLanAddresses(service.hostAddresses);
    if (fresh.isEmpty) return;
    final addresses = rankLanAddresses([
      ...fresh,
      ...?_addressesById[id],
    ]).take(_maxAddressesPerDevice).toList();
    _addressesById[id] = addresses;
    onDeviceSeen(
      DeviceInfo(
        id: id,
        name: name,
        platform: platform,
        publicKey: pk,
        port: service.port,
      ),
      addresses,
    );
  }

  /// Restarts the broadcast to pick up a changed name/port.
  Future<void> restart() async {
    final broadcast = _broadcast;
    _broadcast = null;
    await broadcast?.stop();
    try {
      final me = localInfo();
      final fresh = BonsoirBroadcast(
        service: BonsoirService(
          name: '${me.name} [${me.id.substring(0, 6)}]',
          type: serviceType,
          port: me.port,
          attributes: {
            'v': '$protocolVersion',
            'id': me.id,
            'name': me.name,
            'platform': me.platform,
            'pk': me.publicKey,
          },
        ),
      );
      await fresh.initialize();
      await fresh.start();
      _broadcast = fresh;
    } catch (_) {}
  }

  void stop() {
    _sub?.cancel();
    _broadcast?.stop();
    _discovery?.stop();
    _broadcast = null;
    _discovery = null;
    _addressesById.clear();
  }
}

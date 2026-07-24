import 'package:flutter_test/flutter_test.dart';
import 'package:plokee/src/discovery.dart';

void main() {
  group('rankLanAddresses', () {
    test('drops addresses that cannot point at another host', () {
      // A real capture: a Mac with a Thunderbolt bridge publishes all four
      // under one hostname, and only 192.168.178.22 routes from the LAN.
      expect(
        rankLanAddresses(
            ['0.0.0.0', '127.0.0.1', '169.254.220.15', '192.168.178.22']),
        ['192.168.178.22', '169.254.220.15'],
      );
    });

    test('sorts link-local behind routable addresses whatever the order', () {
      expect(
        rankLanAddresses(['169.254.1.2', '10.0.0.5']),
        ['10.0.0.5', '169.254.1.2'],
      );
      expect(
        rankLanAddresses(['10.0.0.5', '169.254.1.2']),
        ['10.0.0.5', '169.254.1.2'],
      );
    });

    test('keeps link-local when it is all there is (direct cable)', () {
      expect(rankLanAddresses(['169.254.1.2']), ['169.254.1.2']);
    });

    test('drops IPv6, junk and duplicates', () {
      expect(
        rankLanAddresses([
          'fe80::c51:5062:e422:58e4%en0',
          '2a02:8071:7100:3120::1',
          'not-an-address',
          '192.168.1.4',
          '192.168.1.4',
        ]),
        ['192.168.1.4'],
      );
    });

    test('is empty when nothing is dialable', () {
      expect(rankLanAddresses(['127.0.0.1', '0.0.0.0']), isEmpty);
      expect(rankLanAddresses(const []), isEmpty);
    });
  });
}

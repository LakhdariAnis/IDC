import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'pc_device.dart';

class DiscoveryService {
  Future<List<PcDevice>> scan({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
    );
    socket.broadcastEnabled = true;

    print('Discovery scan started...');

    final broadcastAddr = InternetAddress('192.168.100.255');
    final message = utf8.encode('IDC_DISCOVER');
    socket.send(message, broadcastAddr, 58111);

    final completer = Completer<List<PcDevice>>();
    final results = <PcDevice>[];
    final seenPcIds = <String>{};

    final subscription = socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram == null) return;
        try {
          final jsonStr = utf8.decode(datagram.data);
          final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
          final device = PcDevice.fromJson(jsonMap, datagram.address.address);
          if (seenPcIds.add(device.pcId)) {
            results.add(device);
            print('  Discovery reply from ${device.name} at ${device.ip}');
          }
        } catch (_) {
          // skip malformed packets
        }
      }
    });

    unawaited(Future.delayed(timeout, () {
      subscription.cancel();
      socket.close();
      print('Discovery scan completed, ${results.length} device(s) found');
      completer.complete(results);
    }));

    return completer.future;
  }
}

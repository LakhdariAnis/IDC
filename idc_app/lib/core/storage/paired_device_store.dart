import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../network/pc_device.dart';

class PairedDeviceStore {
  static const _key = 'paired_device';

  // TODO: re-enable once single-system flow is confirmed stable
  // Future<void> savePairedDevice(PcDevice device) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_key, jsonEncode(device.toJson()));
  // }

  Future<PcDevice?> getPairedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return PcDevice.fromJson(map, map['ip'] as String);
  }

  Future<void> clearPairedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

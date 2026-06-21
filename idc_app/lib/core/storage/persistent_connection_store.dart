import 'package:shared_preferences/shared_preferences.dart';

class PersistentConnectionStore {
  static const _keyIp = 'last_connected_ip';
  static const _keyPort = 'last_connected_port';
  static const _keyDeviceName = 'last_connected_device_name';
  static const _keyPcId = 'last_connected_pc_id';

  Future<void> save(String ip, int port, String deviceName, String pcId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIp, ip);
    await prefs.setInt(_keyPort, port);
    await prefs.setString(_keyDeviceName, deviceName);
    await prefs.setString(_keyPcId, pcId);
  }

  Future<({String ip, int port, String deviceName, String pcId})?>
      load() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_keyIp);
    final port = prefs.getInt(_keyPort);
    final deviceName = prefs.getString(_keyDeviceName);
    final pcId = prefs.getString(_keyPcId);
    if (ip == null || port == null || deviceName == null || pcId == null) {
      return null;
    }
    return (ip: ip, port: port, deviceName: deviceName, pcId: pcId);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIp);
    await prefs.remove(_keyPort);
    await prefs.remove(_keyDeviceName);
    await prefs.remove(_keyPcId);
  }
}

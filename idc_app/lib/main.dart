import 'package:flutter/material.dart';
import 'core/network/foreground_service.dart';
import 'core/storage/device_id_store.dart';
import 'theme/app_theme.dart';
import 'screens/gate_connection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deviceId = await DeviceIdStore().getDeviceId();
  debugPrint('Device ID: $deviceId');
  ForegroundService.initialize(autoReconnect: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IDC App',
      theme: AppTheme.darkTheme,
      home: const GateConnectionScreen(),
    );
  }
}

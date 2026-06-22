import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../storage/device_id_store.dart';
import '../clipboard_history.dart';
import '../storage/clipboard_store.dart';
import '../storage/persistent_connection_store.dart';
import 'connection_manager.dart' as cm;
import 'foreground_task_handler.dart';
import 'pc_device.dart';

class ForegroundService {
  static final ValueNotifier<cm.ConnectionState> state =
      ValueNotifier(cm.ConnectionState.idle);

  static PcDevice? _connectedDevice;
  static bool _initialized = false;

  static void initialize({bool autoReconnect = false}) {
    if (_initialized) return;
    _initialized = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'idc_connection_channel',
        channelName: 'IDC Connection',
        channelDescription: 'Shows IDC connection status',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);

    if (autoReconnect) {
      _tryAutoReconnect();
    }
  }

  static Future<void> _tryAutoReconnect() async {
    final saved = await PersistentConnectionStore().load();
    if (saved != null) {
      state.value = cm.ConnectionState.connecting;
      connect(
        PcDevice(
          name: saved.deviceName,
          ip: saved.ip,
          wsPort: saved.port,
          pcId: saved.pcId,
        ),
      );
    }
  }

  static Future<void> connect(PcDevice device) async {
    _connectedDevice = device;
    state.value = cm.ConnectionState.connecting;

    await PersistentConnectionStore().save(
      device.ip,
      device.wsPort,
      device.name,
      device.pcId,
    );

    final deviceId = await DeviceIdStore().getDeviceId();

    await FlutterForegroundTask.saveData(key: 'ip', value: device.ip);
    await FlutterForegroundTask.saveData(key: 'port', value: device.wsPort);
    await FlutterForegroundTask.saveData(key: 'deviceId', value: deviceId);
    await FlutterForegroundTask.saveData(key: 'deviceName', value: device.name);

    final result = await FlutterForegroundTask.startService(
      callback: foregroundTaskMain,
      notificationTitle: 'IDC',
      notificationText: 'Connecting to ${device.name}...',
    );

    if (result is ServiceRequestFailure) {
      final error = result.error;
      print('ForegroundService.connect: startService failed: $error');
      if (error is ServiceAlreadyStartedException) {
        print('ForegroundService.connect: service already running, '
            'relying on existing state');
      } else if (error is ServiceNotInitializedException) {
        state.value = cm.ConnectionState.error;
      } else {
        state.value = cm.ConnectionState.error;
      }
    }
  }

  static void disconnect() {
    FlutterForegroundTask.sendDataToTask({
      'command': 'disconnect',
    });
    FlutterForegroundTask.stopService();
    _connectedDevice = null;
    state.value = cm.ConnectionState.idle;
    PersistentConnectionStore().clear();
  }

  static PcDevice? get connectedDevice => _connectedDevice;

  static void updateNotification({
    required String title,
    required String text,
  }) {
    FlutterForegroundTask.sendDataToTask({
      'command': 'update_notification',
      'title': title,
      'text': text,
    });
  }

  static void _onTaskData(Object data) {
    if (data is! Map) return;

    final type = data['type'] as String?;
    if (type == 'state') {
      final stateStr = data['state'] as String? ?? 'idle';
      state.value = _parseState(stateStr);
    } else if (type == 'clipboard_received') {
      final text = data['text'] as String? ?? '';
      _handleClipboardReceived(text);
    } else if (type == 'clipboard_sent') {
      final text = data['text'] as String? ?? '';
      if (text.isNotEmpty) {
        ClipboardHistory.instance.add(text, ClipDirection.phoneToPC);
      }
    }
  }

  static Future<void> _handleClipboardReceived(String text) async {
    print('ForegroundService: clipboard_received (${text.length} chars)');

    await Clipboard.setData(ClipboardData(text: text));
    print('ForegroundService: clipboard set');

    ClipboardHistory.instance.add(text, ClipDirection.pcToPhone);

    updateNotification(title: 'IDC', text: 'Clipboard received');
    print('ForegroundService: notification updated to "Clipboard received"');

    await Future.delayed(const Duration(seconds: 3));

    final device = _connectedDevice;
    if (device != null) {
      updateNotification(title: 'IDC', text: 'Connected to ${device.name}');
    } else {
      updateNotification(title: 'IDC', text: 'Connected');
    }
    print('ForegroundService: notification restored');
  }

  static cm.ConnectionState _parseState(String s) {
    switch (s) {
      case 'connecting':
        return cm.ConnectionState.connecting;
      case 'connected':
        return cm.ConnectionState.connected;
      case 'disconnected':
        return cm.ConnectionState.disconnected;
      case 'error':
        return cm.ConnectionState.error;
      default:
        return cm.ConnectionState.idle;
    }
  }
}

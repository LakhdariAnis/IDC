import 'dart:async';
import 'dart:convert';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@pragma('vm:entry-point')
void foregroundTaskMain() {
  FlutterForegroundTask.setTaskHandler(IdcTaskHandler());
}

class IdcTaskHandler extends TaskHandler {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  String _deviceName = 'PC';
  String _ip = '';
  int _port = 0;
  String _deviceId = '';
  int _unansweredPings = 0;
  bool _isConnected = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('IdcTaskHandler.onStart: starter=$starter');
    _ip = (await FlutterForegroundTask.getData<String>(key: 'ip')) ?? '';
    _port = (await FlutterForegroundTask.getData<int>(key: 'port')) ?? 0;
    _deviceId =
        (await FlutterForegroundTask.getData<String>(key: 'deviceId')) ?? '';
    _deviceName =
        (await FlutterForegroundTask.getData<String>(key: 'deviceName')) ??
            'PC';

    print('IdcTaskHandler.onStart: ip=$_ip port=$_port deviceId=$_deviceName');

    if (_ip.isEmpty || _port == 0 || _deviceId.isEmpty) {
      print('IdcTaskHandler.onStart: missing data, sending error');
      _sendState('error');
      return;
    }

    _connect();
  }

  void _connect() async {
    print('IdcTaskHandler._connect: connecting to ws://$_ip:$_port');
    _sendState('connecting');
    _updateNotification('IDC', 'Connecting to $_deviceName...');

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$_ip:$_port'),
      );

      await _channel!.ready;
      print('IdcTaskHandler._connect: channel ready, sending handshake');

      final handshake = jsonEncode({
        'device_id': _deviceId,
        'device_name': _deviceName,
      });
      _channel!.sink.add(handshake);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _isConnected = true;
      print('IdcTaskHandler._connect: connected successfully');
    } catch (e) {
      print('IdcTaskHandler._connect: failed: $e');
      _isConnected = false;
      _sendState('error');
      _startReconnectLoop();
    }
  }

  void _onMessage(dynamic message) {
    if (message == 'pong') {
      _unansweredPings = 0;
      return;
    }

    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      if (data['status'] == 'accepted') {
        print('IdcTaskHandler: handshake accepted for $_deviceName');
        _isConnected = true;
        _sendState('connected');
        _updateNotification('IDC', 'Connected to $_deviceName');
      }
    } catch (_) {
      print('IdcTaskHandler: non-json message from server: $message');
    }

    FlutterForegroundTask.sendDataToMain({
      'type': 'data',
      'message': message,
    });
  }

  void _onError(Object error) {
    _isConnected = false;
    _sendState('disconnected');
    _updateNotification('IDC', 'Connection lost — reconnecting...');
    _startReconnectLoop();
  }

  void _onDone() {
    _isConnected = false;
    _sendState('disconnected');
    _updateNotification('IDC', 'Connection lost — reconnecting...');
    _startReconnectLoop();
  }

  void _startReconnectLoop() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _connect();
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (!_isConnected || _channel == null) return;

    try {
      _channel!.sink.add('ping');
    } catch (_) {
      return;
    }

    _unansweredPings++;
    if (_unansweredPings >= 3) {
      _isConnected = false;
      _subscription?.cancel();
      _subscription = null;
      _channel?.sink.close();
      _channel = null;
      _sendState('disconnected');
      _updateNotification('IDC', 'Connection lost — reconnecting...');
      _startReconnectLoop();
    }
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map) {
      final command = data['command'] as String?;
      if (command == 'disconnect') {
        _cleanup();
        _sendState('idle');
        _updateNotification('IDC', 'Disconnected');
      } else if (command == 'update_notification') {
        _updateNotification(
          data['title'] as String? ?? 'IDC',
          data['text'] as String? ?? '',
        );
      }
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _cleanup();
  }

  void _cleanup() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  void _sendState(String state) {
    print('IdcTaskHandler._sendState: $state');
    FlutterForegroundTask.sendDataToMain({
      'type': 'state',
      'state': state,
    });
  }

  void _updateNotification(String title, String text) {
    FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
    );
  }
}

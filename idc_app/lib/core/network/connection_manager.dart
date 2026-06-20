import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../storage/device_id_store.dart';
import 'pc_device.dart';

enum ConnectionState { idle, connecting, pending, connected, disconnected, error }

class ConnectionManager {
  final ValueNotifier<ConnectionState> state =
      ValueNotifier(ConnectionState.idle);

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;
  Timer? _connectionTimer;
  Completer<void>? _connectCompleter;
  bool _handshakeComplete = false;
  int _unansweredPings = 0;

  PcDevice? _lastDevice;
  bool _wasEverConnected = false;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;

  ConnectionManager() {
    state.addListener(_onStateChanged);
  }

  Future<void> connect(PcDevice device) async {
    disconnect();

    _lastDevice = device;
    state.value = ConnectionState.connecting;
    print('Connecting to ${device.name} @ ${device.ip}:${device.wsPort}...');

    _connectionTimer = Timer(const Duration(seconds: 12), () {
      if (!_handshakeComplete) {
        print('Connection timed out after 12s');
        state.value = ConnectionState.error;
        _connectCompleter?.completeError('Connection timed out');
        _connectCompleter = null;
        _subscription?.cancel();
        _subscription = null;
        _channel?.sink.close();
        _channel = null;
      }
    });

    try {
      final deviceId = await DeviceIdStore().getDeviceId();

      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${device.ip}:${device.wsPort}'),
      );

      _connectCompleter = Completer<void>();
      _handshakeComplete = false;

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onStreamError,
        onDone: _onStreamDone,
      );

      print('Awaiting ready...');
      await _channel!.ready;
      print('Channel ready, sending handshake');

      final handshake = jsonEncode({
        'device_id': deviceId,
        'device_name': 'My Phone',
      });
      _channel!.sink.add(handshake);

      return _connectCompleter!.future;
    } catch (e) {
      _cancelConnectionTimer();
      state.value = ConnectionState.error;
      print('Connection error: $e');
      _connectCompleter?.completeError(e);
      _connectCompleter = null;
      return;
    }
  }

  void disconnect() {
    _stopHeartbeat();
    _cancelConnectionTimer();
    if (!_isReconnecting) {
      _stopReconnectLoop();
    }
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _handshakeComplete = false;
    _connectCompleter?.completeError('Disconnected', StackTrace.current);
    _connectCompleter = null;
    state.value = ConnectionState.idle;
    print('Disconnected');
  }

  // ---------------------------------------------------------------------------
  // Internal state handler — drives the reconnect loop
  // ---------------------------------------------------------------------------

  void _onStateChanged() {
    final currentState = state.value;
    if (currentState == ConnectionState.connected) {
      _stopReconnectLoop();
    } else if ((currentState == ConnectionState.disconnected ||
            currentState == ConnectionState.error) &&
        _wasEverConnected) {
      _startReconnectLoop();
    }
  }

  void _startReconnectLoop() {
    if (_reconnectTimer != null) return;
    print('Starting reconnect loop (every 5s)...');
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_lastDevice == null) {
        _stopReconnectLoop();
        return;
      }
      _isReconnecting = true;
      connect(_lastDevice!).then((_) {
        _isReconnecting = false;
      }).catchError((_) {
        _isReconnecting = false;
      });
    });
  }

  void _stopReconnectLoop() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Internal stream handlers
  // ---------------------------------------------------------------------------

  void _onMessage(dynamic message) {
    print('Raw message received: $message');
    if (!_handshakeComplete) {
      _handleHandshakeResponse(message);
      return;
    }

    if (message == 'pong') {
      _unansweredPings = 0;
    }
  }

  void _onStreamError(Object error) {
    _cancelConnectionTimer();
    if (!_handshakeComplete) {
      state.value = ConnectionState.error;
      _connectCompleter?.completeError(error);
      _connectCompleter = null;
    } else {
      state.value = ConnectionState.disconnected;
      print('Connection error: $error');
      _stopHeartbeat();
    }
  }

  void _onStreamDone() {
    _cancelConnectionTimer();
    print('Stream onDone fired (handshakeComplete: $_handshakeComplete)');
    if (!_handshakeComplete) {
      state.value = ConnectionState.error;
      _connectCompleter?.completeError('Connection closed before handshake');
      _connectCompleter = null;
    } else {
      state.value = ConnectionState.disconnected;
      print('Connection closed');
      _stopHeartbeat();
    }
  }

  void _handleHandshakeResponse(dynamic message) {
    _handshakeComplete = true;
    _cancelConnectionTimer();
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      if (data['status'] == 'accepted') {
        _wasEverConnected = true;
        state.value = ConnectionState.connected;
        print('Handshake accepted');
        _startHeartbeat();
        _connectCompleter?.complete();
      } else {
        state.value = ConnectionState.error;
        print('Unexpected handshake response: $data');
        _connectCompleter
            ?.completeError('Unexpected handshake response: $data');
      }
    } catch (e) {
      state.value = ConnectionState.error;
      print('Failed to parse handshake response: $e');
      _connectCompleter?.completeError(e);
    }
    _connectCompleter = null;
  }

  // ---------------------------------------------------------------------------
  // Heartbeat
  // ---------------------------------------------------------------------------

  void _startHeartbeat() {
    _unansweredPings = 0;
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_channel == null) return;
      try {
        _channel!.sink.add('ping');
      } catch (_) {
        return;
      }
      _unansweredPings++;
      if (_unansweredPings >= 3) {
        print('Heartbeat: 3 pings unanswered, disconnecting');
        state.value = ConnectionState.disconnected;
        _stopHeartbeat();
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _cancelConnectionTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }
}

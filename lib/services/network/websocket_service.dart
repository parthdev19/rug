/// WebSocket service for real-time multiplayer communication.
///
/// Manages WebSocket connection lifecycle including auto-reconnect,
/// message routing, and connection state tracking.
library;

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rug/config/env/env_config.dart';
import 'package:rug/core/constants/app_constants.dart';
import 'package:rug/core/enums/app_enums.dart';
import 'package:rug/core/types/typedefs.dart';
import 'package:rug/services/logging/app_logger.dart';

class WebSocketService {
  WebSocketService._();

  static final WebSocketService instance = WebSocketService._();

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  WsConnectionState _connectionState = WsConnectionState.disconnected;
  WsConnectionState get connectionState => _connectionState;

  final _stateController = StreamController<WsConnectionState>.broadcast();
  Stream<WsConnectionState> get stateStream => _stateController.stream;

  final _messageController = StreamController<JSON>.broadcast();
  Stream<JSON> get messageStream => _messageController.stream;

  /// Connect to the WebSocket server.
  Future<void> connect({String? token}) async {
    if (_connectionState == WsConnectionState.connected) return;

    _updateState(WsConnectionState.connecting);
    AppLogger.info('WebSocket connecting...');

    try {
      final wsUrl = Uri.parse(EnvConfig.instance.wsBaseUrl);
      final uri = token != null
          ? wsUrl.replace(queryParameters: {'token': token})
          : wsUrl;

      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _updateState(WsConnectionState.connected);
      _reconnectAttempts = 0;
      _startHeartbeat();
      AppLogger.info('WebSocket connected');

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );
    } catch (e) {
      AppLogger.error('WebSocket connection failed', error: e);
      _updateState(WsConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// Send a message through the WebSocket.
  void send(String event, [JSON? data]) {
    if (_connectionState != WsConnectionState.connected) {
      AppLogger.warning('WebSocket not connected — cannot send: $event');
      return;
    }

    final payload = jsonEncode({
      'event': event,
      'data': ?data,
    });

    _channel?.sink.add(payload);
    AppLogger.debug('WS → $event');
  }

  /// Disconnect from the WebSocket.
  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _updateState(WsConnectionState.disconnected);
    AppLogger.info('WebSocket disconnected');
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as JSON;
      AppLogger.debug('WS ← ${data['event']}');
      _messageController.add(data);
    } catch (e) {
      AppLogger.error('WebSocket message parse error', error: e);
    }
  }

  void _onError(Object error) {
    AppLogger.error('WebSocket error', error: error);
    _updateState(WsConnectionState.error);
    _scheduleReconnect();
  }

  void _onDone() {
    AppLogger.warning('WebSocket connection closed');
    _updateState(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      AppLogger.error('Max WebSocket reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;
    _updateState(WsConnectionState.reconnecting);

    final delay = AppConstants.webSocketReconnectDelay * _reconnectAttempts;
    AppLogger.info('WebSocket reconnecting in ${delay.inSeconds}s '
        '(attempt $_reconnectAttempts/$_maxReconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, connect);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => send('ping'),
    );
  }

  void _updateState(WsConnectionState state) {
    _connectionState = state;
    _stateController.add(state);
  }

  /// Dispose all resources.
  void dispose() {
    disconnect();
    _stateController.close();
    _messageController.close();
  }
}

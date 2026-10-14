
import 'package:alpha_track/core/api_urls/api_urls.dart';
import 'package:alpha_track/services/storage_services/storage_services.dart';
import 'package:alpha_track/utils/app_log/app_log.dart';
import 'package:alpha_track/utils/app_log/error_log.dart';
import 'package:alpha_track/utils/demo_data/demo_data.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class AppSocketAllOperation {
  AppSocketAllOperation._privateConstructor();
  static final AppSocketAllOperation _instance =
      AppSocketAllOperation._privateConstructor();
  static AppSocketAllOperation get instance => _instance;

  io.Socket? appRootSocket;
  bool _isConnecting = false;
  String? _connectedWithToken;
  final Map<String, List<void Function(dynamic)>> _eventHandlers = {};

  bool get isConnected => appRootSocket?.connected == true;

  /// Connect when a stored access token exists. Skips in demo mode.
  void connectIfAuthenticated() {
    if (kDemoMode) return;

    final token = StorageServices.instance.getAccessToken();
    if (token.isEmpty) {
      appLog('Socket connect skipped: no access token');
      return;
    }

    if (isConnected && _connectedWithToken == token) {
      return;
    }

    if (appRootSocket != null) {
      _tearDownSocket(keepHandlers: true);
    }

    _connectSocketToServer(token);
  }

  /// Logout: disconnect and drop all registered handlers.
  void disconnectAndClear() {
    _tearDownSocket(keepHandlers: false);
    _connectedWithToken = null;
  }

  void initializeSocket() {
    connectIfAuthenticated();
  }

  void readEvent({
    required String event,
    required void Function(dynamic) handler,
  }) {
    try {
      if (!_eventHandlers.containsKey(event)) {
        _eventHandlers[event] = [];
      }
      _eventHandlers[event]!.add(handler);

      if (isConnected) {
        _attachEventListeners(event);
      } else {
        connectIfAuthenticated();
      }
    } catch (e, stackTrace) {
      errorLog("readEvent ($event)$e", stackTrace);
    }
  }

  void removeHandlersForEvent(String event) {
    _eventHandlers.remove(event);
    appRootSocket?.off(event);
  }

  void _attachEventListeners(String event) {
    final handlers = _eventHandlers[event];
    if (handlers == null || handlers.isEmpty) return;

    appRootSocket?.off(event);
    appRootSocket?.on(event, (data) {
      appLog("Received event: $event ");
      appLog("with data: $data");
      for (final handler in handlers) {
        handler(data);
      }
    });
  }

  void _attachAllEventListeners() {
    for (final event in _eventHandlers.keys) {
      _attachEventListeners(event);
    }
  }

  void emitEvent(String event, dynamic data) {
    try {
      if (isConnected) {
        appRootSocket?.emit(event, data);
      } else {
        connectIfAuthenticated();
        _onceConnected(() {
          appRootSocket?.emit(event, data);
        });
      }
    } catch (e, stackTrace) {
      errorLog("emitEvent ($event) $e", stackTrace);
    }
  }

  void _onceConnected(void Function() callback) {
    if (isConnected) {
      callback();
      return;
    }

    void listener(dynamic _) {
      try {
        callback();
        appRootSocket?.off('connect', listener);
      } catch (e) {
        errorLog("listener", e);
      }
    }

    appRootSocket?.on('connect', listener);
  }

  void vendorLiveLocationUpdate({
    required String orderId,
    required dynamic latitude,
    required dynamic longitude,
  }) {
    try {
      final data = {
        "orderId": orderId,
        "latitude": _convertToDouble(latitude),
        "longitude": _convertToDouble(longitude),
      };
      emitEvent("liveTracking", data);
    } catch (e, stackTrace) {
      errorLog("vendorLiveLocationUpdate$e", stackTrace);
    }
  }

  double _convertToDouble(dynamic value) {
    try {
      return double.parse(value.toString());
    } catch (e, stackTrace) {
      errorLog("_convertToDouble $e", stackTrace);
      return 0.0;
    }
  }

  void _connectSocketToServer(String accessToken) {
    try {
      if (_isConnecting) return;

      _isConnecting = true;
      _connectedWithToken = accessToken;
      appLog("Attempting to connect socket...");

      appRootSocket = io.io(
        ApiUrls.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': accessToken})
            .enableReconnection()
            .build(),
      );

      appRootSocket?.onConnect((_) {
        _isConnecting = false;
        appLog("Socket connected");
        _attachAllEventListeners();
      });

      appRootSocket?.onDisconnect((_) {
        errorLog("Socket disconnected", "");
        _isConnecting = false;
      });

      appRootSocket?.onConnectError((data) {
        errorLog("Connect error", data);
        _isConnecting = false;
      });

      appRootSocket?.onError((data) {
        errorLog("Error", data);
        _isConnecting = false;
      });

      appRootSocket?.onReconnect((_) {
        appLog("Socket reconnected");
        final token = StorageServices.instance.getAccessToken();
        if (token.isNotEmpty && token != _connectedWithToken) {
          _tearDownSocket(keepHandlers: true);
          connectIfAuthenticated();
        } else {
          _attachAllEventListeners();
        }
      });

      appRootSocket?.connect();
    } catch (e, stackTrace) {
      _isConnecting = false;
      errorLog("_connectSocketToServer $e", stackTrace);
    }
  }

  void reconnect() {
    connectIfAuthenticated();
  }

  void _tearDownSocket({required bool keepHandlers}) {
    if (appRootSocket != null) {
      appRootSocket?.disconnect();
      appRootSocket?.dispose();
      appRootSocket = null;
    }
    if (!keepHandlers) {
      _eventHandlers.clear();
    }
    _isConnecting = false;
  }

  void dispose() {
    disconnectAndClear();
  }
}

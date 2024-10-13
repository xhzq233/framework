// import 'dart:async';
//
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:framework/base.dart';
//
// class NetworkConnectivityProvider extends Provider {
//   static const tag = 'NetworkConnectivityProvider';
//
//   ConnectivityResult get result => _result;
//
//   ConnectivityResult _result = ConnectivityResult.none;
//
//   late final StreamSubscription<ConnectivityResult> _stream;
//   final void Function()? onLoseConnection;
//
//   void _updateConnectivity(ConnectivityResult result) {
//     if (_result == result) return;
//     _result = result;
//     if (result == ConnectivityResult.none) {
//       onLoseConnection?.call();
//     }
//     notifyListeners();
//   }
//
//   NetworkConnectivityProvider([this.onLoseConnection]) {
//     _stream = Connectivity().onConnectivityChanged.listen(_updateConnectivity);
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _stream.cancel();
//   }
//
//   bool get isConnected {
//     return _result != ConnectivityResult.none;
//   }
// }

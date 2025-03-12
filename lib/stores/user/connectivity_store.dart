import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobx/mobx.dart';

part 'connectivity_store.g.dart';

class ConnectivityStore = _ConnectivityStoreBase with _$ConnectivityStore;

abstract class _ConnectivityStoreBase with Store {
  _ConnectivityStoreBase() {
    _monitorarConexao();
  }

  @observable
  bool isOffline = false;

  void _monitorarConexao() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      isOffline = results.isEmpty || results.contains(ConnectivityResult.none);
    });
  }
}

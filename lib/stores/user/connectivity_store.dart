import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobx/mobx.dart';

part 'connectivity_store.g.dart';

class ConnectivityStore = _ConnectivityStoreBase with _$ConnectivityStore;

abstract class _ConnectivityStoreBase with Store {
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker.createInstance();

  _ConnectivityStoreBase() {
    _monitorarConexao();
  }

  @observable
  bool isOffline = true;

  void _monitorarConexao() {
    // Monitora mudanças de conectividade de rede (WiFi/4G/etc)
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final hasNetwork = results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (!hasNetwork) {
        // Se não há rede, definitivamente está offline
        isOffline = true;
      } else {
        // Se há rede, verifica se há internet real
        isOffline = !await _connectionChecker.hasConnection;
      }
    });

    // Monitora mudanças de conexão real com a internet
    _connectionChecker.onStatusChange.listen((InternetConnectionStatus status) {
      isOffline = status == InternetConnectionStatus.disconnected;
    });
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/auth/firebase_options.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/admin/comanda_store.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:provider/provider.dart';

final UserComandaStore userComandaStore = UserComandaStore();

void monitorarConexao() {
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
    if (results.isNotEmpty && results.contains(ConnectivityResult.none)) {
      print('No internet connection');
    } else {
      print('Internet connection restored');
      userComandaStore.sincronizarPendencias();
    }
  });
}


void main() async {
  await initializeDateFormatting('pt_BR', null);
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
  monitorarConexao();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ComandaStore>(create: (_) => ComandaStore()),
        Provider<SaborStore>(create: (_) => SaborStore()),
        Provider<UserComandaStore>(create: (_) => UserComandaStore()),
        Provider<UserSaborStore>(create: (_) => UserSaborStore()),
      ],
      child: MaterialApp(
        title: 'Flutter Firebase Auth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: Routes.routes,
        initialRoute: RouteName.splash,
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/auth/firebase_options.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/connectivity_store.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/stores/user_sabor_store.dart';
import 'package:provider/provider.dart';

final UserComandaStore userComandaStore = UserComandaStore();

final ConnectivityStore connectivityStore = ConnectivityStore();

void main() async {
  await initializeDateFormatting('pt_BR', null);
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<UserSaborStore>(create: (_) => UserSaborStore()),
        Provider<UserComandaStore>(create: (_) => UserComandaStore()),
        Provider<DescartaveisStore>(create: (_) => DescartaveisStore()),
        Provider<ConnectivityStore>(create: (_) => connectivityStore),
      ],
      child: MaterialApp(
        title: 'Orama Checklist',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: const ColorScheme.light(
                primary: Color(0xFF00A676), brightness: Brightness.light)),
        routes: Routes.routes,
        initialRoute: RouteName.splash,
      ),
    );
  }
}

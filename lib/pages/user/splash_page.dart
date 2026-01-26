import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orama_user/pages/user/user_comandas_page.dart';
import 'package:orama_user/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  //final CheckUpdates checkUpdates = CheckUpdates();
  //final FlutterAppInstaller flutterAppInstaller = FlutterAppInstaller();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _startAnimaton();
  }

  Future<void> _checkLoginStatus() async {
    // Simula um tempo de carregamento (ex: carregando recursos iniciais)

    // Verifica se o usuário está logado
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Usuário está logado, redireciona para a página inicial
      Navigator.of(context).pushReplacementNamed(RouteName.user_comandas_page);
    } else {
      // Usuário não está logado, redireciona para a tela de login
      Navigator.of(context).pushReplacementNamed(RouteName.auth);
    }
  }

  Future<void> _startAnimaton() async {
    Timer(Duration(seconds: 5), _checkLoginStatus);
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
          child: FadeTransition(
              opacity: _animation,
              child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Color(0xff006764),
                child: Center(
                  child: Image.asset(
                    'lib/images/splashscreen.png',
                  ),
                ),
              ))),
    );
  }
}

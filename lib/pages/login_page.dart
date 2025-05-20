import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orama_user/others/field_validators.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/utils/exit_dialog_utils.dart';
import 'package:orama_user/widgets/my_textfield.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool isLoading = false;

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print('Login realizado com sucesso!');
      final userId = authResult.user!.uid;
      if (userId != null) {
        GetStorage().write('userId', userId);
      }

      // Obtém os dados do usuário do Firestore
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userData.exists) {
        final role = userData['role'];
        // Redireciona para a página correta com base no papel do usuário
        if (role == 'user') {
          if (mounted) {
            Navigator.of(context)
                .pushReplacementNamed(RouteName.user_comandas_page);
          }
        } else {
          _showErrorDialog('Usuário sem permissão.');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showSnackbar('Email não cadastrado');
      } else {
        _showSnackbar('Erro: ${e.message}');
      }
    } catch (e) {
      _showSnackbar('Ocorreu um erro. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Configura a cor da barra de status
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          const Color(0xff60C03D), // Define a cor da barra de status
      statusBarIconBrightness: Brightness.light, // Ícones brancos na barra
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bool? shouldPop = await DialogUtils.showConfirmationDialog(
          context: context,
          title: 'Confirmação de Saída',
          content: 'Você deseja sair do aplicativo?',
          confirmText: 'Sair',
          cancelText: 'Não',
          onConfirm: () {
            exit(0);
            
          },
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: SizedBox.expand(
          child: Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff60C03D),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Cor da sombra
                    spreadRadius: 5, // Espalhamento
                    blurRadius: 12, // Borrão
                    offset: Offset(0, 3), // Deslocamento (x, y)
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Fazer Login",
                            style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                    fontSize: 40, fontWeight: FontWeight.w500),
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          MyTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            validator: FieldValidators.validateEmail,
                            prefixicon: Icon(Icons.email),
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                          ),
                          MyTextField(
                            controller: _passwordController,
                            hintText: 'Senha',
                            obscureText: obscurePassword,
                            validator: FieldValidators.validatePassword,
                            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                            prefixicon: Icon(Icons.lock),
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (isLoading)
                            CircularProgressIndicator()
                          else
                            ElevatedButton(
                              onPressed: _login,
                              child: Text(
                                'Login',
                                style: TextStyle(color: Color(0xff60C03D)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

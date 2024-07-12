import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
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
  final formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop =
            await DialogUtils.showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  MyTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    validator: FieldValidators.validateEmail,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                    controller: _passwordController,
                    hintText: 'Senha',
                    obscureText: obscurePassword,
                    validator: FieldValidators.validatePassword,
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
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final authResult = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
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
                            Navigator.of(context).pushReplacementNamed(
                                RouteName.user_comandas_page);
                          } else {
                            print("Erro");
                          }
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text('Login'),
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

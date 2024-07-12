import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/others/field_validators.dart';
import 'package:orama_user/pages/user/user.sabores.page.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/widgets/my_button.dart';
import 'package:orama_user/widgets/my_datefield.dart';
import 'package:orama_user/widgets/my_dropdown.dart';
import 'package:orama_user/widgets/my_textfield.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  final List<String> pdvs = [
    "Villa Brunholli",
    "Recanto Marquezim",
    "Sítio Fontebasso",
    "Sítio Sassafraz",
    "Restaurante Travitália",
    "Vinhos Micheletto",
    "Da Roça Gastronomia",
    "Bendito Quintal",
    "Pesqueiro Tambury",
    "VIBE"
  ];
  String? pdvSelecionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Escolha ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        elevation: 4,
        backgroundColor: const Color(0xff60C03D),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(RouteName.login);
            },
          ),
        ],
      ),
      body: Center(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  MyTextField(
                    controller: _nameController,
                    hintText: 'Nome',
                    validator: FieldValidators.validateName,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: MyDropDownButton(
                      hint: "Ponto de Venda",
                      options: pdvs,
                      value: pdvSelecionado,
                      onChanged: (result) {
                        setState(() {
                          pdvSelecionado = result;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
                    child: MyDateField(
                      date: _date,
                      hintText: 'Data',
                      newDate: (newDate) {
                        setState(() {
                          _date = newDate;
                        });
                      },
                    ),
                  ),
                  MyButton(
                    buttonName: 'Próximo',
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserSaboresPage(
                              pdv: pdvSelecionado ?? '',
                              nome: _nameController.text,
                              data: _date.toString(), userId: GetStorage().read('userId'), // Adjust the format as needed
                            ),
                          ),
                        );
                      }
                    },
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

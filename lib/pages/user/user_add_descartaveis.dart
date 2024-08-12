import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/others/field_validators.dart';
import 'package:orama_user/pages/user/user_descartaveis_select.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/widgets/my_button.dart';
import 'package:orama_user/widgets/my_dropdown.dart';
import 'package:orama_user/widgets/my_textfield.dart';

class UserAddDescartaveis extends StatefulWidget {
  @override
  _UserAddDescartaveisState createState() => _UserAddDescartaveisState();
}

class _UserAddDescartaveisState extends State<UserAddDescartaveis> {
  final TextEditingController _nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();

  final List<String> periodo = ["INICIO", "FINAL"];
  String? periodoSelecionado;

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

  // ValueNotifier to track the validation state of the form
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _nameController.dispose();
    isFormValid.dispose();
    super.dispose();
  }

  void _validateForm() {
    isFormValid.value = _nameController.text.isNotEmpty &&
        pdvSelecionado != null &&
        periodoSelecionado != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Descartáveis",
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
                    hintText: 'Seu Nome',
                    validator: FieldValidators.validateName,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: MyDropDownButton(
                      hint: "Periodo",
                      options: periodo,
                      value: periodoSelecionado,
                      onChanged: (result) {
                        setState(() {
                          periodoSelecionado = result;
                          _validateForm(); // Update validation state
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
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
                          _validateForm(); // Update validation state
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isFormValid,
                    builder: (context, isValid, child) {
                      return MyButton(
                        buttonName: 'Próximo',
                        onTap: isValid
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UserDescartaveisSelect(
                                        pdv: pdvSelecionado ?? '',
                                        nome:
                                            "${_nameController.text} (${periodoSelecionado})",
                                        data: _date.toString(),
                                        userId: GetStorage().read('userId'),
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        enabled: isValid,
                      );
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

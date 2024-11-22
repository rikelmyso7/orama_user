import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/others/field_validators.dart';
import 'package:orama_user/pages/user/user.sabores.page.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/widgets/my_button.dart';
import 'package:orama_user/widgets/my_dropdown.dart';
import 'package:orama_user/widgets/my_textfield.dart';

class UserAddSorvetes extends StatefulWidget {
  @override
  _UserAddSorvetesState createState() => _UserAddSorvetesState();
}

class _UserAddSorvetesState extends State<UserAddSorvetes> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caixaInicialController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);
  final TextEditingController _caixaFinalController = TextEditingController();

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

  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _caixaInicialController.addListener(_validateForm);
    _caixaFinalController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _nameController.dispose();
    _caixaInicialController.removeListener(_validateForm);
    _caixaInicialController.dispose();
    _caixaFinalController.removeListener(_validateForm);
    _caixaFinalController.dispose();
    isFormValid.dispose();
    super.dispose();
  }

  void _validateForm() {
    isFormValid.value = _nameController.text.isNotEmpty &&
        pdvSelecionado != null &&
        periodoSelecionado != null &&
        ((periodoSelecionado == "INICIO" &&
                _caixaInicialController.text.isNotEmpty) ||
            (periodoSelecionado == "FINAL" &&
                _caixaFinalController.text.isNotEmpty));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Sorvetes",
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
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight, // Para ocupar no mínimo o tamanho da tela
          ),
          child: Center(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    padding: const EdgeInsets.only(top: 10),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: periodoSelecionado == "INICIO"
                        ? MyTextField(
                            controller: _caixaInicialController,
                            hintText: r'Caixa Inicial R$',
                            validator: FieldValidators.validateMoney,
                            keyBordType: TextInputType.number,
                          )
                        : MyTextField(
                            controller: _caixaFinalController,
                            hintText: r'Caixa Final R$',
                            validator: FieldValidators.validateMoney,
                            keyBordType: TextInputType.number,
                          ),
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
                                      builder: (context) => UserSaboresPage(
                                        pdv: pdvSelecionado ?? '',
                                        nome:
                                            "${_nameController.text} (${periodoSelecionado})",
                                        data: _date.toString(),
                                        userId: GetStorage().read('userId'),
                                        caixaInicial:
                                            periodoSelecionado == "INICIO"
                                                ? _caixaInicialController.text
                                                : null,
                                        caixaFinal:
                                            periodoSelecionado == "FINAL"
                                                ? _caixaFinalController.text
                                                : null,
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

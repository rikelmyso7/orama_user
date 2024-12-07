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
  final TextEditingController _caixaInicialDinheiroController =
      TextEditingController();
  final TextEditingController _caixaInicialPixController =
      TextEditingController();
  final TextEditingController _caixaFinalPixController =
      TextEditingController();
  final TextEditingController _caixaFinalDinheiroController =
      TextEditingController();

  final formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

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
    _caixaInicialDinheiroController.addListener(_validateForm);
    _caixaFinalDinheiroController.addListener(_validateForm);
    _caixaInicialPixController.addListener(_validateForm);
    _caixaFinalPixController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caixaInicialDinheiroController.dispose();
    _caixaFinalDinheiroController.dispose();
    _caixaInicialPixController.dispose();
    _caixaFinalPixController.dispose();
    isFormValid.dispose();
    super.dispose();
  }

  void _validateForm() {
    isFormValid.value = _nameController.text.isNotEmpty &&
        pdvSelecionado != null &&
        periodoSelecionado != null &&
        ((periodoSelecionado == "INICIO" &&
                _caixaInicialDinheiroController.text.isNotEmpty &&
                _caixaInicialPixController.text.isNotEmpty) ||
            (periodoSelecionado == "FINAL" &&
                _caixaFinalDinheiroController.text.isNotEmpty &&
                _caixaFinalPixController.text.isNotEmpty));
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(RouteName.login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
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
                  MyDropDownButton(
                    hint: "Periodo",
                    options: periodo,
                    value: periodoSelecionado,
                    onChanged: (result) {
                      setState(() {
                        periodoSelecionado = result;
                        _validateForm();
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MyDropDownButton(
                    hint: "Ponto de Venda",
                    options: pdvs,
                    value: pdvSelecionado,
                    onChanged: (result) {
                      setState(() {
                        pdvSelecionado = result;
                        _validateForm();
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (periodoSelecionado == "INICIO") ...[
                    MyTextField(
                      controller: _caixaInicialDinheiroController,
                      hintText: r'Caixa Inicial Dinheiro',
                      validator: FieldValidators.validateMoney,
                      keyBordType: TextInputType.number,
                    ),
                    MyTextField(
                      controller: _caixaInicialPixController,
                      hintText: r'Caixa Inicial Pix',
                      validator: FieldValidators.validateMoney,
                      keyBordType: TextInputType.number,
                    ),
                  ] else if (periodoSelecionado == "FINAL") ...[
                    MyTextField(
                      controller: _caixaFinalDinheiroController,
                      hintText: r'Caixa Final Dinheiro',
                      validator: FieldValidators.validateMoney,
                      keyBordType: TextInputType.number,
                    ),
                    MyTextField(
                      controller: _caixaFinalPixController,
                      hintText: r'Caixa Final Pix',
                      validator: FieldValidators.validateMoney,
                      keyBordType: TextInputType.number,
                    ),
                  ],
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
                                        caixaInicial: periodoSelecionado ==
                                                "INICIO"
                                            ? _caixaInicialDinheiroController
                                                .text
                                            : null,
                                        caixaFinal: periodoSelecionado ==
                                                "FINAL"
                                            ? _caixaFinalDinheiroController.text
                                            : null,
                                        pixInicial: periodoSelecionado ==
                                                "INICIO"
                                            ? _caixaInicialPixController.text
                                            : null,
                                        pixFinal: periodoSelecionado == "FINAL"
                                            ? _caixaFinalPixController.text
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

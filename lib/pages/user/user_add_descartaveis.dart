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
  final TextEditingController _customPdvController = TextEditingController();
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
    "Bendito Quintal",
    "Bar da Cachoeira",
    "Sítio São Francisco",
    "Outro",
  ];
  String? pdvSelecionado;

  // ValueNotifier to track the validation state of the form
  final ValueNotifier<bool> isFormValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _customPdvController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _customPdvController.dispose();
    _nameController.dispose();
    isFormValid.dispose();
    super.dispose();
  }

  void _validateForm() {
    isFormValid.value = _nameController.text.isNotEmpty &&
        pdvSelecionado != null &&
        periodoSelecionado != null &&
        (pdvSelecionado != 'Outro' || _customPdvController.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Adicionar Descartáveis",
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
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
                      _validateForm(); // Update validation state
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
                      if (pdvSelecionado != 'Outro') {
                        _customPdvController.clear();
                      }
                      _validateForm();
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                if (pdvSelecionado == 'Outro')
                  MyTextField(
                    controller: _customPdvController,
                    hintText: 'Nome do Ponto de Venda',
                    validator: (value) {
                      if (pdvSelecionado == 'Outro' && (value ?? '').isEmpty) {
                        return 'Digite o nome do ponto de venda';
                      }
                      return null;
                    },
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
                                      pdv: pdvSelecionado == 'Outro'
                                          ? _customPdvController.text
                                          : pdvSelecionado ?? '',
                                      nome: _nameController.text,
                                      data: _date.toString(),
                                      userId: GetStorage().read('userId'),
                                      periodo: periodoSelecionado,
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
    );
  }
}

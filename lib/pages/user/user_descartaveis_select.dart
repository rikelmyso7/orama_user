import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:orama_user/others/field_validators.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';

class UserDescartaveisSelect extends StatefulWidget {
  final String pdv;
  final String nome;
  final String data;
  final String userId;

  const UserDescartaveisSelect({
    Key? key,
    required this.pdv,
    required this.nome,
    required this.data,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserDescartaveisSelect> createState() => _UserDescartaveisSelectState();
}

class _UserDescartaveisSelectState extends State<UserDescartaveisSelect> {
  final List<String> quantities = [];
  final List<String> notes = [];
  final List<bool> fieldsCompleted = [];
  final List<bool> showNotes = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<bool> showTextField;
  late List<TextEditingController> textControllers;
  late List<TextEditingController> noteControllers;
  late List<FocusNode> textFocusNodes;
  late List<FocusNode> noteFocusNodes;

  @override
  void initState() {
    super.initState();
    quantities.addAll(List<String>.filled(descartaveis.length, ''));
    notes.addAll(List<String>.filled(descartaveis.length, ''));
    fieldsCompleted.addAll(List<bool>.filled(descartaveis.length, false));
    showNotes.addAll(List<bool>.filled(descartaveis.length, false));
    showTextField = List<bool>.filled(descartaveis.length, false);
    textControllers = List<TextEditingController>.generate(
        descartaveis.length, (index) => TextEditingController());
    noteControllers = List<TextEditingController>.generate(
        descartaveis.length, (index) => TextEditingController());
    textFocusNodes =
        List<FocusNode>.generate(descartaveis.length, (index) => FocusNode());
    noteFocusNodes =
        List<FocusNode>.generate(descartaveis.length, (index) => FocusNode());

    for (int i = 0; i < textControllers.length; i++) {
      textControllers[i].addListener(() {
        setState(() {
          quantities[i] = textControllers[i].text;
          _checkFieldsCompleted();
        });
      });
      noteControllers[i].addListener(() {
        setState(() {
          notes[i] = noteControllers[i].text;
        });
      });
    }
  }

  Future<void> _saveData() async {
    if (!fieldsCompleted.every((completed) => completed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final comandaId = Uuid().v4();
    final userId = widget.userId;

    final ComandaDescartaveis comanda = ComandaDescartaveis(
      name: widget.nome,
      id: comandaId,
      pdv: widget.pdv,
      userId: userId,
      quantidades: quantities,
      observacoes: notes,
      data: DateTime.now(),
    );

    try {
      await comanda.uploadToFirestore();
      Navigator.pushReplacementNamed(context, RouteName.user_descartaveis_page);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkFieldsCompleted() {
    setState(() {
      for (int i = 0; i < descartaveis.length; i++) {
        fieldsCompleted[i] = quantities[i].isNotEmpty;
      }
    });
  }

  Widget _buildQuantityButtons(int index) {
    List<String> options;

    switch (descartaveis[index].type) {
      case 'numeric':
        options = List.generate(8, (i) => i.toString()); // Example: 0-7
        break;
      case 'fractional':
        options = ['Vazio', '1/4', '2/4', '3/4', '4/4'];
        break;
      case 'text':
        options = ['Cheio', 'Pouco', 'Vazio'];
        break;
      default:
        options = [];
    }

    options.add('Outro');

    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(option),
              selected: quantities[index] == option ||
                  (option == 'Outro' && showTextField[index]),
              selectedColor: Color(0xff60C03D),
              onSelected: (selected) {
                setState(() {
                  if (option == 'Outro') {
                    showTextField[index] = selected;
                    if (selected) {
                      FocusScope.of(context)
                          .requestFocus(textFocusNodes[index]);
                    } else {
                      textControllers[index].clear();
                      quantities[index] = '';
                    }
                  } else {
                    showTextField[index] = false;
                    quantities[index] = selected ? option : '';
                    textControllers[index].clear();
                  }
                  _checkFieldsCompleted();
                });
              },
            );
          }).toList(),
        ),
        if (showTextField[index])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: TextField(
              controller: textControllers[index],
              focusNode: textFocusNodes[index],
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                labelText: 'Digite a quantidade',
                border: OutlineInputBorder(),
                suffixIcon: quantities[index].isNotEmpty
                    ? Icon(Icons.check, color: Colors.green)
                    : Icon(Icons.close, color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Descartáveis - ${widget.pdv}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          elevation: 4,
          backgroundColor: const Color(0xff60C03D),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: descartaveis.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Text(
                        descartaveis[index].name,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildQuantityButtons(index),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Adicionar observações"),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            activeColor: const Color(0xff60C03D),
                            value: showNotes[index],
                            onChanged: (value) {
                              setState(() {
                                showNotes[index] = value;
                                if (value) {
                                  FocusScope.of(context)
                                      .requestFocus(noteFocusNodes[index]);
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    if (showNotes[index])
                      TextField(
                        controller: noteControllers[index],
                        focusNode: noteFocusNodes[index],
                        decoration: InputDecoration(
                          labelText: 'Observações',
                          border: OutlineInputBorder(),
                          suffixIcon: notes[index].isNotEmpty
                              ? Icon(Icons.check, color: Colors.green)
                              : Icon(Icons.close, color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: fieldsCompleted.every((completed) => completed)
            ? FloatingActionButton(
                backgroundColor: const Color(0xff60C03D),
                child: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: _saveData,
              )
            : null,
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    quantities.addAll(List<String>.filled(descartaveis.length, ''));
    notes.addAll(List<String>.filled(descartaveis.length, ''));
    fieldsCompleted.addAll(List<bool>.filled(descartaveis.length, false));
    showNotes.addAll(List<bool>.filled(descartaveis.length, false));
    showTextField = List<bool>.filled(descartaveis.length, false);
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
        fieldsCompleted[i] = quantities[i] != '';
      }
    });
  }

  Widget _buildQuantityButtons(int index) {
    List<String> options;

    switch (descartaveis[index].type) {
      case 'numeric':
        options = List.generate(8, (i) => i.toString()); // Example: 0-9
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
              label: Text(
                option,
              ),
              selected: quantities[index] == option ||
                  (option == 'Outro' && showTextField[index]),
              selectedColor: Color(0xff60C03D),
              onSelected: (selected) {
                setState(() {
                  if (option == 'Outro') {
                    showTextField[index] = selected;
                    if (!selected) {
                      quantities[index] = '';
                    }
                  } else {
                    showTextField[index] = false;
                    quantities[index] = selected ? option : '';
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
              keyboardType: TextInputType.numberWithOptions(),
              decoration: InputDecoration(
                labelText: 'Digite a quantidade',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                quantities[index] = value;
                _checkFieldsCompleted();
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (showNotes[index])
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Observações',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        notes[index] = value;
                      },
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
    );
  }
}

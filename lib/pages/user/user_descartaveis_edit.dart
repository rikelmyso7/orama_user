import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:orama_user/others/field_validators.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';

class UserDescartaveisEdit extends StatefulWidget {
  final ComandaDescartaveis comanda;

  const UserDescartaveisEdit({Key? key, required this.comanda}) : super(key: key);

  @override
  State<UserDescartaveisEdit> createState() => _UserDescartaveisEditState();
}

class _UserDescartaveisEditState extends State<UserDescartaveisEdit> {
  late List<String> quantities;
  late List<String> notes;
  final List<bool> fieldsCompleted = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<bool> showNotes;

  @override
  void initState() {
    super.initState();
    quantities = List.from(widget.comanda.quantidades);
    notes = List.from(widget.comanda.observacoes);
    fieldsCompleted.addAll(List<bool>.filled(descartaveis.length, false));
    showNotes = List<bool>.filled(descartaveis.length, false);
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

    try {
      final userId = GetStorage().read('userId');
      final docRef = _firestore.collection('users')
          .doc(userId)
          .collection('descartaveis').doc(widget.comanda.id);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({
          'quantidades': quantities,
          'observacoes': notes,
        });

        Navigator.pushReplacementNamed(context, RouteName.user_descartaveis_page);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Documento não encontrado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        options = List.generate(10, (i) => i.toString()); // Example: 0-9
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

    return Wrap(
      spacing: 8.0,
      children: options.map((option) {
        return ChoiceChip(
          label: Text(
            option,
          ),
          selected: quantities[index] == option,
          selectedColor: Color(0xff60C03D),
          onSelected: (selected) {
            setState(() {
              quantities[index] = selected ? option : '';
              _checkFieldsCompleted();
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Editar Descartáveis - ${widget.comanda.pdv}",
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  descartaveis[index].name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildQuantityButtons(index),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Adicionar observações"),
                    Switch(
                      value: showNotes[index],
                      onChanged: (value) {
                        setState(() {
                          showNotes[index] = value;
                        });
                      },
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:uuid/uuid.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:orama_user/routes/routes.dart';

class UserDescartaveisEdit extends StatefulWidget {
  final ComandaDescartaveis comanda;

  const UserDescartaveisEdit({Key? key, required this.comanda})
      : super(key: key);

  @override
  State<UserDescartaveisEdit> createState() => _UserDescartaveisEditState();
}

class _UserDescartaveisEditState extends State<UserDescartaveisEdit> {
  late List<String> quantities;
  late List<String> notes;
  late List<bool> showNotes;
  late List<bool> showTextField;

  final List<TextEditingController> textControllers = [];
  final List<TextEditingController> noteControllers = [];
  final List<FocusNode> textFocusNodes = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    quantities = widget.comanda.itens.map((item) => item['Quantidade'] ?? '').toList();
    notes = List.from(widget.comanda.observacoes);
    showNotes = List<bool>.filled(descartaveis.length, false);
    showTextField = List<bool>.filled(descartaveis.length, false);

    for (int i = 0; i < descartaveis.length; i++) {
      textControllers.add(TextEditingController(text: quantities[i]));
      noteControllers.add(TextEditingController(
          text: i < notes.length ? notes[i] : ''));
      textFocusNodes.add(FocusNode());
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_dismissKeyboardOnScroll);
  }

  @override
  void dispose() {
    for (var controller in textControllers) {
      controller.dispose();
    }
    for (var node in textFocusNodes) {
      node.dispose();
    }
    _scrollController.removeListener(_dismissKeyboardOnScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _dismissKeyboardOnScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.isScrollingNotifier.value) {
      _dismissKeyboard();
    }
  }

  Future<void> _saveData() async {
    if (quantities.any((quantity) => quantity.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<Map<String, String>> itens = [];
    for (int i = 0; i < descartaveis.length; i++) {
      itens.add({
        'Item': descartaveis[i].name,
        'Quantidade': quantities[i],
      });
    }

    final updatedComanda = widget.comanda.copyWith(
      itens: itens,
      observacoes: notes,
      data: DateTime.now(),
    );

    try {
      await updatedComanda.uploadToFirestore(); // Salva no Firestore
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

  Widget _buildQuantitySelector(int index) {
    List<String> options;

    switch (descartaveis[index].type) {
      case 'numeric':
        options = List.generate(6, (i) => i.toString());
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

    if (options.length == 1 && options.first == 'Outro') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextField(
          controller: textControllers[index],
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            labelText: 'Digite a quantidade',
            border: OutlineInputBorder(),
            suffixIcon: quantities[index].isNotEmpty
                ? Icon(Icons.check, color: Colors.green)
                : Icon(Icons.close, color: Colors.red),
          ),
          onChanged: (value) {
            setState(() {
              quantities[index] = value;
            });
          },
        ),
      );
    }

    return Column(
      children: [
        ...options.map((option) {
          if (option == 'Outro') {
            return Container();
          }
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: quantities[index],
            onChanged: (value) {
              setState(() {
                showTextField[index] = false;
                quantities[index] = value!;
                textControllers[index].clear();
              });
            },
          );
        }).toList(),
        if (showTextField[index])
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: textControllers[index],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Digite a quantidade',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  quantities[index] = value;
                });
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Editar Descartáveis - ${widget.comanda.pdv}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xff60C03D),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveData,
            ),
          ],
        ),
        body: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          itemCount: descartaveis.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      descartaveis[index].name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildQuantitySelector(index),
                    SwitchListTile(
                      title: Text("Adicionar Observações"),
                      value: showNotes[index],
                      onChanged: (value) {
                        setState(() {
                          showNotes[index] = value;
                        });
                      },
                    ),
                    if (showNotes[index])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: noteControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Observações',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              notes[index] = value;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

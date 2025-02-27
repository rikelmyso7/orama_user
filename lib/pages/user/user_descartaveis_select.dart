import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:uuid/uuid.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:orama_user/routes/routes.dart';

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
  final List<String> quantities = List<String>.filled(descartaveis.length, '');
  final List<String> notes = List<String>.filled(descartaveis.length, '');
  final List<bool> showNotes = List<bool>.filled(descartaveis.length, false);
  final List<bool> showTextField =
      List<bool>.filled(descartaveis.length, false);

  final List<TextEditingController> textControllers = [];
  final List<TextEditingController> noteControllers = [];
  final List<FocusNode> textFocusNodes = [];
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < descartaveis.length; i++) {
      textControllers.add(TextEditingController());
      noteControllers.add(TextEditingController());
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
    // Verifica se há pelo menos um item preenchido
    if (quantities.every((quantity) => quantity.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha pelo menos um item.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Cria a lista de itens com nome, quantidade e observação
    final List<Map<String, String>> itens = [];

    for (int i = 0; i < descartaveis.length; i++) {
      // Verifica se o usuário inseriu alguma quantidade para o item
      if (quantities[i].isNotEmpty) {
        itens.add({
          'Item': descartaveis[i].name, // Nome do item
          'Quantidade': quantities[i], // Quantidade do item
          'Observacao': notes[i].isNotEmpty ? notes[i] : '', // Observação
        });
      }
    }

    // Gera um ID único para a comanda
    final comandaId = Uuid().v4();

    // Cria o objeto ComandaDescartaveis com os itens e observações associadas
    final ComandaDescartaveis comanda = ComandaDescartaveis(
      name: widget.nome,
      id: comandaId,
      pdv: widget.pdv,
      userId: widget.userId,
      itens: itens, // Agora os itens incluem quantidade e observação
      observacoes: [], // Removemos a lista separada de observações
      data: DateTime.now(),
    );

    try {
      await comanda.uploadToFirestore(); // Salva no Firestore
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

    // Verifica se "Outro" é a única opção disponível
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
            return Container(); // Não exibe a opção "Outro" no RadioListTile
          }
          return RadioListTile<String>(
            activeColor: const Color(0xff60C03D),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            "Descartáveis - ${widget.pdv}",
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
                      activeColor: const Color(0xff60C03D),
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

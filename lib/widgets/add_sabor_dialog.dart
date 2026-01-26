import 'package:flutter/material.dart';

class AddSaborDialog extends StatefulWidget {
  final List<String> categorias;
  final List<String> opcoes;
  final Function(String categoria, String sabor, String opcao, int quantidade) onSaborAdded;

  AddSaborDialog({
    required this.categorias,
    required this.opcoes,
    required this.onSaborAdded,
  });

  @override
  _AddSaborDialogState createState() => _AddSaborDialogState();
}

class _AddSaborDialogState extends State<AddSaborDialog> {
  String? categoriaSelecionada;
  String? saborSelecionado;
  String? opcaoSelecionada;
  int quantidadeSelecionada = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Sabor'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: categoriaSelecionada,
            hint: Text(categoriaSelecionada ?? 'Selecione a Categoria'),
            isExpanded: true,
            items: widget.categorias.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                categoriaSelecionada = newValue;
              });
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Sabor'),
            onChanged: (value) {
              saborSelecionado = value;
            },
          ),
          DropdownButton<String>(
            value: opcaoSelecionada,
            hint: Text(opcaoSelecionada ?? 'Selecione a Opção'),
            isExpanded: true,
            items: widget.opcoes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                opcaoSelecionada = newValue;
              });
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Quantidade'),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              quantidadeSelecionada = int.tryParse(value) ?? 0;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (categoriaSelecionada != null &&
                saborSelecionado != null &&
                opcaoSelecionada != null) {
              widget.onSaborAdded(
                categoriaSelecionada!,
                saborSelecionado!,
                opcaoSelecionada!,
                quantidadeSelecionada,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}

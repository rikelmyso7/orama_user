import 'package:flutter/material.dart';
import 'package:orama_user/stores/user_sabor_store.dart';
import 'package:provider/provider.dart';

class SaborTile extends StatefulWidget {
  final String sabor;
  final String categoria;

  SaborTile({required this.sabor, required this.categoria});

  @override
  _SaborTileState createState() => _SaborTileState();
}

class _SaborTileState extends State<SaborTile> {
  final List<String> opcoes = ['0', '1/4', '2/4', '3/4', '4/4'];
  late Map<String, int> quantidadePorOpcao;
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    final tabViewState = Provider.of<UserSaborStore>(context, listen: false);
    quantidadePorOpcao = tabViewState.saboresSelecionados[widget.categoria]?[widget.sabor] ?? {
      '0': 0,
      '1/4': 0,
      '2/4': 0,
      '3/4': 0,
      '4/4': 0,
    };
    isExpanded = tabViewState.expansionState[widget.categoria]?[widget.sabor] ?? false;
  }

  void _incrementar(String opcao) {
    setState(() {
      quantidadePorOpcao[opcao] = (quantidadePorOpcao[opcao]! + 1);
    });
    Provider.of<UserSaborStore>(context, listen: false).updateSaborTabView(widget.categoria, widget.sabor, quantidadePorOpcao);
  }

  void _decrementar(String opcao) {
    setState(() {
      if (quantidadePorOpcao[opcao]! > 0) {
        quantidadePorOpcao[opcao] = (quantidadePorOpcao[opcao]! - 1);
      }
    });
    Provider.of<UserSaborStore>(context, listen: false).updateSaborTabView(widget.categoria, widget.sabor, quantidadePorOpcao);
  }

  @override
  Widget build(BuildContext context) {
    final tabViewState = Provider.of<UserSaborStore>(context);

    return ExpansionTile(
      title: Text(widget.sabor),
      initiallyExpanded: isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          isExpanded = expanded;
        });
        tabViewState.setExpansionState(widget.categoria, widget.sabor, expanded);
      },
      children: opcoes.map((opcao) {
        return ListTile(
          title: Text(opcao),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => _decrementar(opcao),
              ),
              Text(quantidadePorOpcao[opcao].toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _incrementar(opcao),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

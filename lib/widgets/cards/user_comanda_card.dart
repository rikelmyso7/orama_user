import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/comanda_utils.dart';

class UserComandaCard extends StatelessWidget {
  final Comanda2 comanda;

  UserComandaCard({
    required this.comanda,
    Key? key,
  }) : super(key: key ?? ValueKey(comanda.id));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Atendente - ${comanda.name}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            _buildHeader(context),
            _buildDateRow(),
            const SizedBox(height: 8.0),
            ..._buildSaborList(),
          ],
        ),
      ),
    );
  }

  void _deleteComanda(BuildContext context) {
    ComandaUtils.deleteComanda(context, comanda);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${comanda.pdv}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteComanda(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(DateFormat('dd/MM/yyyy').format(comanda.data)),
    );
  }

  List<Widget> _buildSaborList() {
    print("Comanda sabores: ${comanda.sabores}");

    if (comanda.sabores.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Text("Nenhum sabor selecionado."),
        ),
      ];
    }

    return comanda.sabores.entries.expand((categoria) {
      return categoria.value.entries.map((saborEntry) {
        print(
            "Categoria: ${categoria.key}, Sabor: ${saborEntry.key}, Quantidades: ${saborEntry.value}");
        final opcoesValidas = saborEntry.value.entries
            .where((quantidadeEntry) => quantidadeEntry.value > 0)
            .toList();

        if (opcoesValidas.isEmpty) {
          return Container();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saborEntry.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...opcoesValidas.map((quantidadeEntry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                      "- ${quantidadeEntry.value} Cuba ${quantidadeEntry.key}"),
                );
              }).toList(),
            ],
          ),
        );
      }).toList();
    }).toList();
  }
}

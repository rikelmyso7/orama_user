import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/comanda_utils.dart';

class AdminRelatoriosCard extends StatelessWidget {
  final Comanda2 comanda;
  final box = GetStorage();

  AdminRelatoriosCard({
    required this.comanda,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(comanda.data),
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () => _copyComanda(comanda),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              ..._buildSaborList(comanda.sabores),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteComanda(BuildContext context) {
    ComandaUtils.deleteComanda(context, comanda);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            comanda.pdv,
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

  List<Widget> _buildSaborList(
      Map<String, Map<String, Map<String, int>>> sabores) {
    if (sabores.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text("Nenhum sabor selecionado."),
        ),
      ];
    }

    return sabores.entries.expand((categoria) {
      return categoria.value.entries.map((saborEntry) {
        final opcoesValidas = saborEntry.value.entries
            .where((quantidadeEntry) => quantidadeEntry.value > 0)
            .toList();

        if (opcoesValidas.isEmpty) {
          return Container();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saborEntry.key,
                style: TextStyle(fontWeight: FontWeight.bold),
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

  void _copyComanda(Comanda2 comanda) {
    // Armazena a comanda no GetStorage
    box.write('copiedComanda', comanda.toJson());
  }
}

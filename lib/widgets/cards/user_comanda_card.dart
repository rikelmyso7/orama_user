import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/pages/user/user_sabores_edit_page.dart';
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
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Atendente - ${comanda.name}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            _buildHeader(context),
            _buildDateRow(context),
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

  void _editComanda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSaboresEditPage(comanda: comanda),
      ),
    );
  }

  void _changeDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: comanda.data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != comanda.data) {
      comanda.data = pickedDate;
      // Salve a nova data usando o método addOrUpdateCard do UserComandaStore
      final store = UserComandaStore();
      store.addOrUpdateCard(comanda);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${comanda.pdv}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editComanda(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteComanda(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextButton(
          onPressed: () => _changeDate(context),
          child: Text(
            DateFormat('dd/MM/yyyy').format(comanda.data),
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          )),
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

        final isMassa = categoria.key == 'Massas';
        final isManteiga = saborEntry.key == 'Manteiga';
        final unidade = isManteiga ? 'Pote' : (isMassa ? 'Tubos' : 'Cubas');
        final saborNome = isManteiga
            ? "Manteiga"
            : (isMassa ? "Massa de ${saborEntry.key}" : saborEntry.key);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saborNome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...opcoesValidas.map((quantidadeEntry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    isManteiga
                        ? "- ${quantidadeEntry.key} $unidade"
                        : isMassa
                            ? "- ${quantidadeEntry.key} $unidade"
                            : "- ${quantidadeEntry.value} $unidade ${quantidadeEntry.key}",
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList();
    }).toList();
  }
}

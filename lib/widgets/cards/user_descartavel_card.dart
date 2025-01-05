import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:orama_user/pages/user/user_descartaveis_edit.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/comanda_utils.dart';

class UserDescartavelCard extends StatelessWidget {
  final ComandaDescartaveis comanda;

  const UserDescartavelCard({Key? key, required this.comanda})
      : super(key: key);

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
            _buildDescartaveisList(),
          ],
        ),
      ),
    );
  }

  void _deleteComanda(BuildContext context) {
    ComandaUtils.deleteComandaDescartaveis(context, comanda);
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
      final store = DescartaveisStore();
      store.addOrUpdateDescartavel(comanda);
    }
  }

  void _editComanda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDescartaveisEdit(comanda: comanda),
      ),
    );
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

  Widget _buildDescartaveisList() {
    // Verifica se o novo formato (itens) está presente
    final bool hasNewFormat = comanda.itens.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: hasNewFormat
            ? _buildNewFormatList() // Novo formato com nome e quantidade
            : _buildOldFormatList(), // Antigo formato com apenas quantidades
      ),
    );
  }

  List<Widget> _buildNewFormatList() {
    return comanda.itens.map((item) {
      final itemName = item['Item'] ?? 'Item';
      final quantity = item['Quantidade'] ?? '';
      final observationIndex = comanda.itens.indexOf(item);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text('- Quantidade: $quantity'),
            ),
            if (observationIndex < comanda.observacoes.length)
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                    '- Observação: ${comanda.observacoes[observationIndex]}'),
              ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildOldFormatList() {
    return List.generate(descartaveis.length, (index) {
      final quantity = index < comanda.observacoes.length
          ? comanda.observacoes[index]
          : ''; // Usa "N/A" se a quantidade não for encontrada

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              index < descartaveis.length
                  ? descartaveis[index].name
                  : 'Item $index',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text('- Quantidade: $quantity'),
            ),
            if (index < comanda.observacoes.length)
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text('- Observação: ${comanda.observacoes[index]}'),
              ),
          ],
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:orama_user/pages/user/user_descartaveis_edit.dart';
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
            _buildDescartaveisList(),
          ],
        ),
      ),
    );
  }

  void _deleteComanda(BuildContext context) {
    ComandaUtils.deleteComandaDescartaveis(context, comanda);
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

  Widget _buildDateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(DateFormat('dd/MM/yyyy').format(comanda.data)),
    );
  }

  Widget _buildDescartaveisList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(comanda.quantidades.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  descartaveis[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('- Quantidade ${comanda.quantidades[index]}'),
                      Text('- Observação: ${comanda.observacoes[index]}'),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}

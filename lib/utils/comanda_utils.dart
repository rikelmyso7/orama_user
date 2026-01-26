// utils/comanda_utils.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/models/comanda_model.dart';
import 'package:orama_user/models/descartaveis_model.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:provider/provider.dart';

class ComandaUtils {
  static Future<void> deleteComanda(
      BuildContext context, Comanda2 comanda) async {
    try {
      final userId = GetStorage().read('userId');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('comandas')
          .doc(comanda.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comanda deletada com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Erro ao deletar a comanda: $e');
    }
  }

  static Future<void> deleteComandaDescartaveis(
      BuildContext context, Descartaveis comanda) async {
    try {
      context.read<DescartaveisStore>().deleteComanda(comanda.id);
      print(comanda.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comanda deletada com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Erro ao deletar a comanda: $e');
    }
  }
}

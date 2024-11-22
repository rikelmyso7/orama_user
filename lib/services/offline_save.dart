// services/offline_sync_service.dart
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfflineSyncService {
  final GetStorage _storage = GetStorage();

  Future<void> salvarRelatorioOffline(Map<String, dynamic> relatorio) async {
    List<dynamic> relatoriosPendentes = _storage.read('relatorios') ?? [];
    relatoriosPendentes.add(relatorio);
    _storage.write('relatorios', relatoriosPendentes);
  }

  Future<void> enviarDadosPendentes() async {
    List<dynamic> relatoriosPendentes = _storage.read('relatorios') ?? [];
    if (relatoriosPendentes.isNotEmpty) {
      for (var relatorio in relatoriosPendentes) {
        try {
          await FirebaseFirestore.instance.collection('relatorios').add(relatorio);
          relatoriosPendentes.remove(relatorio);
        } catch (e) {
          print("Erro ao enviar relatório: $e");
          break;
        }
      }
      _storage.write('relatorios', relatoriosPendentes);
    }
  }
}

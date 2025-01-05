import 'package:mobx/mobx.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:uuid/uuid.dart';

part 'descartaveis_store.g.dart';

class DescartaveisStore = _DescartaveisStoreBase with _$DescartaveisStore;

abstract class _DescartaveisStoreBase with Store {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  @observable
  ObservableList<ComandaDescartaveis> descartaveis =
      ObservableList<ComandaDescartaveis>();

  @action
  Future<void> deleteComandaDescartaveis(ComandaDescartaveis comanda) async {
    final userId = _storage.read('userId');
    if (userId == null) {
      throw Exception('Usuário não está autenticado');
    }

    try {
      // Remove do Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('descartaveis')
          .doc(comanda.id)
          .delete();

      // Remove do estado local
      descartaveis.remove(comanda);
      print('Comanda deletada com sucesso do Firestore.');
    } catch (e) {
      print('Erro ao deletar comanda do Firestore: $e');
      throw e;
    }
  }

  @action
  Future<void> salvarPendenciaOfflineDescartaveis(
      ComandaDescartaveis comanda) async {
    List<dynamic> pendentes =
        _storage.read('comandasPendentesDescartaveis') ?? [];
    pendentes.add(comanda.toJson());
    await _storage.write('comandasPendentesDescartaveis', pendentes);
    print('Comanda salva como pendente offline.');
  }

  @action
  Future<void> addOrUpdateDescartavel(ComandaDescartaveis descartavel) async {
    try {
      final userId = _storage.read('userId');
      if (userId == null) {
        throw Exception('Usuário não está autenticado');
      }

      final descartavelId =
          descartavel.id.isEmpty ? Uuid().v4() : descartavel.id;
      descartavel.id = descartavelId;
      descartavel.userId = userId;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('descartaveis')
          .doc(descartavelId)
          .set(descartavel.toJson());

      final existingIndex =
          descartaveis.indexWhere((d) => d.id == descartavelId);
      if (existingIndex != -1) {
        descartaveis[existingIndex] = descartavel;
      } else {
        descartaveis.add(descartavel);
      }

      print('Descartável enviado para o Firestore com sucesso.');
    } catch (e) {
      print('Erro ao enviar descartável para o Firestore: $e');
      await salvarPendenciaOfflineDescartaveis(descartavel);
    }
  }
}

class ComandaDescartaveis {
  String name;
  String id;
  String pdv;
  String userId;
  List<Map<String, String>> itens; // Apenas no formato novo
  List<String> observacoes;
  DateTime data;

  ComandaDescartaveis({
    required this.name,
    required this.id,
    required this.pdv,
    required this.userId,
    required this.itens,
    required this.observacoes,
    required this.data,
  });

  String get currentUserId => GetStorage().read('userId') ?? '';

  factory ComandaDescartaveis.fromJson(Map<String, dynamic> json) {
    // Verifica se o campo `itens` existe
    final itens = (json['itens'] as List<dynamic>?)
            ?.map((item) => Map<String, String>.from(item as Map))
            .toList() ??
        [];

    // Caso o campo `itens` não exista, tenta carregar o formato antigo
    if (itens.isEmpty && json.containsKey('quantidades')) {
      final quantidades = (json['quantidades'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      // Cria itens a partir da lista `descartaveis` (caso disponível)
      final itensAntigos = List.generate(quantidades.length, (index) {
        final itemName = descartaveis.length > index
            ? descartaveis[index].name
            : 'Item $index';
        return {'Item': itemName, 'Quantidade': quantidades[index]};
      });

      return ComandaDescartaveis(
        name: json['name'] ?? '',
        id: json['id'] ?? '',
        pdv: json['pdv'] ?? '',
        userId: json['userId'] ?? '',
        itens: itensAntigos, // Transforma o antigo em novo
        observacoes: (json['observacoes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        data: DateTime.tryParse(json['data'] ?? '') ?? DateTime.now(),
      );
    }

    // Se `itens` existe, usa o formato novo
    return ComandaDescartaveis(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      pdv: json['pdv'] ?? '',
      userId: json['userId'] ?? '',
      itens: itens,
      observacoes: (json['observacoes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      data: DateTime.tryParse(json['data'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    // Salva sempre no formato novo
    return {
      'name': name,
      'id': id,
      'pdv': pdv,
      'userId': userId,
      'itens': itens, // Sempre salva no novo formato
      'observacoes': observacoes,
      'data': data.toIso8601String(),
    };
  }

  /// Método copyWith para criar uma nova instância com campos sobrescritos
  ComandaDescartaveis copyWith({
    String? name,
    String? id,
    String? pdv,
    String? userId,
    List<Map<String, String>>? itens,
    List<String>? observacoes,
    DateTime? data,
  }) {
    return ComandaDescartaveis(
      name: name ?? this.name,
      id: id ?? this.id,
      pdv: pdv ?? this.pdv,
      userId: userId ?? this.userId,
      itens: itens ?? this.itens,
      observacoes: observacoes ?? this.observacoes,
      data: data ?? this.data,
    );
  }


  Future<void> uploadToFirestore() async {
    try {
      final userIdToUse = userId.isNotEmpty ? userId : currentUserId;
      if (userIdToUse.isEmpty) {
        throw Exception('ID do usuário não encontrado.');
      }

      if (id.isEmpty) {
        id = FirebaseFirestore.instance.collection('descartaveis').doc().id;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userIdToUse)
          .collection('descartaveis')
          .doc(id)
          .set(toJson());

      print('Comanda de descartáveis enviada para o Firestore com sucesso.');
    } catch (e) {
      print('Erro ao enviar comanda de descartáveis para o Firestore: $e');
      rethrow;
    }
  }
}

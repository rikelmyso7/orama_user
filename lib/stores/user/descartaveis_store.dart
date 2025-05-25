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
  final String name = json['name']?.toString() ?? 'Nome não informado';
  final String id = json['id']?.toString() ?? '';
  final String pdv = json['pdv']?.toString() ?? 'PDV não informado';
  final String userId = json['userId']?.toString() ?? '';
  final dynamic rawItens = json['itens'];
  final dynamic rawObs = json['observacoes'];

  // Converte lista de itens
  final List<Map<String, String>> itens = (rawItens is List)
      ? rawItens
          .whereType<Map>()
          .map((item) => {
                'Item': item['Item']?.toString() ?? '',
                'Quantidade': item['Quantidade']?.toString() ?? '',
                'Observacao': item['Observacao']?.toString() ?? '',
              })
          .toList()
      : [];

  // Se vier no formato antigo com 'quantidades', transforma
  if (itens.isEmpty && json.containsKey('quantidades')) {
    final quantidades = (json['quantidades'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    final itensAntigos = List.generate(quantidades.length, (index) {
      final itemName = descartaveis.length > index
          ? descartaveis[index].name
          : 'Item $index';
      return {
        'Item': itemName,
        'Quantidade': quantidades[index],
        'Observacao': '',
      };
    });

    return ComandaDescartaveis(
      name: name,
      id: id,
      pdv: pdv,
      userId: userId,
      itens: itensAntigos,
      observacoes: [],
      data: DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // Observações (separadas, formato novo)
  final List<String> observacoes = (rawObs is List)
      ? rawObs.map((e) => e.toString()).toList()
      : [];

  // Data
  DateTime data;
  if (json['data'] is Timestamp) {
    data = (json['data'] as Timestamp).toDate();
  } else if (json['data'] is String) {
    data = DateTime.tryParse(json['data']) ?? DateTime.now();
  } else {
    data = DateTime.now();
  }

  return ComandaDescartaveis(
    name: name,
    id: id,
    pdv: pdv,
    userId: userId,
    itens: itens,
    observacoes: observacoes,
    data: data,
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

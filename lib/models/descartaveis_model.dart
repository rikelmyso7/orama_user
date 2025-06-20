import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';

class Descartaveis {
  String name;
  String? periodo;
  String id;
  String pdv;
  String userId;
  List<Map<String, String>> itens; // Apenas no formato novo
  List<String> observacoes;
  DateTime data;
  DescartaveisStatus status;

  Descartaveis({
    required this.name,
    required this.id,
    required this.pdv,
    required this.userId,
    required this.itens,
    required this.observacoes,
    required this.data,
    required this.periodo,
    this.status = DescartaveisStatus.pendente,
  });

  String get currentUserId => GetStorage().read('userId') ?? '';

  factory Descartaveis.fromJson(Map<String, dynamic> json) {
    final String name = json['name']?.toString() ?? 'Nome não informado';
    final String periodo = json['periodo'].toString() ?? '';
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

      return Descartaveis(
        name: name,
        id: id,
        pdv: pdv,
        userId: userId,
        itens: itensAntigos,
        observacoes: [],
        data:
            DateTime.tryParse(json['data']?.toString() ?? '') ?? DateTime.now(),
        periodo: periodo,
        status: DescartaveisStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pendente'),
        orElse: () => DescartaveisStatus.pendente,
      ),
      );
    }

    // Observações (separadas, formato novo)
    final List<String> observacoes =
        (rawObs is List) ? rawObs.map((e) => e.toString()).toList() : [];

    // Data
    DateTime data;
    if (json['data'] is Timestamp) {
      data = (json['data'] as Timestamp).toDate();
    } else if (json['data'] is String) {
      data = DateTime.tryParse(json['data']) ?? DateTime.now();
    } else {
      data = DateTime.now();
    }

    return Descartaveis(
      name: name,
      id: id,
      pdv: pdv,
      userId: userId,
      itens: itens,
      observacoes: observacoes,
      data: data, 
      periodo: periodo,
    );
  }

  Map<String, dynamic> toJson() {
    // Salva sempre no formato novo
    return {
      'name': name,
      'periodo': periodo,
      'id': id,
      'pdv': pdv,
      'userId': userId,
      'itens': itens, // Sempre salva no novo formato
      'observacoes': observacoes,
      'data': data.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  /// Método copyWith para criar uma nova instância com campos sobrescritos
  Descartaveis copyWith({
    String? name,
    String? periodo,
    String? id,
    String? pdv,
    String? userId,
    List<Map<String, String>>? itens,
    List<String>? observacoes,
    DateTime? data,
    DescartaveisStatus? status,
  }) {
    return Descartaveis(
      name: name ?? this.name,
      id: id ?? this.id,
      pdv: pdv ?? this.pdv,
      userId: userId ?? this.userId,
      itens: itens ?? this.itens,
      observacoes: observacoes ?? this.observacoes,
      data: data ?? this.data, periodo: periodo ?? this.periodo,
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

  factory Descartaveis.fromDoc(DocumentSnapshot doc) =>
      Descartaveis.fromJson(doc.data() as Map<String, dynamic>);
}

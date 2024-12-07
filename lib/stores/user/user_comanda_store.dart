import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

part 'user_comanda_store.g.dart';

//Comanda2.dart
class Comanda2 {
  String name;
  String id;
  String pdv;
  String userId;
  Map<String, Map<String, Map<String, int>>> sabores;
  DateTime data;
  String? caixaInicial;
  String? caixaFinal;
  String? pixInicial;
  String? pixFinal;

  Comanda2({
    required this.name,
    required this.id,
    required this.pdv,
    required this.userId,
    required this.sabores,
    required this.data,
    this.caixaInicial,
    this.caixaFinal,
    this.pixInicial,
    this.pixFinal,
  });

  factory Comanda2.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, Map<String, int>>> saboresConvertidos = {};
    if (json['sabores'] != null) {
      Map<String, dynamic> saboresJson = json['sabores'];

      saboresJson.forEach((categoria, saboresMap) {
        saboresConvertidos[categoria] = {};
        (saboresMap as Map<String, dynamic>).forEach((sabor, opcoesMap) {
          saboresConvertidos[categoria]![sabor] =
              Map<String, int>.from(opcoesMap);
        });
      });
    }

    return Comanda2(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      pdv: json['pdv'] ?? '',
      userId: json['userId'] ?? '',
      sabores: saboresConvertidos,
      data: DateTime.parse(json['data'] ?? DateTime.now().toIso8601String()),
      caixaInicial: json['caixaInicial'],
      caixaFinal: json['caixaFinal'],
      pixInicial: json['pixInicial'],
      pixFinal: json['pixFinal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'pdv': pdv,
      'userId': userId,
      'sabores': sabores,
      'data': data.toIso8601String(),
      'caixaInicial': caixaInicial,
      'caixaFinal': caixaFinal,
      'pixInicial': pixInicial,
      'pixFinal': pixFinal,
    };
  }
}

//Descartavel.dart
class ComandaDescartaveis {
  String name;
  String id;
  String pdv;
  String userId;
  List<String> quantidades;
  List<String> observacoes;
  DateTime data;

  ComandaDescartaveis({
    required this.name,
    required this.id,
    required this.pdv,
    required this.userId,
    required this.quantidades,
    required this.observacoes,
    required this.data,
  });

  factory ComandaDescartaveis.fromJson(Map<String, dynamic> json) {
    return ComandaDescartaveis(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      pdv: json['pdv'] ?? '',
      userId: json['userId'] ?? '',
      quantidades: List<String>.from(json['quantidades'] ?? []),
      observacoes: List<String>.from(json['observacoes'] ?? []),
      data: DateTime.parse(json['data'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'pdv': pdv,
      'userId': userId,
      'quantidades': quantidades,
      'observacoes': observacoes,
      'data': data.toIso8601String(),
    };
  }

  Future<void> uploadToFirestore() async {
    try {
      final userId = GetStorage()
          .read('userId'); // Troque para a forma que você obtém o ID do usuário
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('descartaveis')
          .doc(id)
          .set(toJson());

      print('Comanda de descartáveis enviada para o Firestore com sucesso.');
    } catch (e) {
      print('Erro ao enviar comanda de descartáveis para o Firestore: $e');
      throw e;
    }
  }
}

//Sabor2.dart
@JsonSerializable()
class Sabor2 {
  String nome;
  String categoria;
  int quantidade;

  Sabor2(
      {required this.nome, required this.categoria, required this.quantidade});

  factory Sabor2.fromJson(Map<String, dynamic> json) => _$Sabor2FromJson(json);
  Map<String, dynamic> toJson() => _$Sabor2ToJson(this);
}

//UserSaborStore.dart
class UserSaborStore = _UserSaborStore with _$UserSaborStore;

abstract class _UserSaborStore with Store {
  @observable
  ObservableList<Sabor2> sabores = ObservableList<Sabor2>();

  @action
  void addSabor(Sabor2 sabor) {
    sabores.add(sabor);
  }

  @action
  void removeSabor(Sabor2 sabor) {
    sabores.remove(sabor);
  }

  @action
  void updateSabor(int index, Sabor2 sabor) {
    sabores[index] = sabor;
  }

  // TabViewState
  @observable
  int currentIndex = 0;

  @observable
  ObservableMap<String, ObservableMap<String, Map<String, int>>>
      saboresSelecionados = ObservableMap();

  @observable
  ObservableMap<String, ObservableMap<String, bool>> expansionState =
      ObservableMap();

  @action
  void setCurrentIndex(int index) {
    currentIndex = index;
  }

  @action
  void updateSaborTabView(
      String categoria, String sabor, Map<String, int> quantidade) {
    if (!saboresSelecionados.containsKey(categoria)) {
      saboresSelecionados[categoria] = ObservableMap();
    }
    saboresSelecionados[categoria]![sabor] = quantidade;
  }

  @action
  void setExpansionState(String categoria, String sabor, bool isExpanded) {
    if (!expansionState.containsKey(categoria)) {
      expansionState[categoria] = ObservableMap();
    }
    expansionState[categoria]![sabor] = isExpanded;
  }

  @action
  void resetExpansionState() {
    expansionState.clear();
  }

  @action
  void resetSaborTabView() {
    saboresSelecionados.clear();
  }
}

//UserComandaStore.dart
class UserComandaStore = _UserComandaStoreBase with _$UserComandaStore;

abstract class _UserComandaStoreBase with Store {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  _UserComandaStoreBase() {
    _loadComandas();
    sincronizarPendencias();
  }

  @observable
  ObservableList<Comanda2> comandas = ObservableList<Comanda2>();

  @observable
  ObservableList<ComandaDescartaveis> descartaveisComanda =
      ObservableList<ComandaDescartaveis>();

  @observable
  DateTime selectedDate = DateTime.now();

  @action
  Future<void> salvarPendenciaOffline(Comanda2 comanda) async {
    List<dynamic> pendentes = _storage.read('comandasPendentes') ?? [];
    pendentes.add(comanda.toJson());
    await _storage.write('comandasPendentes', pendentes);
    print('Comanda salva como pendente offline.');
  }

  @action
  Future<void> sincronizarPendencias() async {
    List<dynamic> pendentes = _storage.read('comandasPendentes') ?? [];
    if (pendentes.isEmpty) return;

    for (var pendenteJson in List.from(pendentes)) {
      try {
        final comanda = Comanda2.fromJson(pendenteJson);
        await addOrUpdateCard(comanda);
        pendentes.remove(pendenteJson);
      } catch (e) {
        print('Erro ao sincronizar comanda pendente: $e');
      }
    }

    await _storage.write('comandasPendentes', pendentes);
    print('Sincronização de pendências concluída.');
  }

  @action
  void removeComandaStorage(int index) {
    comandas.removeAt(index);
    _saveComandas();
  }

  Future<void> _loadComandasStorage() async {
    final data = await _storage.read('copiedComanda') as List<dynamic>?;

    if (data != null) {
      comandas = ObservableList<Comanda2>.of(
        data.map((json) => Comanda2.fromJson(json as Map<String, dynamic>)),
      );
    }
  }

  @action
  void addOrUpdateCardStorage(Comanda2 comanda) {
    final index = comandas.indexWhere((c) => c.id == comanda.id);
    if (index == -1) {
      comandas.add(comanda);
    } else {
      comandas[index] = comanda;
    }
    _saveComandas();
  }

  Future<void> _saveComandas() async {
    await _storage.write(
        'copiedComanda', comandas.map((c) => c.toJson()).toList());
  }

  //Comandas2 Firebase
  @action
  Future<void> addOrUpdateCard(Comanda2 comanda) async {
    try {
      final userId = GetStorage().read('userId');
      if (userId == null) {
        throw Exception('Usuário não está autenticado');
      }

      final comandaId = comanda.id.isEmpty ? Uuid().v4() : comanda.id;
      comanda.id = comandaId;
      comanda.userId = userId;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('comandas')
          .doc(comandaId)
          .set(comanda.toJson());

      final existingIndex = comandas.indexWhere((c) => c.id == comandaId);
      if (existingIndex != -1) {
        comandas[existingIndex] = comanda;
      } else {
        comandas.add(comanda);
      }
      print('Comanda enviada para o Firestore com sucesso.');
    } catch (e) {
      print('Erro ao enviar comanda para o Firestore. Salvando offline: $e');
      await salvarPendenciaOffline(comanda);
    }
  }

  @action
  Future<void> removeComanda(int index) async {
    final userId = GetStorage().read('userId');
    if (userId == null) {
      throw Exception('Usuário não está autenticado');
    }

    if (index < 0 || index >= comandas.length) {
      throw Exception('Índice de comanda inválido');
    }

    final comanda = comandas[index];
    comandas.removeAt(index);

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userRole = userDoc.data()?['role'];

    if (userRole == 'admin' || userDoc.id == comanda.userId) {
      try {
        await _firestore
            .collection('users')
            .doc(comanda.userId)
            .collection('comandas')
            .doc(comanda.id)
            .delete();
        print('Comanda deletada com sucesso do Firestore.');
      } catch (e) {
        print('Erro ao deletar comanda do Firestore: $e');
      }
    } else {
      print('Usuário não autorizado a deletar esta comanda.');
    }
  }

  @action
  Future<void> deleteComandaDescartaveis(ComandaDescartaveis comanda) async {
    final userId = GetStorage().read('userId');
    if (userId == null) {
      throw Exception('Usuário não está autenticado');
    }

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('descartaveis')
          .doc(comanda.id)
          .delete();

      comandas.remove(comanda);
      print('Comanda deletada com sucesso do Firestore.');
    } catch (e) {
      print('Erro ao deletar comanda do Firestore: $e');
      throw e;
    }
  }

  @action
  void setSelectedDate(DateTime date) {
    selectedDate = date;
  }

  @action
  List<Comanda2> getComandasForSelectedDay(DateTime date) {
    return comandas
        .where((comanda) =>
            comanda.data.year == date.year &&
            comanda.data.month == date.month &&
            comanda.data.day == date.day)
        .toList();
  }

  Future<void> _loadComandas() async {
    final userId = GetStorage().read('userId');
    if (userId == null) {
      throw Exception('Usuário não está autenticado');
    }

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userRole = userDoc.data()?['role'];

    QuerySnapshot querySnapshot;
    if (userRole == 'admin') {
      // Carregar todas as comandas
      querySnapshot = await _firestore.collectionGroup('comandas').get();
    } else {
      // Carregar apenas as comandas do usuário
      querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('comandas')
          .get();
    }

    comandas = ObservableList<Comanda2>.of(
      querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final comanda = Comanda2.fromJson(data);
        print('Comanda carregada: ${comanda.id}');
        return comanda;
      }),
    );
  }

  @action
  Future<void> loadAllComandas() async {
    final querySnapshot = await _firestore.collectionGroup('comandas').get();

    comandas = ObservableList<Comanda2>.of(
      querySnapshot.docs.map((doc) {
        final comanda = Comanda2.fromJson(doc.data());
        print('Comanda carregada: ${comanda.id}');
        return comanda;
      }),
    );
  }
}

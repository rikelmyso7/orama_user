import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

part 'comanda_store.g.dart';

//Comanda.dart
class Comanda {
  String name;
  String userId;
  String id;
  String pdv;
  Map<String, Map<String, Map<String, int>>> sabores;
  DateTime data;

  Comanda({
    required this.name,
    required this.id,
    required this.pdv,
    required this.userId,
    required this.sabores,
    required this.data,
  });

  factory Comanda.fromJson(Map<String, dynamic> json) {
    // Convert nested sabores from JSON to Dart map structure
    Map<String, Map<String, Map<String, int>>> saboresConvertidos = {};
    Map<String, dynamic> saboresJson = json['sabores'];

    saboresJson.forEach((categoria, saboresMap) {
      saboresConvertidos[categoria] = {};
      (saboresMap as Map<String, dynamic>).forEach((sabor, opcoesMap) {
        saboresConvertidos[categoria]![sabor] =
            Map<String, int>.from(opcoesMap);
      });
    });

    return Comanda(
      id: json['id'],
      pdv: json['pdv'],
      sabores: saboresConvertidos,
      data: DateTime.parse(json['data']),
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Convert the Comanda object to JSON-compatible map
    return {
      'id': id,
      'pdv': pdv,
      'sabores': sabores,
      'data': data.toIso8601String(),
      'name': name,
      'userId': userId,
    };
  }
}

//SaborStore.dart
class SaborStore = _SaborStore with _$SaborStore;

abstract class _SaborStore with Store {
  @observable
  ObservableList<Sabor> sabores = ObservableList<Sabor>();

  @action
  void addSabor(Sabor sabor) {
    sabores.add(sabor);
  }

  @action
  void removeSabor(Sabor sabor) {
    sabores.remove(sabor);
  }

  @action
  void updateSabor(int index, Sabor sabor) {
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

//Sabor.dart
@JsonSerializable()
class Sabor {
  String nome;
  String categoria;
  int quantidade;

  Sabor(
      {required this.nome, required this.categoria, required this.quantidade});

  factory Sabor.fromJson(Map<String, dynamic> json) => _$SaborFromJson(json);
  Map<String, dynamic> toJson() => _$SaborToJson(this);
}

class ComandaStore = _ComandaStoreBase with _$ComandaStore;

abstract class _ComandaStoreBase with Store {
  final GetStorage _storage = GetStorage();

  _ComandaStoreBase() {
    _loadComandas();
  }

  @observable
  ObservableList<Comanda> comandas = ObservableList<Comanda>();

  @observable
  DateTime selectedDate = DateTime.now();

  @action
  void addOrUpdateCard(Comanda comanda) {
    final index = comandas.indexWhere((c) => c.id == comanda.id);
    if (index == -1) {
      comandas.add(comanda);
    } else {
      comandas[index] = comanda;
    }
    _saveComandas();
  }

  @action
  void removeComanda(int index) {
    comandas.removeAt(index);
    _saveComandas();
  }

  @action
  void setSelectedDate(DateTime date) {
    selectedDate = date;
  }

  @action
  List<Comanda> getComandasForSelectedDay(DateTime date) {
    return comandas
        .where((comanda) =>
            comanda.data.year == date.year &&
            comanda.data.month == date.month &&
            comanda.data.day == date.day)
        .toList();
  }

  Future<void> _loadComandas() async {
    final data = await _storage.read('comandas') as List<dynamic>?;

    if (data != null) {
      comandas = ObservableList<Comanda>.of(
        data.map((json) => Comanda.fromJson(json as Map<String, dynamic>)),
      );
    }
  }

  Future<void> _saveComandas() async {
    await _storage.write('comandas', comandas.map((c) => c.toJson()).toList());
  }
}

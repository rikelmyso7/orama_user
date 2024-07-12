// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comanda_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sabor _$SaborFromJson(Map<String, dynamic> json) => Sabor(
      nome: json['nome'] as String,
      categoria: json['categoria'] as String,
      quantidade: (json['quantidade'] as num).toInt(),
    );

Map<String, dynamic> _$SaborToJson(Sabor instance) => <String, dynamic>{
      'nome': instance.nome,
      'categoria': instance.categoria,
      'quantidade': instance.quantidade,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SaborStore on _SaborStore, Store {
  late final _$saboresAtom =
      Atom(name: '_SaborStore.sabores', context: context);

  @override
  ObservableList<Sabor> get sabores {
    _$saboresAtom.reportRead();
    return super.sabores;
  }

  @override
  set sabores(ObservableList<Sabor> value) {
    _$saboresAtom.reportWrite(value, super.sabores, () {
      super.sabores = value;
    });
  }

  late final _$currentIndexAtom =
      Atom(name: '_SaborStore.currentIndex', context: context);

  @override
  int get currentIndex {
    _$currentIndexAtom.reportRead();
    return super.currentIndex;
  }

  @override
  set currentIndex(int value) {
    _$currentIndexAtom.reportWrite(value, super.currentIndex, () {
      super.currentIndex = value;
    });
  }

  late final _$saboresSelecionadosAtom =
      Atom(name: '_SaborStore.saboresSelecionados', context: context);

  @override
  ObservableMap<String, ObservableMap<String, Map<String, int>>>
      get saboresSelecionados {
    _$saboresSelecionadosAtom.reportRead();
    return super.saboresSelecionados;
  }

  @override
  set saboresSelecionados(
      ObservableMap<String, ObservableMap<String, Map<String, int>>> value) {
    _$saboresSelecionadosAtom.reportWrite(value, super.saboresSelecionados, () {
      super.saboresSelecionados = value;
    });
  }

  late final _$expansionStateAtom =
      Atom(name: '_SaborStore.expansionState', context: context);

  @override
  ObservableMap<String, ObservableMap<String, bool>> get expansionState {
    _$expansionStateAtom.reportRead();
    return super.expansionState;
  }

  @override
  set expansionState(ObservableMap<String, ObservableMap<String, bool>> value) {
    _$expansionStateAtom.reportWrite(value, super.expansionState, () {
      super.expansionState = value;
    });
  }

  late final _$_SaborStoreActionController =
      ActionController(name: '_SaborStore', context: context);

  @override
  void addSabor(Sabor sabor) {
    final _$actionInfo =
        _$_SaborStoreActionController.startAction(name: '_SaborStore.addSabor');
    try {
      return super.addSabor(sabor);
    } finally {
      _$_SaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeSabor(Sabor sabor) {
    final _$actionInfo = _$_SaborStoreActionController.startAction(
        name: '_SaborStore.removeSabor');
    try {
      return super.removeSabor(sabor);
    } finally {
      _$_SaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSabor(int index, Sabor sabor) {
    final _$actionInfo = _$_SaborStoreActionController.startAction(
        name: '_SaborStore.updateSabor');
    try {
      return super.updateSabor(index, sabor);
    } finally {
      _$_SaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentIndex(int index) {
    final _$actionInfo = _$_SaborStoreActionController.startAction(
        name: '_SaborStore.setCurrentIndex');
    try {
      return super.setCurrentIndex(index);
    } finally {
      _$_SaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSaborTabView(
      String categoria, String sabor, Map<String, int> quantidade) {
    final _$actionInfo = _$_SaborStoreActionController.startAction(
        name: '_SaborStore.updateSaborTabView');
    try {
      return super.updateSaborTabView(categoria, sabor, quantidade);
    } finally {
      _$_SaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setExpansionState(String categoria, String sabor, bool isExpanded) {
    final _$actionInfo = _$_SaborStoreActionController.startAction(
        name: '_SaborStore.setExpansionState');
    try {
      return super.setExpansionState(categoria, sabor, isExpanded);
    } finally {
      _$_SaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetExpansionState() {
    final _$actionInfo = _$_SaborStoreActionController.startAction(
        name: '_SaborStore.resetExpansionState');
    try {
      return super.resetExpansionState();
    } finally {
      _$_SaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetSaborTabView() {
    final _$actionInfo = _$_SaborStoreActionController.startAction(
        name: '_SaborStore.resetSaborTabView');
    try {
      return super.resetSaborTabView();
    } finally {
      _$_SaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
sabores: ${sabores},
currentIndex: ${currentIndex},
saboresSelecionados: ${saboresSelecionados},
expansionState: ${expansionState}
    ''';
  }
}

mixin _$ComandaStore on _ComandaStoreBase, Store {
  late final _$comandasAtom =
      Atom(name: '_ComandaStoreBase.comandas', context: context);

  @override
  ObservableList<Comanda> get comandas {
    _$comandasAtom.reportRead();
    return super.comandas;
  }

  @override
  set comandas(ObservableList<Comanda> value) {
    _$comandasAtom.reportWrite(value, super.comandas, () {
      super.comandas = value;
    });
  }

  late final _$selectedDateAtom =
      Atom(name: '_ComandaStoreBase.selectedDate', context: context);

  @override
  DateTime get selectedDate {
    _$selectedDateAtom.reportRead();
    return super.selectedDate;
  }

  @override
  set selectedDate(DateTime value) {
    _$selectedDateAtom.reportWrite(value, super.selectedDate, () {
      super.selectedDate = value;
    });
  }

  late final _$_ComandaStoreBaseActionController =
      ActionController(name: '_ComandaStoreBase', context: context);

  @override
  void addOrUpdateCard(Comanda comanda) {
    final _$actionInfo = _$_ComandaStoreBaseActionController.startAction(
        name: '_ComandaStoreBase.addOrUpdateCard');
    try {
      return super.addOrUpdateCard(comanda);
    } finally {
      _$_ComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeComanda(int index) {
    final _$actionInfo = _$_ComandaStoreBaseActionController.startAction(
        name: '_ComandaStoreBase.removeComanda');
    try {
      return super.removeComanda(index);
    } finally {
      _$_ComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedDate(DateTime date) {
    final _$actionInfo = _$_ComandaStoreBaseActionController.startAction(
        name: '_ComandaStoreBase.setSelectedDate');
    try {
      return super.setSelectedDate(date);
    } finally {
      _$_ComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  List<Comanda> getComandasForSelectedDay(DateTime date) {
    final _$actionInfo = _$_ComandaStoreBaseActionController.startAction(
        name: '_ComandaStoreBase.getComandasForSelectedDay');
    try {
      return super.getComandasForSelectedDay(date);
    } finally {
      _$_ComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
comandas: ${comandas},
selectedDate: ${selectedDate}
    ''';
  }
}

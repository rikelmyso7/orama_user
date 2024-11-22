// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_comanda_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sabor2 _$Sabor2FromJson(Map<String, dynamic> json) => Sabor2(
      nome: json['nome'] as String,
      categoria: json['categoria'] as String,
      quantidade: (json['quantidade'] as num).toInt(),
    );

Map<String, dynamic> _$Sabor2ToJson(Sabor2 instance) => <String, dynamic>{
      'nome': instance.nome,
      'categoria': instance.categoria,
      'quantidade': instance.quantidade,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserSaborStore on _UserSaborStore, Store {
  late final _$saboresAtom =
      Atom(name: '_UserSaborStore.sabores', context: context);

  @override
  ObservableList<Sabor2> get sabores {
    _$saboresAtom.reportRead();
    return super.sabores;
  }

  @override
  set sabores(ObservableList<Sabor2> value) {
    _$saboresAtom.reportWrite(value, super.sabores, () {
      super.sabores = value;
    });
  }

  late final _$currentIndexAtom =
      Atom(name: '_UserSaborStore.currentIndex', context: context);

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
      Atom(name: '_UserSaborStore.saboresSelecionados', context: context);

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
      Atom(name: '_UserSaborStore.expansionState', context: context);

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

  late final _$_UserSaborStoreActionController =
      ActionController(name: '_UserSaborStore', context: context);

  @override
  void addSabor(Sabor2 sabor) {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.addSabor');
    try {
      return super.addSabor(sabor);
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeSabor(Sabor2 sabor) {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.removeSabor');
    try {
      return super.removeSabor(sabor);
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSabor(int index, Sabor2 sabor) {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.updateSabor');
    try {
      return super.updateSabor(index, sabor);
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentIndex(int index) {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.setCurrentIndex');
    try {
      return super.setCurrentIndex(index);
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSaborTabView(
      String categoria, String sabor, Map<String, int> quantidade) {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.updateSaborTabView');
    try {
      return super.updateSaborTabView(categoria, sabor, quantidade);
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setExpansionState(String categoria, String sabor, bool isExpanded) {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.setExpansionState');
    try {
      return super.setExpansionState(categoria, sabor, isExpanded);
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetExpansionState() {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.resetExpansionState');
    try {
      return super.resetExpansionState();
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetSaborTabView() {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.resetSaborTabView');
    try {
      return super.resetSaborTabView();
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
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

mixin _$UserComandaStore on _UserComandaStoreBase, Store {
  late final _$comandasAtom =
      Atom(name: '_UserComandaStoreBase.comandas', context: context);

  @override
  ObservableList<Comanda2> get comandas {
    _$comandasAtom.reportRead();
    return super.comandas;
  }

  @override
  set comandas(ObservableList<Comanda2> value) {
    _$comandasAtom.reportWrite(value, super.comandas, () {
      super.comandas = value;
    });
  }

  late final _$descartaveisComandaAtom =
      Atom(name: '_UserComandaStoreBase.descartaveisComanda', context: context);

  @override
  ObservableList<ComandaDescartaveis> get descartaveisComanda {
    _$descartaveisComandaAtom.reportRead();
    return super.descartaveisComanda;
  }

  @override
  set descartaveisComanda(ObservableList<ComandaDescartaveis> value) {
    _$descartaveisComandaAtom.reportWrite(value, super.descartaveisComanda, () {
      super.descartaveisComanda = value;
    });
  }

  late final _$selectedDateAtom =
      Atom(name: '_UserComandaStoreBase.selectedDate', context: context);

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

  late final _$salvarPendenciaOfflineAsyncAction = AsyncAction(
      '_UserComandaStoreBase.salvarPendenciaOffline',
      context: context);

  @override
  Future<void> salvarPendenciaOffline(Comanda2 comanda) {
    return _$salvarPendenciaOfflineAsyncAction
        .run(() => super.salvarPendenciaOffline(comanda));
  }

  late final _$sincronizarPendenciasAsyncAction = AsyncAction(
      '_UserComandaStoreBase.sincronizarPendencias',
      context: context);

  @override
  Future<void> sincronizarPendencias() {
    return _$sincronizarPendenciasAsyncAction
        .run(() => super.sincronizarPendencias());
  }

  late final _$addOrUpdateCardAsyncAction =
      AsyncAction('_UserComandaStoreBase.addOrUpdateCard', context: context);

  @override
  Future<void> addOrUpdateCard(Comanda2 comanda) {
    return _$addOrUpdateCardAsyncAction
        .run(() => super.addOrUpdateCard(comanda));
  }

  late final _$removeComandaAsyncAction =
      AsyncAction('_UserComandaStoreBase.removeComanda', context: context);

  @override
  Future<void> removeComanda(int index) {
    return _$removeComandaAsyncAction.run(() => super.removeComanda(index));
  }

  late final _$deleteComandaDescartaveisAsyncAction = AsyncAction(
      '_UserComandaStoreBase.deleteComandaDescartaveis',
      context: context);

  @override
  Future<void> deleteComandaDescartaveis(ComandaDescartaveis comanda) {
    return _$deleteComandaDescartaveisAsyncAction
        .run(() => super.deleteComandaDescartaveis(comanda));
  }

  late final _$loadAllComandasAsyncAction =
      AsyncAction('_UserComandaStoreBase.loadAllComandas', context: context);

  @override
  Future<void> loadAllComandas() {
    return _$loadAllComandasAsyncAction.run(() => super.loadAllComandas());
  }

  late final _$_UserComandaStoreBaseActionController =
      ActionController(name: '_UserComandaStoreBase', context: context);

  @override
  void removeComandaStorage(int index) {
    final _$actionInfo = _$_UserComandaStoreBaseActionController.startAction(
        name: '_UserComandaStoreBase.removeComandaStorage');
    try {
      return super.removeComandaStorage(index);
    } finally {
      _$_UserComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addOrUpdateCardStorage(Comanda2 comanda) {
    final _$actionInfo = _$_UserComandaStoreBaseActionController.startAction(
        name: '_UserComandaStoreBase.addOrUpdateCardStorage');
    try {
      return super.addOrUpdateCardStorage(comanda);
    } finally {
      _$_UserComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedDate(DateTime date) {
    final _$actionInfo = _$_UserComandaStoreBaseActionController.startAction(
        name: '_UserComandaStoreBase.setSelectedDate');
    try {
      return super.setSelectedDate(date);
    } finally {
      _$_UserComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  List<Comanda2> getComandasForSelectedDay(DateTime date) {
    final _$actionInfo = _$_UserComandaStoreBaseActionController.startAction(
        name: '_UserComandaStoreBase.getComandasForSelectedDay');
    try {
      return super.getComandasForSelectedDay(date);
    } finally {
      _$_UserComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
comandas: ${comandas},
descartaveisComanda: ${descartaveisComanda},
selectedDate: ${selectedDate}
    ''';
  }
}

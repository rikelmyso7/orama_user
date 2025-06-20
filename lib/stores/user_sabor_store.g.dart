// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_sabor_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserSaborStore on _UserSaborStore, Store {
  late final _$saboresAtom =
      Atom(name: '_UserSaborStore.sabores', context: context);

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
  void addSabor(Sabor sabor) {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.addSabor');
    try {
      return super.addSabor(sabor);
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeSabor(Sabor sabor) {
    final _$actionInfo = _$_UserSaborStoreActionController.startAction(
        name: '_UserSaborStore.removeSabor');
    try {
      return super.removeSabor(sabor);
    } finally {
      _$_UserSaborStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSabor(int index, Sabor sabor) {
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

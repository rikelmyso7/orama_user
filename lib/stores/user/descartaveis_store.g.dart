// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'descartaveis_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DescartaveisStore on _DescartaveisStoreBase, Store {
  Computed<List<Descartaveis>>? _$DescartaveisForSelectedDateComputed;

  @override
  List<Descartaveis> get DescartaveisForSelectedDate =>
      (_$DescartaveisForSelectedDateComputed ??= Computed<List<Descartaveis>>(
              () => super.DescartaveisForSelectedDate,
              name: '_DescartaveisStoreBase.DescartaveisForSelectedDate'))
          .value;

  late final _$descartaveisAtom =
      Atom(name: '_DescartaveisStoreBase.descartaveis', context: context);

  @override
  ObservableList<Descartaveis> get descartaveis {
    _$descartaveisAtom.reportRead();
    return super.descartaveis;
  }

  @override
  set descartaveis(ObservableList<Descartaveis> value) {
    _$descartaveisAtom.reportWrite(value, super.descartaveis, () {
      super.descartaveis = value;
    });
  }

  late final _$selectedDateAtom =
      Atom(name: '_DescartaveisStoreBase.selectedDate', context: context);

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

  late final _$pendingDescartaveisAtom = Atom(
      name: '_DescartaveisStoreBase.pendingDescartaveis', context: context);

  @override
  ObservableList<Descartaveis> get pendingDescartaveis {
    _$pendingDescartaveisAtom.reportRead();
    return super.pendingDescartaveis;
  }

  @override
  set pendingDescartaveis(ObservableList<Descartaveis> value) {
    _$pendingDescartaveisAtom.reportWrite(value, super.pendingDescartaveis, () {
      super.pendingDescartaveis = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_DescartaveisStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$deleteComandaAsyncAction =
      AsyncAction('_DescartaveisStoreBase.deleteComanda', context: context);

  @override
  Future<void> deleteComanda(String comandaId) {
    return _$deleteComandaAsyncAction.run(() => super.deleteComanda(comandaId));
  }

  late final _$addOrUpdateCardAsyncAction =
      AsyncAction('_DescartaveisStoreBase.addOrUpdateCard', context: context);

  @override
  Future<void> addOrUpdateCard(Descartaveis comanda) {
    return _$addOrUpdateCardAsyncAction
        .run(() => super.addOrUpdateCard(comanda));
  }

  late final _$syncPendingDescartaveisAsyncAction = AsyncAction(
      '_DescartaveisStoreBase.syncPendingDescartaveis',
      context: context);

  @override
  Future<void> syncPendingDescartaveis() {
    return _$syncPendingDescartaveisAsyncAction
        .run(() => super.syncPendingDescartaveis());
  }

  late final _$_syncPendingDescartaveisAsyncAction = AsyncAction(
      '_DescartaveisStoreBase._syncPendingDescartaveis',
      context: context);

  @override
  Future<void> _syncPendingDescartaveis() {
    return _$_syncPendingDescartaveisAsyncAction
        .run(() => super._syncPendingDescartaveis());
  }

  late final _$_DescartaveisStoreBaseActionController =
      ActionController(name: '_DescartaveisStoreBase', context: context);

  @override
  List<Descartaveis> getDescartaveisForSelectedDay2(DateTime date) {
    final _$actionInfo = _$_DescartaveisStoreBaseActionController.startAction(
        name: '_DescartaveisStoreBase.getDescartaveisForSelectedDay2');
    try {
      return super.getDescartaveisForSelectedDay2(date);
    } finally {
      _$_DescartaveisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSelectedDate(DateTime date) {
    final _$actionInfo = _$_DescartaveisStoreBaseActionController.startAction(
        name: '_DescartaveisStoreBase.setSelectedDate');
    try {
      return super.setSelectedDate(date);
    } finally {
      _$_DescartaveisStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
descartaveis: ${descartaveis},
selectedDate: ${selectedDate},
pendingDescartaveis: ${pendingDescartaveis},
isLoading: ${isLoading},
DescartaveisForSelectedDate: ${DescartaveisForSelectedDate}
    ''';
  }
}

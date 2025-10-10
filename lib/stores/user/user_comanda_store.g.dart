// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_comanda_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserComandaStore on _UserComandaStoreBase, Store {
  Computed<List<Comanda2>>? _$comandasForSelectedDateComputed;

  @override
  List<Comanda2> get comandasForSelectedDate =>
      (_$comandasForSelectedDateComputed ??= Computed<List<Comanda2>>(
              () => super.comandasForSelectedDate,
              name: '_UserComandaStoreBase.comandasForSelectedDate'))
          .value;

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

  late final _$pendingComandasAtom =
      Atom(name: '_UserComandaStoreBase.pendingComandas', context: context);

  @override
  ObservableList<Comanda2> get pendingComandas {
    _$pendingComandasAtom.reportRead();
    return super.pendingComandas;
  }

  @override
  set pendingComandas(ObservableList<Comanda2> value) {
    _$pendingComandasAtom.reportWrite(value, super.pendingComandas, () {
      super.pendingComandas = value;
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

  late final _$isLoadingAtom =
      Atom(name: '_UserComandaStoreBase.isLoading', context: context);

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

  late final _$isSyncingAtom =
      Atom(name: '_UserComandaStoreBase.isSyncing', context: context);

  @override
  bool get isSyncing {
    _$isSyncingAtom.reportRead();
    return super.isSyncing;
  }

  @override
  set isSyncing(bool value) {
    _$isSyncingAtom.reportWrite(value, super.isSyncing, () {
      super.isSyncing = value;
    });
  }

  late final _$syncErrorAtom =
      Atom(name: '_UserComandaStoreBase.syncError', context: context);

  @override
  String? get syncError {
    _$syncErrorAtom.reportRead();
    return super.syncError;
  }

  @override
  set syncError(String? value) {
    _$syncErrorAtom.reportWrite(value, super.syncError, () {
      super.syncError = value;
    });
  }

  late final _$deleteComandaAsyncAction =
      AsyncAction('_UserComandaStoreBase.deleteComanda', context: context);

  @override
  Future<void> deleteComanda(String comandaId) {
    return _$deleteComandaAsyncAction.run(() => super.deleteComanda(comandaId));
  }

  late final _$addOrUpdateCardAsyncAction =
      AsyncAction('_UserComandaStoreBase.addOrUpdateCard', context: context);

  @override
  Future<void> addOrUpdateCard(Comanda2 comanda) {
    return _$addOrUpdateCardAsyncAction
        .run(() => super.addOrUpdateCard(comanda));
  }

  late final _$syncPendingComandasAsyncAction = AsyncAction(
      '_UserComandaStoreBase.syncPendingComandas',
      context: context);

  @override
  Future<void> syncPendingComandas() {
    return _$syncPendingComandasAsyncAction
        .run(() => super.syncPendingComandas());
  }

  late final _$setSelectedDateAsyncAction =
      AsyncAction('_UserComandaStoreBase.setSelectedDate', context: context);

  @override
  Future<void> setSelectedDate(DateTime date) {
    return _$setSelectedDateAsyncAction.run(() => super.setSelectedDate(date));
  }

  late final _$_syncPendingComandasAsyncAction = AsyncAction(
      '_UserComandaStoreBase._syncPendingComandas',
      context: context);

  @override
  Future<void> _syncPendingComandas() {
    return _$_syncPendingComandasAsyncAction
        .run(() => super._syncPendingComandas());
  }

  late final _$_UserComandaStoreBaseActionController =
      ActionController(name: '_UserComandaStoreBase', context: context);

  @override
  List<Comanda2> getComandasForSelectedDay2(DateTime date) {
    final _$actionInfo = _$_UserComandaStoreBaseActionController.startAction(
        name: '_UserComandaStoreBase.getComandasForSelectedDay2');
    try {
      return super.getComandasForSelectedDay2(date);
    } finally {
      _$_UserComandaStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
comandas: ${comandas},
pendingComandas: ${pendingComandas},
selectedDate: ${selectedDate},
isLoading: ${isLoading},
isSyncing: ${isSyncing},
syncError: ${syncError},
comandasForSelectedDate: ${comandasForSelectedDate}
    ''';
  }
}

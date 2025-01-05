// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'descartaveis_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DescartaveisStore on _DescartaveisStoreBase, Store {
  late final _$descartaveisAtom =
      Atom(name: '_DescartaveisStoreBase.descartaveis', context: context);

  @override
  ObservableList<ComandaDescartaveis> get descartaveis {
    _$descartaveisAtom.reportRead();
    return super.descartaveis;
  }

  @override
  set descartaveis(ObservableList<ComandaDescartaveis> value) {
    _$descartaveisAtom.reportWrite(value, super.descartaveis, () {
      super.descartaveis = value;
    });
  }

  late final _$deleteComandaDescartaveisAsyncAction = AsyncAction(
      '_DescartaveisStoreBase.deleteComandaDescartaveis',
      context: context);

  @override
  Future<void> deleteComandaDescartaveis(ComandaDescartaveis comanda) {
    return _$deleteComandaDescartaveisAsyncAction
        .run(() => super.deleteComandaDescartaveis(comanda));
  }

  late final _$salvarPendenciaOfflineDescartaveisAsyncAction = AsyncAction(
      '_DescartaveisStoreBase.salvarPendenciaOfflineDescartaveis',
      context: context);

  @override
  Future<void> salvarPendenciaOfflineDescartaveis(ComandaDescartaveis comanda) {
    return _$salvarPendenciaOfflineDescartaveisAsyncAction
        .run(() => super.salvarPendenciaOfflineDescartaveis(comanda));
  }

  late final _$addOrUpdateDescartavelAsyncAction = AsyncAction(
      '_DescartaveisStoreBase.addOrUpdateDescartavel',
      context: context);

  @override
  Future<void> addOrUpdateDescartavel(ComandaDescartaveis descartavel) {
    return _$addOrUpdateDescartavelAsyncAction
        .run(() => super.addOrUpdateDescartavel(descartavel));
  }

  @override
  String toString() {
    return '''
descartaveis: ${descartaveis}
    ''';
  }
}

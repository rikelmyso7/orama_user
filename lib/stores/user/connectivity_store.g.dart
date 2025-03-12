// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ConnectivityStore on _ConnectivityStoreBase, Store {
  late final _$isOfflineAtom =
      Atom(name: '_ConnectivityStoreBase.isOffline', context: context);

  @override
  bool get isOffline {
    _$isOfflineAtom.reportRead();
    return super.isOffline;
  }

  @override
  set isOffline(bool value) {
    _$isOfflineAtom.reportWrite(value, super.isOffline, () {
      super.isOffline = value;
    });
  }

  @override
  String toString() {
    return '''
isOffline: ${isOffline}
    ''';
  }
}

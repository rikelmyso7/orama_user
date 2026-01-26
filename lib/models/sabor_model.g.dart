// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sabor_model.dart';

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

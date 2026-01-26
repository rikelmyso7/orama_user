// models/sabor_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'sabor_model.g.dart';

@JsonSerializable()
class Sabor {
  String nome;
  String categoria;
  int quantidade;

  Sabor({
    required this.nome,
    required this.categoria,
    required this.quantidade,
  });

  factory Sabor.fromJson(Map<String, dynamic> json) =>
      _$SaborFromJson(json);
  Map<String, dynamic> toJson() => _$SaborToJson(this);
}

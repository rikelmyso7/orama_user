import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';

class Comanda2 {
  String name;
  String? periodo;
  String id;
  String pdv;
  String userId;
  Map<String, Map<String, Map<String, int>>> sabores;
  DateTime data;
  String? caixaInicial;
  String? caixaFinal;
  String? pixInicial;
  String? pixFinal;
  ComandaStatus status;

  Comanda2({
    required this.name,
    required this.id,
    required this.periodo,
    required this.pdv,
    required this.userId,
    required this.sabores,
    required this.data,
    this.caixaInicial,
    this.caixaFinal,
    this.pixInicial,
    this.pixFinal,
    this.status = ComandaStatus.pendente,
  });

  factory Comanda2.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, Map<String, int>>> saboresConvertidos = {};
    if (json['sabores'] != null) {
      Map<String, dynamic> saboresJson = json['sabores'];

      saboresJson.forEach((categoria, saboresMap) {
        saboresConvertidos[categoria] = {};
        (saboresMap as Map<String, dynamic>).forEach((sabor, opcoesMap) {
          saboresConvertidos[categoria]![sabor] =
              Map<String, int>.from(opcoesMap);
        });
      });
    }

    return Comanda2(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      periodo: json['periodo'] ?? '',
      pdv: json['pdv'] ?? '',
      userId: json['userId'] ?? '',
      sabores: saboresConvertidos,
      data: DateTime.parse(json['data'] ?? DateTime.now().toIso8601String()),
      caixaInicial: json['caixaInicial'],
      caixaFinal: json['caixaFinal'],
      pixInicial: json['pixInicial'],
      pixFinal: json['pixFinal'],
      status: ComandaStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'pendente'),
        orElse: () => ComandaStatus.pendente,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'periodo': periodo,
      'id': id,
      'pdv': pdv,
      'userId': userId,
      'sabores': sabores,
      'data': data.toIso8601String(),
      'caixaInicial': caixaInicial,
      'caixaFinal': caixaFinal,
      'pixInicial': pixInicial,
      'pixFinal': pixFinal,
      'status': status.toString().split('.').last,
    };
  }

  factory Comanda2.fromDoc(DocumentSnapshot doc) =>
      Comanda2.fromJson(doc.data() as Map<String, dynamic>);
}

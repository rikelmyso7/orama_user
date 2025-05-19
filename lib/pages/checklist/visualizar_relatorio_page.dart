import 'package:flutter/material.dart';

class VisualizarRelatorioPage extends StatelessWidget {
  final String date;
  final Map<String, dynamic> relatorioData;

  const VisualizarRelatorioPage({
    super.key,
    required this.date,
    required this.relatorioData,
  });

  @override
  Widget build(BuildContext context) {
    final checklist = relatorioData['checklist'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de $date'),
        backgroundColor: const Color(0xff60C03D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pix: ${relatorioData['pix']}'),
            const SizedBox(height: 8),
            Text('Venda: R\$ ${relatorioData['valorVenda'].toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Comissão: R\$ ${relatorioData['comissao'].toStringAsFixed(2)}'),
            const SizedBox(height: 24),
            const Text(
              'Checklist:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final item in checklist)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item['imageUrl'] != null)
                      Image.network(item['imageUrl']),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(item['description'] ?? ''),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

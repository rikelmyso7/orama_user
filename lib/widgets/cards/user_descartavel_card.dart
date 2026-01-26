import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/models/descartaveis_model.dart';
import 'package:orama_user/others/descartaveis.dart';
import 'package:orama_user/pages/user/user_descartaveis_edit.dart';
import 'package:orama_user/stores/user/connectivity_store.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/utils/comanda_utils.dart';
import 'package:orama_user/utils/exit_dialog_utils.dart';
import 'package:orama_user/utils/loading_dialog_utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDescartavelCard extends StatelessWidget {
  final Descartaveis comanda;

  const UserDescartavelCard({Key? key, required this.comanda})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityStore = Provider.of<ConnectivityStore>(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Text(
                        'Atendente - ${comanda.name} | ${comanda.periodo}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (connectivityStore.isOffline)
                        const Text(
                          'Verifique a conexão com a internet...',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            _buildHeader(context),
            _buildDateRow(context),
            const SizedBox(height: 8.0),
            _buildDescartaveisList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (comanda.status) {
      case DescartaveisStatus.pendente:
        return Column(
          children: [
            const Icon(Icons.check, size: 22, color: Colors.grey),
            Text(
              "Enviado\nAguardando Internet",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        );
      case DescartaveisStatus.entregue:
        return const Icon(Icons.done_all, size: 22, color: Colors.green);
    }
  }

  void _deleteComanda(BuildContext context) {
    ComandaUtils.deleteComandaDescartaveis(context, comanda);
  }

  void _changeDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: comanda.data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (!context.mounted) return;
    if (picked == null || picked == comanda.data) return;

    final store = context.read<DescartaveisStore>();

    // remove e add => Observer percebe
    store.deleteComanda(comanda.id); // já remove da lista observável
    store.addOrUpdateCard(comanda.copyWith(data: picked));
  }

  void _editComanda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDescartaveisEdit(comanda: comanda),
      ),
    );
  }

  // Função para gerar o texto do relatório
  String _generateReportText() {
    final sortedItems = List<Map<String, String>>.from(comanda.itens);
    sortedItems.sort((a, b) => (a['Item'] ?? '').compareTo(b['Item'] ?? ''));
    final dateFormatted = DateFormat('dd/MM/yyyy').format(comanda.data);
    StringBuffer report = StringBuffer();

    report.writeln("📝 *Relatório Descartaveis*"); // Corrigido
    report.writeln("📍 *PDV:* ${comanda.pdv}");
    report.writeln("👤 *Atendente:* ${comanda.name}");
    report.writeln("📅 *Data:* ${dateFormatted}\n");
    report.writeln('\n📦 *Itens:*');

    if (sortedItems.isNotEmpty) {
      for (var item in sortedItems) {
        final itemName = item['Item'] ?? 'Item';
        final quantity = item['Quantidade'] ?? '';
        final observationIndex = comanda.itens.indexOf(item);

        report.writeln('  - *$itemName*');
        report.writeln('    Quantidade: $quantity');

        if (observationIndex < comanda.observacoes.length) {
          report.writeln(
              '    Observação: ${comanda.observacoes[observationIndex]}');
        }
      }
    } else {
      for (int i = 0; i < descartaveis.length; i++) {
        final quantity =
            i < comanda.observacoes.length ? comanda.observacoes[i] : '';
        report.writeln('  - *${descartaveis[i].name}*');
        report.writeln('    Quantidade: $quantity');
        if (i < comanda.observacoes.length) {
          report.writeln('    📝 Observação: ${comanda.observacoes[i]}');
        }
      }
    }

    return report.toString();
  }

  // Função para compartilhar o relatório

  Future<void> _shareReport(BuildContext context) async {
    if (!context.mounted) return;

    final reportText = _generateReportText();
    bool whatsappOpened = false;

    try {
      final encodedText = Uri.encodeComponent(reportText);
      final Uri whatsappUri = Uri.parse('whatsapp://send?text=$encodedText');

      final canLaunch = await canLaunchUrl(whatsappUri);

      if (canLaunch) {
        await launchUrl(whatsappUri);
        whatsappOpened = true;
      }
    } catch (e) {
      print('Erro ao tentar abrir WhatsApp: $e');
    }

    // Se WhatsApp não abriu, copia para clipboard
    if (!whatsappOpened) {
      try {
        await Clipboard.setData(ClipboardData(text: reportText));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Relatório copiado para área de transferência'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Erro ao copiar para clipboard: $e');
      }
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${comanda.pdv}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editComanda(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  DialogUtils.showConfirmationDialog(
                    context: context,
                    title: 'Excluir Item',
                    content: 'Tem certeza que deseja excluir este Relatório?',
                    confirmText: 'Excluir',
                    cancelText: 'Cancelar',
                    onConfirm: () => _deleteComanda(context),
                  );
                },
              ),
              IconButton(
                onPressed: () => _shareReport(context),
                icon: const FaIcon(FontAwesomeIcons.whatsapp),
                tooltip: 'Compartilhar ou Copiar', // Dica para o usuário
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => _changeDate(context),
            child: Text(
              DateFormat('dd/MM/yyyy').format(comanda.data),
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildStatusIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescartaveisList() {
    final bool hasNewFormat = comanda.itens.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: hasNewFormat ? _buildNewFormatList() : _buildOldFormatList(),
      ),
    );
  }

  List<Widget> _buildNewFormatList() {
    List<Map<String, String>> sortedItems = List.from(comanda.itens);
    sortedItems.sort((a, b) => (a['Item'] ?? '').compareTo(b['Item'] ?? ''));

    return sortedItems.map((item) {
      final itemName = item['Item'] ?? 'Item';
      final quantity = item['Quantidade'] ?? '';
      final observationIndex = item['Observacao'] ?? '';
      ;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text('- Quantidade: $quantity'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text('- Observação: ${observationIndex}'),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildOldFormatList() {
    return List.generate(descartaveis.length, (index) {
      final quantity =
          index < comanda.observacoes.length ? comanda.observacoes[index] : '';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              index < descartaveis.length
                  ? descartaveis[index].name
                  : 'Item $index',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text('- Quantidade: $quantity'),
            ),
            if (index < comanda.observacoes.length)
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text('- Observação: ${comanda.observacoes[index]}'),
              ),
          ],
        ),
      );
    });
  }
}

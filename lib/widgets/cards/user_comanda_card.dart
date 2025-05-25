import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Adicionado para Clipboard
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/pages/user/user_sabores_edit_page.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/comanda_utils.dart';
import 'package:orama_user/utils/exit_dialog_utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UserComandaCard extends StatelessWidget {
  final Comanda2 comanda;

  UserComandaCard({
    required this.comanda,
    Key? key,
  }) : super(key: key ?? ValueKey(comanda.id));

  // Função para compartilhar a comanda ou copiar para a área de transferência
  Future<void> _shareReport(BuildContext context) async {
    final reportText = _generateReportText();
    final encodedText = Uri.encodeComponent(reportText);
    final Uri whatsappUri = Uri.parse('whatsapp://send?text=$encodedText');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      Share.share(reportText);
    }
  }

  // Função para gerar a mensagem da comanda
  String _generateReportText() {
    StringBuffer message = StringBuffer();

    message.writeln("📝 *Comanda de Sabores*");
    message.writeln("📍 *PDV:* ${comanda.pdv}");
    message.writeln("👤 *Atendente:* ${comanda.name}");
    message.writeln(
        "📅 *Data:* ${DateFormat('dd/MM/yyyy').format(comanda.data)}\n");

    if (comanda.caixaInicial != null && comanda.caixaInicial!.isNotEmpty) {
      message.writeln("💰 *Caixa Inicial:* R\$ ${comanda.caixaInicial}");
    }
    if (comanda.caixaFinal != null && comanda.caixaFinal!.isNotEmpty) {
      message.writeln("💰 *Caixa Final:* R\$ ${comanda.caixaFinal}");
    }
    if (comanda.pixInicial != null && comanda.pixInicial!.isNotEmpty) {
      message.writeln("💳 *Pix Inicial:* R\$ ${comanda.pixInicial}");
    }
    if (comanda.pixFinal != null && comanda.pixFinal!.isNotEmpty) {
      message.writeln("💳 *Pix Final:* R\$ ${comanda.pixFinal}");
    }

    message.writeln("\n🍦 *Sabores:*");

    comanda.sabores.forEach((categoria, sabores) {
      message.writeln("\n📌 *$categoria:*");

      sabores.forEach((sabor, opcoes) {
        String saborNome = categoria == 'Massas' ? "Massa de $sabor" : sabor;
        message.writeln("🔹 *$saborNome*");

        opcoes.forEach((opcao, quantidade) {
          if (quantidade > 0) {
            String unidade = (categoria == 'Massas') ? 'Tubos' : 'Cubas';
            if (sabor == 'Manteiga') unidade = 'Pote';

            message.writeln("   - $quantidade $unidade ($opcao)");
          }
        });
      });
    });

    message.writeln("\n📌 *Enviado via Orama User App*");

    return message.toString();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    'Atendente - ${comanda.name}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            _buildHeader(context),
            _buildDateRow(context),
            const SizedBox(height: 8.0),
            ..._buildSaborList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (comanda.status) {
      case ComandaStatus.pendente:
        return const Icon(Icons.access_time, size: 22, color: Colors.orange);
      case ComandaStatus.enviado:
        return const Icon(Icons.check, size: 22, color: Colors.grey);
      case ComandaStatus.entregue:
        return const Icon(Icons.done_all, size: 22, color: Colors.green);
    }
  }

  void _deleteComanda(BuildContext context) {
    ComandaUtils.deleteComanda(context, comanda);
  }

  void _editComanda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSaboresEditPage(comanda: comanda),
      ),
    );
  }

  void _changeDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: comanda.data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != comanda.data) {
      comanda.data = pickedDate;
      final store = UserComandaStore();
      store.addOrUpdateCard(comanda);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${comanda.pdv}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editComanda(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      DialogUtils.showConfirmationDialog(
                        context: context,
                        title: 'Excluir Item',
                        content:
                            'Tem certeza que deseja excluir este Relatório?',
                        confirmText: 'Excluir',
                        cancelText: 'Cancelar',
                        onConfirm: () {
                          _deleteComanda(context);
                        },
                      );
                    },
                  ),
                  IconButton(
                      icon: const FaIcon(FontAwesomeIcons.whatsapp),
                      tooltip: 'Compartilhar ou Copiar', // Dica para o usuário
                      onPressed: () async {
                        final store = Provider.of<UserComandaStore>(context);

                        // Atualiza a comanda local
                        comanda.status = ComandaStatus.entregue;

                        // Salva no Firebase com o status novo
                        await store.addOrUpdateCard(comanda);

                        // Envia mensagem
                        await _shareReport(context);
                      }),
                ],
              ),
            ],
          ),
          if (comanda.caixaInicial != null && comanda.caixaInicial!.isNotEmpty)
            Text(
              'Caixa Inicial: R\$ ${comanda.caixaInicial}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          if (comanda.caixaFinal != null && comanda.caixaFinal!.isNotEmpty)
            Text(
              'Caixa Final: R\$ ${comanda.caixaFinal}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          if (comanda.pixInicial != null && comanda.pixInicial!.isNotEmpty)
            Text(
              'Pix Inicial: R\$ ${comanda.pixInicial}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          if (comanda.pixFinal != null && comanda.pixFinal!.isNotEmpty)
            Text(
              'Pix Final: R\$ ${comanda.pixFinal}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
              onPressed: () => _changeDate(context),
              child: Text(
                DateFormat('dd/MM/yyyy').format(comanda.data),
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold),
              )),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildStatusIcon(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSaborList() {
    print("Comanda sabores: ${comanda.sabores}");

    if (comanda.sabores.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: const Text("Nenhum sabor selecionado."),
        ),
      ];
    }

    return comanda.sabores.entries.expand((categoria) {
      return categoria.value.entries.map((saborEntry) {
        print(
            "Categoria: ${categoria.key}, Sabor: ${saborEntry.key}, Quantidades: ${saborEntry.value}");
        final opcoesValidas = saborEntry.value.entries
            .where((quantidadeEntry) => quantidadeEntry.value > 0)
            .toList();

        if (opcoesValidas.isEmpty) {
          return Container();
        }

        final isMassa = categoria.key == 'Massas';
        final isManteiga = saborEntry.key == 'Manteiga';
        final unidade = isManteiga ? 'Pote' : (isMassa ? 'Tubos' : 'Cubas');
        final saborNome = isManteiga
            ? "Manteiga"
            : (isMassa ? "Massa de ${saborEntry.key}" : saborEntry.key);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                saborNome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              ...opcoesValidas.map((quantidadeEntry) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    isManteiga
                        ? "- ${quantidadeEntry.key} $unidade"
                        : isMassa
                            ? "- ${quantidadeEntry.key} $unidade"
                            : "- ${quantidadeEntry.value} $unidade ${quantidadeEntry.key}",
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList();
    }).toList();
  }
}

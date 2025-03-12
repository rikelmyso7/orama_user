import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Adicionado para Clipboard
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/pages/user/user_sabores_edit_page.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/comanda_utils.dart';
import 'package:orama_user/utils/exit_dialog_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class UserComandaCard extends StatelessWidget {
  final Comanda2 comanda;

  UserComandaCard({
    required this.comanda,
    Key? key,
  }) : super(key: key ?? ValueKey(comanda.id));

  // Função para compartilhar a comanda ou copiar para a área de transferência
  void _shareComanda(BuildContext context) async {
    String message = _generateComandaMessage();

    if (await canLaunchUrl(Uri.parse("https://wa.me/"))) {
      String encodedMessage = Uri.encodeComponent(message);
      String whatsappUrl = "https://wa.me/?text=$encodedMessage";
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      // Fallback: Copiar para a área de transferência
      await Clipboard.setData(ClipboardData(text: message));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comanda copiada para a área de transferência!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Função para gerar a mensagem da comanda
  String _generateComandaMessage() {
    String message = "📝 *Comanda de Sabores*\n";
    message += "📍 *PDV:* ${comanda.pdv}\n";
    message += "👤 *Atendente:* ${comanda.name}\n";
    message +=
        "📅 *Data:* ${DateFormat('dd/MM/yyyy').format(comanda.data)}\n\n";

    if (comanda.caixaInicial != null && comanda.caixaInicial!.isNotEmpty) {
      message += "💰 *Caixa Inicial:* R\$ ${comanda.caixaInicial}\n";
    }
    if (comanda.caixaFinal != null && comanda.caixaFinal!.isNotEmpty) {
      message += "💰 *Caixa Final:* R\$ ${comanda.caixaFinal}\n";
    }
    if (comanda.pixInicial != null && comanda.pixInicial!.isNotEmpty) {
      message += "💳 *Pix Inicial:* R\$ ${comanda.pixInicial}\n";
    }
    if (comanda.pixFinal != null && comanda.pixFinal!.isNotEmpty) {
      message += "💳 *Pix Final:* R\$ ${comanda.pixFinal}\n";
    }

    message += "\n🍦 *Sabores:*\n";
    comanda.sabores.forEach((categoria, sabores) {
      message += "\n📌 *$categoria:*\n";
      sabores.forEach((sabor, opcoes) {
        String saborNome = categoria == 'Massas' ? "Massa de $sabor" : sabor;
        message += "🔹 $saborNome\n";

        opcoes.forEach((opcao, quantidade) {
          if (quantidade > 0) {
            String unidade = (categoria == 'Massas') ? 'Tubos' : 'Cubas';
            if (sabor == 'Manteiga') unidade = 'Pote';
            message += "   - $quantidade $unidade ($opcao)\n";
          }
        });
      });
    });

    message += "\n📌 *Enviado via Orama User App*";

    return message;
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
                    onPressed: () => _shareComanda(context),
                    icon: const FaIcon(FontAwesomeIcons.whatsapp),
                    tooltip: 'Compartilhar ou Copiar', // Dica para o usuário
                  ),
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
      child: TextButton(
          onPressed: () => _changeDate(context),
          child: Text(
            DateFormat('dd/MM/yyyy').format(comanda.data),
            style: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold),
          )),
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
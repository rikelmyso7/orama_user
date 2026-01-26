// user_descartaveis_edit.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/utils/loading_dialog_utils.dart';
import 'package:provider/provider.dart';

import 'package:orama_user/models/descartaveis_model.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/others/descartaveis.dart';

class UserDescartaveisEdit extends StatefulWidget {
  final Descartaveis comanda;

  const UserDescartaveisEdit({Key? key, required this.comanda})
      : super(key: key);

  @override
  State<UserDescartaveisEdit> createState() => _UserDescartaveisEditState();
}

class _UserDescartaveisEditState extends State<UserDescartaveisEdit> {
  // ---------- estado ----------
  late final List<String> _quantities; // valores pré-preenchidos
  late final List<String> _notes;
  late final List<bool> _showNotes;
  late final List<bool> _showTextField;
  late final List<TextEditingController> _textCtrls;
  late final List<TextEditingController> _noteCtrls;
  late final List<FocusNode> _focusNodes;
  late final List<bool> _hasError;

  // ---------- outros ----------
  late final ScrollController _scroll;
  static const Color _primaryColor = Color(0xff60C03D);

  // ---------- ciclo ----------
  @override
  void initState() {
    super.initState();

    // Mapeia quantidades/observações existentes para cada item da lista fixa
    final Map<String, String> qtyMap = {
      for (final i in widget.comanda.itens) i['Item']!: i['Quantidade'] ?? ''
    };
    final Map<String, String> obsMap = {
      for (int i = 0; i < widget.comanda.observacoes.length; i++)
        widget.comanda.itens[i]['Item']!: widget.comanda.observacoes[i]
    };

    final count = descartaveis.length;
    _quantities =
        List.generate(count, (i) => qtyMap[descartaveis[i].name] ?? '');
    _notes = List.generate(count, (i) => obsMap[descartaveis[i].name] ?? '');
    _showNotes = List.generate(count, (i) => _notes[i].isNotEmpty);
    _showTextField = List.filled(count, false);
    _hasError = List.filled(count, false);

    _textCtrls = List.generate(
        count, (i) => TextEditingController(text: _quantities[i]));
    _noteCtrls =
        List.generate(count, (i) => TextEditingController(text: _notes[i]));
    _focusNodes = List.generate(count, (i) => FocusNode());

    _scroll = ScrollController()..addListener(_dismissOnScroll);
  }

  @override
  void dispose() {
    for (final c in _textCtrls) c.dispose();
    for (final c in _noteCtrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _scroll
      ..removeListener(_dismissOnScroll)
      ..dispose();
    super.dispose();
  }

  // ---------- helpers ----------
  void _dismissKeyboard() => FocusScope.of(context).unfocus();
  void _dismissOnScroll() {
    if (_scroll.hasClients && _scroll.position.isScrollingNotifier.value)
      _dismissKeyboard();
  }

  List<String> _options(String type) {
    switch (type) {
      case 'numeric':
        return [...List.generate(6, (i) => i.toString()), 'Outro'];
      case 'fractional':
        return ['Vazio', '1/4', '2/4', '3/4', '4/4'];
      case 'text':
        return ['Cheio', 'Pouco', 'Vazio'];
      case 'quantity':
        return [...List.generate(6, (i) => i.toString()), 'Outro'];
      default:
        return [];
    }
  }

  // ---------- salvar ----------
  Future<void> _save() async {
    // ─── 1. Validação ──────────────────────────────────────────────
    bool ok = true;
    int firstErr = -1;

    for (int i = 0; i < _quantities.length; i++) {
      if (_quantities[i].trim().isEmpty) {
        _hasError[i] = true;
        ok = false;
        firstErr = firstErr == -1 ? i : firstErr;
      } else {
        _hasError[i] = false;
      }
    }
    setState(() {}); // atualiza erros na UI
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, preencha todos os itens.'),
        backgroundColor: Colors.red,
      ));
      _scroll.animateTo(firstErr * 230.0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return;
    }

    // ─── 2. Exibe loading (SEM await!) ─────────────────────────────
    LoadingDialog.show(context);

    // ─── 3. Monta itens + observações gerais ───────────────────────
    final itens = <Map<String, String>>[];
    final obsGerais = <String>[];

    for (int i = 0; i < descartaveis.length; i++) {
      itens.add({
        'Item': descartaveis[i].name,
        'Quantidade': _quantities[i],
        'Observacao': _notes[i].trim(), // mantém no item
      });
      if (_notes[i].trim().isNotEmpty) obsGerais.add(_notes[i].trim());
    }

    final atualizado = widget.comanda.copyWith(
      itens: itens,
      observacoes: obsGerais, // compat. telas antigas
      data: DateTime.now(),
    );

    // ─── 4. Salva via store ────────────────────────────────────────
    try {
      await context.read<DescartaveisStore>().addOrUpdateCard(atualizado);

      if (!mounted) return;
      Navigator.of(context).pop(); // fecha o loading
      Navigator.pushReplacementNamed(context, RouteName.user_descartaveis_page);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // fecha o loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ---------- UI helpers ----------
  Widget _opcoesRadio(List<String> op, int index) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: op.map((o) {
        return Column(
          children: [
            Radio<String>(
              activeColor: _primaryColor,
              value: o,
              groupValue: _quantities[index].isEmpty && _showTextField[index]
                  ? 'Outro'
                  : _quantities[index],
              onChanged: (v) {
                setState(() {
                  final isOutro = v == 'Outro';
                  _showTextField[index] = isOutro;
                  _quantities[index] = isOutro ? '' : v!;
                  _textCtrls[index].clear();
                  _hasError[index] = false;
                });
              },
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  final isOutro = o == 'Outro';
                  _showTextField[index] = isOutro;
                  _quantities[index] = isOutro ? '' : o;
                  _textCtrls[index].clear();
                  _hasError[index] = false;
                });
              },
              child: Text(o, style: const TextStyle(fontSize: 14)),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _quantidadeField(int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _textCtrls[idx],
        keyboardType: descartaveis[idx].type == 'numeric'
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: 'Digite a quantidade',
          border: const OutlineInputBorder(),
          suffixIcon: Icon(
            _quantities[idx].isNotEmpty ? Icons.check : Icons.close,
            color: _quantities[idx].isNotEmpty ? Colors.green : Colors.red,
          ),
        ),
        onChanged: (v) => setState(() => _quantities[idx] = v),
      ),
    );
  }

  Widget _seletorQuantidade(int idx) {
    final opts = _options(descartaveis[idx].type);
    if (opts.isEmpty) return _quantidadeField(idx);

    return Column(
      children: [
        _opcoesRadio(opts, idx),
        if (_showTextField[idx]) _quantidadeField(idx),
      ],
    );
  }

  Widget _notaSecao(int idx) {
    return Column(
      children: [
        SwitchListTile(
          activeColor: _primaryColor,
          title: const Text('Adicionar Observações'),
          value: _showNotes[idx],
          onChanged: (v) => setState(() => _showNotes[idx] = v),
        ),
        if (_showNotes[idx])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              controller: _noteCtrls[idx],
              decoration: const InputDecoration(
                  labelText: 'Observações', border: OutlineInputBorder()),
              onChanged: (v) => setState(() => _notes[idx] = v),
            ),
          ),
      ],
    );
  }

  Widget _card(int idx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(descartaveis[idx].name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (_hasError[idx])
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Preencha este item antes de salvar.',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            const SizedBox(height: 8),
            _seletorQuantidade(idx),
            _notaSecao(idx),
          ],
        ),
      ),
    );
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    final sorted = List.generate(descartaveis.length, (i) => i)
      ..sort((a, b) => descartaveis[a].name.compareTo(descartaveis[b].name));

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('Editar Descartáveis • ${widget.comanda.pdv}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _save),
          ],
        ),
        body: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          itemCount: descartaveis.length,
          itemBuilder: (_, i) => _card(sorted[i]),
        ),
      ),
    );
  }
}

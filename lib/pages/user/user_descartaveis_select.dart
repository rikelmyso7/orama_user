// user_descartaveis_select.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/utils/loading_dialog_utils.dart';
import 'package:provider/provider.dart';

import 'package:orama_user/models/descartaveis_model.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/others/descartaveis.dart'; // contém a lista 'descartaveis'

class UserDescartaveisSelect extends StatefulWidget {
  final String pdv;
  final String nome;
  final String data;
  final String userId;
  final String? periodo;

  const UserDescartaveisSelect({
    super.key,
    required this.pdv,
    required this.nome,
    required this.data,
    required this.userId,
    required this.periodo,
  });

  @override
  State<UserDescartaveisSelect> createState() => _UserDescartaveisSelectState();
}

class _UserDescartaveisSelectState extends State<UserDescartaveisSelect> {
  // ---------- listas de estado ----------
  late final List<String> _quantities;
  late final List<String> _notes;
  late final List<bool> _showNotes;
  late final List<bool> _showTextField;
  late final List<TextEditingController> _textControllers;
  late final List<TextEditingController> _noteControllers;
  late final List<FocusNode> _textFocusNodes;
  late final List<bool> _hasError;
  final dataFormat = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());

  // ---------- outros ----------
  late final ScrollController _scrollController;
  final String _dataFormat =
      DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
  static const Color _primaryColor = Color(0xff60C03D);

  // ---------- ciclo de vida ----------
  @override
  void initState() {
    super.initState();
    _initializeLists(descartaveis.length);
    _initializeControllers(descartaveis.length);
    _setupScrollController();
  }

  @override
  void dispose() {
    for (final c in _textControllers) c.dispose();
    for (final c in _noteControllers) c.dispose();
    for (final n in _textFocusNodes) n.dispose();
    _scrollController
      ..removeListener(_dismissKeyboardOnScroll)
      ..dispose();
    super.dispose();
  }

  // ---------- inicializações ----------
  void _initializeLists(int count) {
    _quantities = List.filled(count, '');
    _notes = List.filled(count, '');
    _showNotes = List.filled(count, false);
    _showTextField = List.filled(count, false);
    _hasError = List.filled(count, false);
  }

  void _initializeControllers(int count) {
    _textControllers = List.generate(count, (_) => TextEditingController());
    _noteControllers = List.generate(count, (_) => TextEditingController());
    _textFocusNodes = List.generate(count, (_) => FocusNode());
  }

  void _setupScrollController() {
    _scrollController = ScrollController()
      ..addListener(_dismissKeyboardOnScroll);
  }

  // ---------- helpers ----------
  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  void _dismissKeyboardOnScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.isScrollingNotifier.value) {
      _dismissKeyboard();
    }
  }

  List<String> _quantityOptions(String type) {
    switch (type) {
      case 'numeric':
        return [...List.generate(5, (i) => i.toString()), 'Outro'];
      case 'fractional':
        return ['Vazio', '1/4', '2/4', '3/4', '4/4'];
      case 'text':
        return ['Cheio', 'Pouco', 'Vazio'];
      case 'quantity':
        return [
          ...List.generate(5, (i) => i.toString()),
          'Outro'
        ]; // 0-10 embalagens, por ex.
      default:
        return [];
    }
  }

  String _documentId() => '${widget.nome} - $_dataFormat - ${widget.pdv}';

  Descartaveis _montaRelatorio(List<Map<String, String>> itens) {
    return Descartaveis(
      id: '${widget.nome} - ${dataFormat} - ${widget.pdv}',
      name: widget.nome,
      pdv: widget.pdv,
      userId: widget.userId,
      itens: itens,
      observacoes: [],
      data: DateTime.now(),
      periodo: widget.periodo,
    );
  }

  void _mostrarSnack(String msg, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ---------- salvar ----------
  Future<void> _salvar() async {
    // ───── 1. Validação das quantidades ─────────────────────────────
    bool preenchido = true;
    int firstInvalid = -1;

    for (int i = 0; i < _quantities.length; i++) {
      if (_quantities[i].trim().isEmpty) {
        _hasError[i] = true;
        preenchido = false;
        firstInvalid = firstInvalid == -1 ? i : firstInvalid;
      } else {
        _hasError[i] = false;
      }
    }

    setState(() {}); // força rebuild para exibir erros
    if (!preenchido) {
      _mostrarSnack('Por favor, preencha todos os itens.');
      _scrollController.animateTo(
        firstInvalid * 230.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }

    // ───── 2. Mostra loading ────────────────────────────────────────
    LoadingDialog.show(context);

    try {
      // ───── 3. Monta lista de itens + observações gerais ───────────
      final itens = <Map<String, String>>[];
      for (int i = 0; i < descartaveis.length; i++) {
        itens.add({
          'Item': descartaveis[i].name,
          'Quantidade': _quantities[i],
          'Observacao': _notes[i].trim(),
        });
      }

      // Observações agregadas (compat. telas antigas)
      final observacoesGerais = _notes
          .where((n) => n.trim().isNotEmpty)
          .map((n) => n.trim())
          .toList();

      // ───── 4. Cria relatório ──────────────────────────────────────
      final relatorio = Descartaveis(
        id: '${widget.nome} - $dataFormat - ${widget.pdv}',
        name: widget.nome,
        pdv: widget.pdv,
        userId: widget.userId,
        itens: itens,
        observacoes: observacoesGerais,
        data: DateTime.now(),
        periodo: widget.periodo,
      );

      // ───── 5. Salva via store (offline-ready) ─────────────────────
      await context.read<DescartaveisStore>().addOrUpdateCard(relatorio);

      if (!mounted) return;

      // ───── 6. Fecha o loading e navega ────────────────────────────
      Navigator.of(context)
        ..pop() // fecha o dialog
        ..pushReplacementNamed(RouteName.user_descartaveis_page);
    } catch (e) {
      Navigator.of(context).pop(); // fecha o dialog em caso de erro
      _mostrarSnack('Erro ao salvar: $e');
    }
  }

  // ---------- UI widgets ----------
  Widget _campoQuantidadeTexto(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _textControllers[index],
        keyboardType: descartaveis[index].type == 'numeric'
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: 'Digite a quantidade',
          border: const OutlineInputBorder(),
          suffixIcon: Icon(
            _quantities[index].isNotEmpty ? Icons.check : Icons.close,
            color: _quantities[index].isNotEmpty ? Colors.green : Colors.red,
          ),
        ),
        onChanged: (v) {
          setState(() {
            _quantities[index] = v;
            if (v.trim().isNotEmpty) _hasError[index] = false;
          });
        },
      ),
    );
  }

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
                  _textControllers[index].clear();
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
                  _textControllers[index].clear();
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

  Widget _seletorQuantidade(int index) {
    final op = _quantityOptions(descartaveis[index].type);
    if (op.isEmpty) return _campoQuantidadeTexto(index);

    return Column(
      children: [
        _opcoesRadio(op, index),
        if (_showTextField[index]) _campoQuantidadeTexto(index),
      ],
    );
  }

  Widget _secaoNotas(int index) {
    return Column(
      children: [
        SwitchListTile(
          activeColor: _primaryColor,
          title: const Text('Adicionar Observações'),
          value: _showNotes[index],
          onChanged: (v) => setState(() => _showNotes[index] = v),
        ),
        if (_showNotes[index])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              controller: _noteControllers[index],
              decoration: const InputDecoration(
                labelText: 'Observações',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _notes[index] = v),
            ),
          ),
      ],
    );
  }

  Widget _cardItem(int idx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              descartaveis[idx].name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_hasError[idx])
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Preencha este item antes de salvar.',
                    style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            const SizedBox(height: 8),
            _seletorQuantidade(idx),
            _secaoNotas(idx),
          ],
        ),
      ),
    );
  }

  // ---------- build ----------
  @override
  Widget build(BuildContext context) {
    // ordena alfabeticamente sem alterar a lista original
    final sorted = List.generate(descartaveis.length, (i) => i)
      ..sort((a, b) => descartaveis[a].name.compareTo(descartaveis[b].name));

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text('Descartáveis • ${widget.pdv}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
          actions: [
            IconButton(icon: const Icon(Icons.save), onPressed: _salvar),
          ],
        ),
        body: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: descartaveis.length,
          itemBuilder: (_, i) => _cardItem(sorted[i]),
        ),
      ),
    );
  }
}

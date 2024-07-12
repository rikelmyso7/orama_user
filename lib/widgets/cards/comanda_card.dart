import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/stores/admin/comanda_store.dart';
import 'package:orama_user/widgets/add_sabor_dialog.dart';
import 'package:orama_user/widgets/date_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ComandaCard extends StatefulWidget {
  final Comanda comanda;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<bool> onEditingChanged;

  ComandaCard({
    required this.comanda,
    required this.isSelected,
    required this.onChanged,
    required this.onEditingChanged,
    Key? key,
  }) : super(key: key ?? ValueKey(comanda.id));

  @override
  _ComandaCardState createState() => _ComandaCardState();
}

class _ComandaCardState extends State<ComandaCard> {
  late TextEditingController _pdvController;
  late Map<String, Map<String, Map<String, int>>> _saboresSelecionados;
  bool _isEditing = false;
  late DateTime _selectedDate;

  final List<String> _categorias = ['Ao Leite', 'Veganos', 'Zero Açúcar'];
  final List<String> _opcoes = ['0', '1/4', '2/4', '3/4', '4/4'];

  @override
  void initState() {
    super.initState();
    _pdvController = TextEditingController(text: widget.comanda.pdv);
    _saboresSelecionados = Map.from(widget.comanda.sabores);
    _selectedDate = widget.comanda.data;
  }

  @override
  void dispose() {
    _pdvController.dispose();
    super.dispose();
  }

  void _updateSabor(
      String categoria, String sabor, String opcao, int quantidade) {
    setState(() {
      if (!_saboresSelecionados.containsKey(categoria)) {
        _saboresSelecionados[categoria] = {};
      }
      if (!_saboresSelecionados[categoria]!.containsKey(sabor)) {
        _saboresSelecionados[categoria]![sabor] = {};
      }
      _saboresSelecionados[categoria]![sabor]![opcao] = quantidade;
    });
  }

  void _saveChanges() {
    final comandaStore = Provider.of<ComandaStore>(context, listen: false);
    setState(() {
      widget.comanda.pdv = _pdvController.text;
      widget.comanda.sabores = Map.from(_saboresSelecionados);
      widget.comanda.data = _selectedDate;
      comandaStore.addOrUpdateCard(widget.comanda);
      _isEditing = false;
      widget.onEditingChanged(_isEditing);
    });
  }

  void _copyComanda() {
    final comandaStore = Provider.of<ComandaStore>(context, listen: false);

    // Ensure deep copy with correct typing
    final newSabores = widget.comanda.sabores.map((categoria, sabores) {
      return MapEntry<String, Map<String, Map<String, int>>>(
        categoria,
        sabores.map((sabor, opcoes) {
          return MapEntry<String, Map<String, int>>(
            sabor,
            Map<String, int>.from(opcoes),
          );
        }),
      );
    });

    final newComanda = Comanda(
      id: Uuid().v4(),
      pdv: widget.comanda.pdv,
      sabores: Map<String, Map<String, Map<String, int>>>.from(
          newSabores), // Ensure correct type
      data: DateTime.now(), name: '', userId: '',
    );

    comandaStore.addOrUpdateCard(newComanda);
  }

  void _deleteComanda() {
    final comandaStore = Provider.of<ComandaStore>(context, listen: false);
    final index = comandaStore.comandas.indexOf(widget.comanda);
    if (index != -1) {
      comandaStore.removeComanda(index);
    }
  }

  void _showAddSaborDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddSaborDialog(
          categorias: _categorias,
          opcoes: _opcoes,
          onSaborAdded: (categoria, sabor, opcao, quantidade) {
            _updateSabor(categoria, sabor, opcao, quantidade);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 2,
        child: ExpansionTile(
          title: Text(widget.comanda.pdv),
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildDateRow(),
                  const SizedBox(height: 8.0),
                  ..._buildSaborList(),
                  if (_isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: _showAddSaborDialog,
                        child: const Text(
                          'Adicionar Sabor',
                          style: TextStyle(color: Color(0xff60C03D)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _isEditing
            ? Expanded(
                child: TextField(
                  controller: _pdvController,
                  decoration: const InputDecoration(labelText: "PDV"),
                ),
              )
            : Text(
                widget.comanda.pdv,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
        Row(
          children: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveChanges,
              )
            else
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteComanda,
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyComanda,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        _isEditing
            ? DatePickerWidget(
                initialDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              )
            : Text(DateFormat('dd/MM/yyyy').format(widget.comanda.data)),
      ],
    );
  }

  List<Widget> _buildSaborList() {
    return _saboresSelecionados.entries.expand((categoria) {
      return categoria.value.entries.map((saborEntry) {
        final opcoesValidas = saborEntry.value.entries
            .where((quantidadeEntry) => quantidadeEntry.value > 0)
            .toList();

        if (opcoesValidas.isEmpty) {
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(saborEntry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _saboresSelecionados[categoria.key]!
                            .remove(saborEntry.key);
                        if (_saboresSelecionados[categoria.key]!.isEmpty) {
                          _saboresSelecionados.remove(categoria.key);
                        }
                      });
                    },
                  ),
              ],
            ),
            ...opcoesValidas.map((quantidadeEntry) {
              return Row(
                children: [
                  Text(
                      "- ${quantidadeEntry.value} Cuba ${quantidadeEntry.key}"),
                  if (_isEditing)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _updateSabor(categoria.key, saborEntry.key,
                                quantidadeEntry.key, quantidadeEntry.value + 1);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            _updateSabor(categoria.key, saborEntry.key,
                                quantidadeEntry.key, quantidadeEntry.value - 1);
                          },
                        ),
                      ],
                    ),
                ],
              );
            }).toList(),
          ],
        );
      }).toList();
    }).toList();
  }
}

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/widgets/add_sabor_dialog.dart';
import 'package:orama_user/widgets/date_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CopiedComandaCard extends StatefulWidget {
  final Comanda2 comanda;

  CopiedComandaCard({
    required this.comanda,
    Key? key,
  }) : super(key: key ?? ValueKey(comanda.id));

  @override
  _CopiedComandaCardState createState() => _CopiedComandaCardState();
}

class _CopiedComandaCardState extends State<CopiedComandaCard> {
  late TextEditingController _nameController;
  late Map<String, Map<String, Map<String, int>>> _saboresSelecionados;
  bool _isEditing = false;
  late DateTime _selectedDate;

  final List<String> _categorias = ['Ao Leite', 'Veganos', 'Zero Açúcar'];
  final List<String> _opcoes = ['0', '1/4', '2/4', '3/4', '4/4'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.comanda.pdv);
    _saboresSelecionados = Map.from(widget.comanda.sabores);
    _selectedDate = widget.comanda.data;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
    final comandaStore = Provider.of<UserComandaStore>(context, listen: false);
    setState(() {
      widget.comanda.name = _nameController.text;
      widget.comanda.sabores = Map.from(_saboresSelecionados);
      widget.comanda.data = _selectedDate;
      comandaStore.addOrUpdateCardStorage(widget.comanda);
      _isEditing = false;
    });
  }

  void _copyComanda() {
    final comandaStore = Provider.of<UserComandaStore>(context, listen: false);

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

    final newComanda = Comanda2(
      name: '',
      id: Uuid().v4(),
      pdv: widget.comanda.pdv,
      sabores: Map<String, Map<String, Map<String, int>>>.from(
          newSabores), // Ensure correct type
      data: DateTime.now(), userId: GetStorage().read('userId'),
    );

    comandaStore.addOrUpdateCardStorage(newComanda);
  }

  void _deleteComandaStorage() {
    final comandaStore = Provider.of<UserComandaStore>(context, listen: false);
    final index = comandaStore.comandas.indexOf(widget.comanda);
    if (index != -1) {
      comandaStore.removeComandaStorage(index);
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
                  controller: _nameController,
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
              onPressed: _deleteComandaStorage,
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

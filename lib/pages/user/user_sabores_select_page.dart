import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/models/comanda_model.dart';
import 'package:orama_user/others/sabores.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/stores/user_sabor_store.dart';
import 'package:orama_user/utils/loading_dialog_utils.dart';
import 'package:orama_user/utils/scroll_hide_fab.dart';
import 'package:orama_user/widgets/sabor_tile_user.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UserSaboresSelectPage extends StatefulWidget {
  final String pdv;
  final String? periodo;
  final String nome;
  final String data;
  final String userId;
  final String? caixaInicial;
  final String? caixaFinal;
  final String? pixInicial;
  final String? pixFinal;

  UserSaboresSelectPage({
    required this.pdv,
    required this.nome,
    required this.data,
    required this.userId,
    this.caixaInicial,
    this.caixaFinal,
    this.pixInicial,
    this.pixFinal,
    required this.periodo,
  });

  @override
  _SaboresSelectPageState createState() => _SaboresSelectPageState();
}

class _SaboresSelectPageState extends State<UserSaboresSelectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  final dataFormat = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sabores.keys.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    final tabViewState = Provider.of<UserSaborStore>(context, listen: false);
    _tabController.index = tabViewState.currentIndex;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    Provider.of<UserSaborStore>(context, listen: false)
        .setCurrentIndex(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    final comandaStore = Provider.of<UserComandaStore>(context);
    final tabViewState = Provider.of<UserSaborStore>(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          tabViewState.resetExpansionState();
          tabViewState.resetSaborTabView();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("${widget.nome} - ${widget.pdv}",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          elevation: 4,
          backgroundColor: const Color(0xff60C03D),
          scrolledUnderElevation: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            indicatorColor: Colors.amber,
            controller: _tabController,
            tabs: sabores.keys.map((String key) {
              return Tab(text: key);
            }).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: sabores.keys.map((String key) {
            final sortedSabores = List.from(sabores[key]!)
              ..sort((a, b) => a.compareTo(b));
            return ListView(
              controller: _scrollController,
              children: sortedSabores.map((sabor) {
                return UserSaborTile(
                  sabor: sabor,
                  categoria: key,
                );
              }).toList(),
            );
          }).toList(),
        ),
        floatingActionButton: ScrollHideFab(
          scrollController: _scrollController,
          child: FloatingActionButton(
            backgroundColor: const Color(0xff60C03D),
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: () {
              if (tabViewState.saboresSelecionados.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Selecione pelo menos um sabor.')),
                );
                return;
              }
              comandaStore.addOrUpdateCard(
                Comanda2(
                  name: widget.nome,
                  pdv: widget.pdv,
                  sabores: tabViewState.saboresSelecionados.map((key, value) =>
                      MapEntry(key, Map<String, Map<String, int>>.from(value))),
                  data: DateTime.now(),
                  id: '${widget.nome} - ${dataFormat} - ${widget.pdv}',
                  userId: GetStorage().read('userId'),
                  caixaInicial: widget.caixaInicial,
                  caixaFinal: widget.caixaFinal,
                  pixInicial: widget.pixInicial,
                  pixFinal: widget.pixFinal,
                  periodo: widget.periodo,
                ),
              );
              LoadingDialog.show(context);
              try {
                if (!mounted) return;
                tabViewState.resetExpansionState();
                tabViewState.resetSaborTabView();
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteName.user_comandas_page,
                  (route) => false,
                );
              } catch (e) {
                

                Navigator.of(context).pop(); // Fecha o dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Erro ao salvar: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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
import 'package:mobx/mobx.dart';

class UserSaboresEditPage extends StatefulWidget {
  final Comanda2 comanda;

  UserSaboresEditPage({required this.comanda});

  @override
  _UserSaboresEditPageState createState() => _UserSaboresEditPageState();
}

class _UserSaboresEditPageState extends State<UserSaboresEditPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: sabores.keys.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    final tabViewState = Provider.of<UserSaborStore>(context, listen: false);
    _tabController.index = tabViewState.currentIndex;
    _scrollController = ScrollController();

    // Preencher sabores selecionados a partir da comanda atual
    tabViewState.saboresSelecionados =
        ObservableMap<String, ObservableMap<String, Map<String, int>>>.of(
            widget.comanda.sabores.map((key, value) => MapEntry(
                key, ObservableMap<String, Map<String, int>>.of(value))));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<UserComandaStore>();
      store.syncPendingComandas(); // envia comandos pendentes, se houver
    });
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

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Editar Sabores - ${widget.comanda.pdv}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
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
            // Atualizar sabores na comanda
            widget.comanda.sabores = tabViewState.saboresSelecionados.map(
                (key, value) => MapEntry(
                    key,
                    Map<String, Map<String, int>>.from(value.map(
                        (saborKey, saborValue) => MapEntry(
                            saborKey, Map<String, int>.from(saborValue))))));
            LoadingDialog.show(context);
            // Salvar comanda atualizada
            try {
              comandaStore.addOrUpdateCard(widget.comanda);
              if (!mounted) return;
              Navigator.of(context).pop();
              // Resetar o estado do UserSaborStore
              tabViewState.resetExpansionState();
              tabViewState.resetSaborTabView();

              // Navegar de volta para user_comandas_page
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
    );
  }
}

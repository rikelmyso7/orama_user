import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/others/sabores.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/scroll_hide_fab.dart';
import 'package:orama_user/widgets/sabor_tile_user.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UserSaboresPage extends StatefulWidget {
  final String pdv;
  final String nome;
  final String data;
  final String userId;

  UserSaboresPage({required this.pdv, required this.nome, required this.data, required this.userId});

  @override
  _SaboresPageState createState() => _SaboresPageState();
}

class _SaboresPageState extends State<UserSaboresPage>
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
              comandaStore.addOrUpdateCard(
                Comanda2(
                    name: widget.nome,
                    pdv: widget.pdv,
                    sabores: tabViewState.saboresSelecionados.map(
                        (key, value) => MapEntry(
                            key, Map<String, Map<String, int>>.from(value))),
                    data: DateTime.now(),
                    id: Uuid().v4(),
                    userId: GetStorage().read('userId')),
              );
              Navigator.pushNamed(context, RouteName.user_comandas_page);
            },
          ),
        ),
      ),
    );
  }
}

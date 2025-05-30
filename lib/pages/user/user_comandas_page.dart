import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/pages/user/user_descartaveis_page.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/exit_dialog_utils.dart';
import 'package:orama_user/utils/scroll_hide_fab.dart';
import 'package:orama_user/widgets/UserBottomNavigationbar.dart';
import 'package:orama_user/widgets/cards/user_comanda_card.dart';
import 'package:orama_user/widgets/date_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class UserComandasPage extends StatefulWidget {
  @override
  _UserComandasPageState createState() => _UserComandasPageState();
}

class _UserComandasPageState extends State<UserComandasPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late ScrollController _scrollController;
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now(); // Add this for date selection

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
    final tabViewState = Provider.of<UserSaborStore>(context, listen: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDescartaveisPage()),
      );
    } else if (index == 0) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  List<Comanda2> filterComandasByPeriodo(
      List<Comanda2> comandas, String periodo) {
    return comandas.where((comanda) {
      return comanda.name.contains("($periodo)");
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userId = GetStorage().read('userId');
    final tabViewState = Provider.of<UserSaborStore>(context);
    final dateFormatted = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final store = Provider.of<UserComandaStore>(context);

    return Scaffold(
      bottomNavigationBar: UserBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: onTabTapped,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Relatório Sorvetes",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        elevation: 4,
        backgroundColor: const Color(0xff60C03D),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(RouteName.login);
            },
          ),
        ],
        bottom: TabBar(
          labelColor: Colors.white,
          indicatorColor: Colors.amber,
          controller: _tabController,
          tabs: [
            Tab(text: "INICIO"),
            Tab(text: "FINAL"),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                ),
                onPressed: () => _changeDate(-1),
              ),
              DatePickerWidget(
                key: UniqueKey(),
                initialDate: _selectedDate,
                onDateSelected: (newDate) {
                  _updateSelectedDate(newDate);
                },
                dateFormat: DateFormat('dd MMMM yyyy', 'pt_BR'),
                textStyle: const TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                final firebaseComandas =
                    store.getComandasForSelectedDay(_selectedDate);

                // 🔸 Recupera as comandas pendentes do GetStorage
                final List<dynamic> pendentesRaw =
                    GetStorage().read('comandasPendentes') ?? [];
                final List<Comanda2> comandasPendentes = pendentesRaw
                    .map((e) => Comanda2.fromJson(Map<String, dynamic>.from(e)))
                    .where((c) =>
                        c.data ==
                        DateFormat('yyyy-MM-dd').format(_selectedDate))
                    .toList();

                // 🔸 Combina as duas listas
                final todasComandas = [
                  ...firebaseComandas,
                  ...comandasPendentes
                ];

                if (todasComandas.isEmpty) {
                  return Center(child: Text("Nenhuma comanda disponível."));
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          filterComandasByPeriodo(todasComandas, "INICIO")
                              .length,
                      itemBuilder: (context, index) {
                        final comanda = filterComandasByPeriodo(
                            todasComandas, "INICIO")[index];
                        return UserComandaCard(comanda: comanda);
                      },
                    ),
                    ListView.builder(
                      controller: _scrollController,
                      itemCount: filterComandasByPeriodo(todasComandas, "FINAL")
                          .length,
                      itemBuilder: (context, index) {
                        final comanda = filterComandasByPeriodo(
                            todasComandas, "FINAL")[index];
                        return UserComandaCard(comanda: comanda);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ScrollHideFab(
        scrollController: _scrollController,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xff60C03D),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          label: Text(
            'add',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            tabViewState.resetExpansionState();
            tabViewState.resetSaborTabView();
            Navigator.pushNamed(context, RouteName.user_add_sorvetes);
          },
        ),
      ),
    );
  }
}

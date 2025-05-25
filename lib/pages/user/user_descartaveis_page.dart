import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/exit_dialog_utils.dart';
import 'package:orama_user/utils/scroll_hide_fab.dart';
import 'package:orama_user/widgets/UserBottomNavigationbar.dart';
import 'package:orama_user/widgets/cards/user_descartavel_card.dart';
import 'package:orama_user/widgets/date_picker_widget.dart';

class UserDescartaveisPage extends StatefulWidget {
  @override
  _UserDescartaveisPageState createState() => _UserDescartaveisPageState();
}

class _UserDescartaveisPageState extends State<UserDescartaveisPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late ScrollController _scrollController;
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteName.user_comandas_page);
    } else if (index == 1) {
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

  List<ComandaDescartaveis> filterComandasByPeriodo(
      List<ComandaDescartaveis> comandas, String periodo) {
    return comandas.where((comanda) {
      return comanda.name.contains("($periodo)");
    }).toList();
  }

  Future<void> limparRelatoriosNulos(String userId) async {
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('descartaveis');

    final snapshot = await ref.get();
    for (final doc in snapshot.docs) {
      final data = doc.data();

      final isInvalido = data['name'] == null ||
          data['pdv'] == null ||
          data['userId'] == null ||
          data['itens'] == null ||
          data['data'] == null;

      if (isInvalido) {
        print('Removendo relatório inválido: ${doc.id}');
        await doc.reference.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = GetStorage().read('userId');
    final dateFormatted = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Scaffold(
      bottomNavigationBar: UserBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabTapped: onTabTapped,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Relatório Descartáveis",
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
          // IconButton(
          //   icon: Icon(Icons.sync),
          //   onPressed: () async {
          //     await limparRelatoriosNulos(userId);
          //     Navigator.of(context).pushReplacementNamed(RouteName.login);
          //   },
          // )
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('descartaveis')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Erro ao carregar relatórios"));
                }

                final comandas = snapshot.data?.docs
                        .map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          if (data['name'] == null ||
                              data['pdv'] == null ||
                              data['userId'] == null ||
                              data['itens'] == null ||
                              data['data'] == null) {
                            return null;
                          }

                          try {
                            DateTime comandaDate;
                            if (data['data'] is Timestamp) {
                              comandaDate =
                                  (data['data'] as Timestamp).toDate();
                            } else if (data['data'] is String) {
                              comandaDate = DateTime.parse(data['data']);
                            } else {
                              return null;
                            }

                            return ComandaDescartaveis.fromJson(data)
                              ..data = comandaDate;
                          } catch (e) {
                            return null;
                          }
                        })
                        .where((comanda) {
                          if (comanda == null) return false;
                          final comandaDate = comanda.data;
                          return comandaDate.year == _selectedDate.year &&
                              comandaDate.month == _selectedDate.month &&
                              comandaDate.day == _selectedDate.day;
                        })
                        .cast<ComandaDescartaveis>()
                        .toList() ??
                    [];

                if (comandas.isEmpty) {
                  return Center(child: Text("Nenhum relatório disponível."));
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          filterComandasByPeriodo(comandas, "INICIO").length,
                      itemBuilder: (context, index) {
                        final comanda =
                            filterComandasByPeriodo(comandas, "INICIO")[index];
                        return UserDescartavelCard(comanda: comanda);
                      },
                    ),
                    ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          filterComandasByPeriodo(comandas, "FINAL").length,
                      itemBuilder: (context, index) {
                        final comanda =
                            filterComandasByPeriodo(comandas, "FINAL")[index];
                        return UserDescartavelCard(comanda: comanda);
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
            Navigator.pushNamed(context, RouteName.user_add_descartaveis);
          },
        ),
      ),
    );
  }
}

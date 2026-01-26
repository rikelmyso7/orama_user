import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:orama_user/models/descartaveis_model.dart';
import 'package:orama_user/pages/user/user_comandas_page.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/descartaveis_store.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/stores/user_sabor_store.dart';
import 'package:orama_user/utils/exit_dialog_utils.dart';
import 'package:orama_user/utils/scroll_hide_fab.dart';
import 'package:orama_user/widgets/UserBottomNavigationbar.dart';
import 'package:orama_user/widgets/cards/user_descartavel_card.dart';
import 'package:orama_user/widgets/date_picker_widget.dart';
import 'package:provider/provider.dart';

class UserDescartaveisPage extends StatefulWidget {
  @override
  _UserDescartaveisPageState createState() => _UserDescartaveisPageState();
}

class _UserDescartaveisPageState extends State<UserDescartaveisPage>
    with SingleTickerProviderStateMixin {
  static const int _descartaveisTabIndex = 1;
  static const int _comandasTabIndex = 0;

  late final ScrollController _scrollController;
  late final TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);

    // Carrega dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = Provider.of<DescartaveisStore>(context, listen: false);
      store.setSelectedDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _comandasTabIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserComandasPage()),
      );
    }
  }

  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });

    final store = Provider.of<DescartaveisStore>(context, listen: false);
    store.setSelectedDate(newDate);
  }

  void _changeDate(int days) {
    _updateSelectedDate(_selectedDate.add(Duration(days: days)));
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(RouteName.login);
      }
    } catch (e) {
      // Handle logout error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DescartaveisStore>(context);

    return Scaffold(
      bottomNavigationBar: UserBottomNavigationBar(
        currentIndex: _descartaveisTabIndex,
        onTabTapped: _onTabTapped,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Relatório Descartaveis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        elevation: 4,
        backgroundColor: const Color(0xff60C03D),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          labelColor: Colors.white,
          indicatorColor: Colors.amber,
          controller: _tabController,
          tabs: const [
            Tab(text: "INÍCIO"),
            Tab(text: "FINAL"),
          ],
        ),
      ),
      body: Observer(builder: (context) {
        return Column(
          children: [
            _buildDateSelector(),
            Expanded(child: _buildTabBarView(store)),
          ],
        );
      }),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _changeDate(-1),
          ),
          DatePickerWidget(
            key: ValueKey(_selectedDate),
            initialDate: _selectedDate,
            onDateSelected: _updateSelectedDate,
            dateFormat: DateFormat('dd MMMM yyyy', 'pt_BR'),
            textStyle: const TextStyle(fontSize: 18),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView(DescartaveisStore store) {
    return TabBarView(
      controller: _tabController,
      children: [
        Observer(builder: (_) {
          return _buildComandaList(
              store.getDescartaveisByPeriodo(_selectedDate, 'INICIO'));
        }),
        Observer(builder: (_) {
          return _buildComandaList(
              store.getDescartaveisByPeriodo(_selectedDate, 'FINAL'));
        }),
      ],
    );
  }

  Widget _buildComandaList(List<Descartaveis> comandas) {
    return Observer(builder: (context) {
      print('📋 Exibindo ${comandas.length} comandas na interface');
      if (comandas.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.library_books_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Nenhum Relatório disponível",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        key: ValueKey(comandas.length),
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: comandas.length,
        itemBuilder: (context, index) {
          return UserDescartavelCard(comanda: comandas[index]);
        },
      );
    });
  }

  Widget _buildFloatingActionButton() {
    return ScrollHideFab(
      scrollController: _scrollController,
      child: FloatingActionButton.extended(
        backgroundColor: const Color(0xff60C03D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Adicionar',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          Navigator.pushNamed(context, RouteName.user_add_descartaveis);
        },
      ),
    );
  }
}

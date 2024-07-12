import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:orama_user/pages/user/user_descartaveis_page.dart';
import 'package:orama_user/routes/routes.dart';
import 'package:orama_user/stores/user/user_comanda_store.dart';
import 'package:orama_user/utils/exit_dialog_utils.dart';
import 'package:orama_user/utils/scroll_hide_fab.dart';
import 'package:orama_user/widgets/UserBottomNavigationbar.dart';
import 'package:orama_user/widgets/cards/user_comanda_card.dart';
import 'package:provider/provider.dart';

class UserComandasPage extends StatefulWidget {
  @override
  _UserComandasPageState createState() => _UserComandasPageState();
}

class _UserComandasPageState extends State<UserComandasPage> {
  int _currentIndex = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final tabViewState = Provider.of<UserSaborStore>(context, listen: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final userId = GetStorage().read('userId');
    final tabViewState = Provider.of<UserSaborStore>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final bool shouldPop =
            await DialogUtils.showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        bottomNavigationBar: UserBottomNavigationBar(
          currentIndex: _currentIndex,
          onTabTapped: onTabTapped,
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Relatório Sorvetes",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
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
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('comandas')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Erro ao carregar comandas"));
            }

            final comandas = snapshot.data?.docs.map((doc) {
                  return Comanda2.fromJson(doc.data() as Map<String, dynamic>);
                }).toList() ??
                [];

            if (comandas.isEmpty) {
              return Center(child: Text("Nenhuma comanda disponível."));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: comandas.length,
                itemBuilder: (context, index) {
                  final comanda = comandas[index];
                  return UserComandaCard(comanda: comanda);
                },
              ),
            );
          },
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
      ),
    );
  }
}

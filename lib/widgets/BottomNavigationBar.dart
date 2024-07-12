import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;

  CustomBottomNavigationBar(
      {required this.currentIndex, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 4,
      selectedItemColor: const Color(0xff60C03D),
      unselectedItemColor: Colors.grey,
      unselectedLabelStyle: TextStyle(color: Colors.grey),
      showUnselectedLabels: true,
      onTap: onTabTapped,
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'PDV'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart), label: 'Estoque'),
        BottomNavigationBarItem(
            icon: Icon(Icons.icecream), label: 'Relatórios'),
        BottomNavigationBarItem(
            icon: Icon(Icons.recycling), label: 'Descartaveis'),
      ],
    );
  }
}

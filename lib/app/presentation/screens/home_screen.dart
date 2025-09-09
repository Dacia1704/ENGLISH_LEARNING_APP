import 'package:english_learning_app/app/presentation/screens/add_screen.dart';
import 'package:english_learning_app/app/presentation/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'manage_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // mở mặc định tab Manage

  final List<Widget> _pages = const [
    AddScreen(),
    ManageScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.lightGreen, // màu nền thanh tab
        selectedItemColor: Colors.white, // màu icon + text khi chọn
        unselectedItemColor: Colors.white70, // màu icon + text khi chưa chọn
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "add".tr()),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "manage".tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "setting".tr(),
          ),
        ],
      ),
    );
  }
}

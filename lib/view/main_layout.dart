import 'package:flutter/material.dart';
import '../model/user_model.dart';
import 'scan_view.dart';
import 'home_view.dart';
import 'profile_view.dart';

class MainLayout extends StatefulWidget {
  final UserModel user;

  const MainLayout({Key? key, required this.user}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _onProfileSaved() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeView(user: widget.user),
      ProfileView(user: widget.user, onSave: _onProfileSaved),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(child: pages[_selectedIndex]),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[600],
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanView(user: widget.user)),
          );
        },
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, 'Beranda', 0),
              const SizedBox(width: 48),
              _buildNavItem(Icons.person, 'Profil', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.teal[600] : Colors.grey[400]),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.teal[600] : Colors.grey[400],
            ),
          )
        ],
      ),
    );
  }
}
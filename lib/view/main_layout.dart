import 'package:flutter/material.dart';
import '../model/user_model.dart';
import 'scan_view.dart';

class MainLayout extends StatefulWidget {
  final UserModel user; // Menerima data dari Wizard

  const MainLayout({Key? key, required this.user}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Tampilan dinamis berdasarkan tab yang dipilih
    final List<Widget> pages = [
      Center(child: Text('Halo, ${widget.user.name.isEmpty ? "Pengguna" : widget.user.name}\nSelamat datang di Beranda!')),
      const Center(child: Text('Halaman Riwayat')),
      Center(child: Text('Alergi Anda: ${widget.user.allergies.join(", ")}')), // Contoh panggil data di Profil
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('NutriScan'), backgroundColor: Colors.teal[700]),
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
        onPressed: () {
          // Buka halaman kamera tanpa GetX
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanView()));
        },
        child: const Icon(Icons.document_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.teal[700],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
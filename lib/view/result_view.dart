// result_view.dart
import 'package:flutter/material.dart';

class ResultView extends StatelessWidget {
  const ResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        backgroundColor: Colors.teal[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu Nutrient Level
          Card(
            color: Colors.green[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text('Skor Nutrisi', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('A (Sangat Sehat)', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Kartu Alergen
          Card(
            color: Colors.red[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Peringatan Alergen!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        Text('Produk ini mengandung Kacang (Sesuai profil alergi Anda).', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
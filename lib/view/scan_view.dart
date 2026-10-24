import 'package:flutter/material.dart';
import 'result_view.dart';

class ScanView extends StatelessWidget {
  const ScanView({Key? key}) : super(key: key);

  void _simulateScan(BuildContext context) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    await Future.delayed(const Duration(seconds: 2));
    
    // Tutup dialog
    Navigator.pop(context); 
    
    // Pindah ke Halaman Hasil
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const ResultView())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Pindai Produk'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => _simulateScan(context), // Perlu kirim context ke fungsi
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal,
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
        ),
      ),
    );
  }
}
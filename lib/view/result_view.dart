import 'package:flutter/material.dart';
import '../model/user_model.dart';

class ResultView extends StatelessWidget {
  final UserModel user;

  const ResultView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasAllergy = user.allergies.isNotEmpty;
    String detectedAllergy = hasAllergy ? user.allergies.first : '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Hasil Pemindaian', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text('TINGKAT KESEHATAN PRODUK', 
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400])),
                      const SizedBox(height: 16),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.yellow[500],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.yellow.shade100, width: 6),
                          boxShadow: [
                            BoxShadow(color: Colors.yellow.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                          ]
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Skor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 48, height: 1.0)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Kualitas Sedang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: hasAllergy ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: hasAllergy ? Colors.red.shade200 : Colors.green.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: hasAllergy ? Colors.red[500] : Colors.green[500],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(hasAllergy ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hasAllergy ? 'PERINGATAN ALERGEN!' : 'AMAN DIKONSUMSI', 
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: hasAllergy ? Colors.red[800] : Colors.green[800])),
                            const SizedBox(height: 4),
                            Text(hasAllergy 
                                ? 'Mengandung bahan yang harus Anda hindari:' 
                                : 'Tidak terdeteksi bahan yang bertentangan dengan profil Anda.', 
                                style: TextStyle(fontSize: 14, color: hasAllergy ? Colors.red[700] : Colors.green[700])),
                            
                            if (hasAllergy) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(detectedAllergy, style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold)),
                              )
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.teal[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Selesai & Kembali', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
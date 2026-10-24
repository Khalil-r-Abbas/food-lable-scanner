import 'package:flutter/material.dart';
import 'dart:math';
import '../model/user_model.dart';
import 'scan_view.dart';

class HomeView extends StatelessWidget {
  final UserModel user;

  const HomeView({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Perhitungan BMI
    double bmi = 0;
    String bmiStatus = '--';
    Color? bmiColor = Colors.teal[600];
    Color? bmiBgColor = Colors.teal[50];

    if (user.height.isNotEmpty && user.weight.isNotEmpty) {
      double h = double.tryParse(user.height) ?? 0;
      double w = double.tryParse(user.weight) ?? 0;
      if (h > 0 && w > 0) {
        bmi = w / pow(h / 100, 2);
        if (bmi < 18.5) {
          bmiStatus = 'Kurang';
          bmiColor = Colors.orange[700];
          bmiBgColor = Colors.orange[50];
        } else if (bmi <= 25) {
          bmiStatus = 'Normal';
          bmiColor = Colors.teal[600];
          bmiBgColor = Colors.teal[50];
        } else {
          bmiStatus = 'Berlebih';
          bmiColor = Colors.red[600];
          bmiBgColor = Colors.red[50];
        }
      }
    }

    String displayName = user.name.isEmpty ? 'Pengguna' : user.name;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Teal
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white24,
                  backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=$displayName&background=ffffff&color=0f766e'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selamat datang,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('Halo, $displayName!',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kartu BMI
                // Container(
                //   padding: const EdgeInsets.all(20),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(color: Colors.grey.shade200),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           const Text('INDEKS MASSA TUBUH (IMT)',
                //               style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                //           const SizedBox(height: 8),
                //           Row(
                //             crossAxisAlignment: CrossAxisAlignment.baseline,
                //             textBaseline: TextBaseline.alphabetic,
                //             children: [
                //               Text(bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                //                   style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                //               const SizedBox(width: 8),
                //               Container(
                //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //                 decoration: BoxDecoration(
                //                   color: bmiBgColor,
                //                   borderRadius: BorderRadius.circular(6),
                //                 ),
                //                 child: Text(bmiStatus,
                //                     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: bmiColor)),
                //               )
                //             ],
                //           )
                //         ],
                //       ),
                //       Icon(Icons.favorite, color: Colors.grey[300], size: 40),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 24),
                const Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>  ScanView(user: user,))),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.teal[800],
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        const Text('Mulai Pindai',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Analisis nilai gizi & komposisi dengan AI',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
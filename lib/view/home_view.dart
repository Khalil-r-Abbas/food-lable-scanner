import 'package:flutter/material.dart';
import 'dart:math';
import '../model/user_model.dart';
import '../data/services/storage_service.dart';
import 'scan_view.dart';
import 'result_view.dart';

class HomeView extends StatefulWidget {
  final UserModel user;

  const HomeView({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<ScanResultModel> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await StorageService.loadHistory();
    if (mounted) {
      setState(() => _history = list);
    }
  }

  Color _badgeColor(String light) {
    if (light == 'GREEN') return Colors.green;
    if (light == 'RED') return Colors.red;
    return Colors.amber[700]!;
  }

  @override
  Widget build(BuildContext context) {
    double bmi = 0;
    String bmiStatus = '--';
    Color? bmiColor = Colors.teal[600];

    if (widget.user.height.isNotEmpty && widget.user.weight.isNotEmpty) {
      double h = double.tryParse(widget.user.height) ?? 0;
      double w = double.tryParse(widget.user.weight) ?? 0;
      if (h > 0 && w > 0) {
        bmi = w / pow(h / 100, 2);
        if (bmi < 18.5) {
          bmiStatus = 'Underweight';
          bmiColor = Colors.orange[700];
        } else if (bmi <= 25) {
          bmiStatus = 'Normal';
          bmiColor = Colors.teal[600];
        } else {
          bmiStatus = 'Overweight';
          bmiColor = Colors.red[600];
        }
      }
    }

    String displayName = widget.user.name.isEmpty ? 'User' : widget.user.name;

    return SingleChildScrollView(
      child: Column(
        children: [
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
                      Text('Standard: ${widget.user.country}',
                          style: const TextStyle(color: Colors.tealAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Hello, $displayName!',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (bmi > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('BMI ${bmi.toStringAsFixed(1)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: bmiColor)),
                        Text(bmiStatus, style: TextStyle(fontSize: 10, color: bmiColor)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanView(user: widget.user)),
                    );
                    _loadHistory(); // Refresh riwayat setelah kembali dari scan
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.teal[800],
                      borderRadius: BorderRadius.circular(28),
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
                        const SizedBox(height: 12),
                        const Text('Scan Food Label',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Camera or Gallery • Personalized AI + Deterministic Check',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Scan History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (_history.isNotEmpty)
                      TextButton(
                        onPressed: () async {
                          await StorageService.clearHistory();
                          _loadHistory();
                        },
                        child: const Text('Clear', style: TextStyle(fontSize: 12, color: Colors.red)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_history.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(
                      child: Text('No scanned products yet. Tap "Scan Food Label" above!',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  )
                else
                  ..._history.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultView(user: widget.user, result: item),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _badgeColor(item.trafficLight),
                            child: Text(item.scoreGrade,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(item.productName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                            'Sugar: ${item.sugarG}g • Sodium: ${item.sodiumMg.toStringAsFixed(0)}mg',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
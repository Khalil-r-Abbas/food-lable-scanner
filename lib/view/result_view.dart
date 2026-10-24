import 'package:flutter/material.dart';
import '../model/user_model.dart';

class ResultView extends StatefulWidget {
  final UserModel user;
  final String? imagePath;
  final ScanResultModel result;

  const ResultView({
    Key? key,
    required this.user,
    this.imagePath,
    required this.result,
  }) : super(key: key);

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  bool _isPerContainer = false; // Toggle Per Sajian vs Per Kemasan

  Color _getTrafficColor(String light) {
    switch (light) {
      case 'GREEN':
        return Colors.green[600]!;
      case 'RED':
        return Colors.red[600]!;
      default:
        return Colors.amber[700]!;
    }
  }

  String _getTrafficLabel(String light) {
    switch (light) {
      case 'GREEN':
        return 'SAFE / HEALTHY CHOICE';
      case 'RED':
        return 'HIGH RISK / AVOID';
      default:
        return 'MODERATE / CONSUME CAREFULLY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;
    final double multiplier = _isPerContainer ? res.servingsPerContainer : 1.0;
    final bool hasAllergyRisk = res.matchedUserAllergies.isNotEmpty;
    final Color badgeColor = _getTrafficColor(res.trafficLight);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          res.productName,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. KARTU SKOR & TRAFFIC LIGHT DETERMINISTIK
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'STANDARD: ${widget.user.country.toUpperCase()}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Confidence: ${(res.confidence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: badgeColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('GRADE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
                            Text(
                              res.scoreGrade,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 44, height: 1.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getTrafficLabel(res.trafficLight),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: badgeColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        res.summary,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. PERINGATAN ALERGEN & DIET (HALAL/VEGAN)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (hasAllergyRisk || !res.isDietCompliant) ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (hasAllergyRisk || !res.isDietCompliant) ? Colors.red.shade200 : Colors.green.shade200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        (hasAllergyRisk || !res.isDietCompliant) ? Icons.warning_amber_rounded : Icons.verified_user,
                        color: (hasAllergyRisk || !res.isDietCompliant) ? Colors.red[700] : Colors.green[700],
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasAllergyRisk
                                  ? 'ALLERGEN ALERT DETECTED!'
                                  : (!res.isDietCompliant ? 'DIET PREFERENCE WARNING!' : 'SAFE FOR YOUR PROFILE'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: (hasAllergyRisk || !res.isDietCompliant) ? Colors.red[800] : Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (hasAllergyRisk)
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: res.matchedUserAllergies
                                    .map((a) => Chip(
                                          label: Text(a, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                          backgroundColor: Colors.red[600],
                                          visualDensity: VisualDensity.compact,
                                        ))
                                    .toList(),
                              )
                            else
                              Text(
                                res.dietNote.isNotEmpty
                                    ? res.dietNote
                                    : 'No conflicting allergens or restricted diet ingredients found.',
                                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. TOGGLE PER SAJIAN VS PER KEMASAN & BATAS HARIAN DART
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'DAILY LIMIT IMPACT',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ToggleButtons(
                            isSelected: [!_isPerContainer, _isPerContainer],
                            onPressed: (idx) => setState(() => _isPerContainer = idx == 1),
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: Colors.teal[600],
                            constraints: const BoxConstraints(minHeight: 30, minWidth: 72),
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text('Serving', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text('Pack (${res.servingsPerContainer.toStringAsFixed(0)}x)',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildNutrientRow(
                        'Sugar',
                        '${(res.sugarG * multiplier).toStringAsFixed(1)} g',
                        res.sugarDailyPct * multiplier,
                      ),
                      const SizedBox(height: 12),
                      _buildNutrientRow(
                        'Sodium (Salt)',
                        '${(res.sodiumMg * multiplier).toStringAsFixed(0)} mg',
                        res.sodiumDailyPct * multiplier,
                      ),
                      const SizedBox(height: 12),
                      _buildNutrientRow(
                        'Saturated Fat',
                        '${(res.saturatedFatG * multiplier).toStringAsFixed(1)} g',
                        res.satFatDailyPct * multiplier,
                      ),
                    ],
                  ),
                ),

                // 4. HIDDEN INGREDIENTS (GULA / GARAM TERSEMBUNYI)
                if (res.hiddenIngredients.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.search_rounded, color: Colors.orange[800], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'HIDDEN INGREDIENTS DETECTED',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange[900]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...res.hiddenIngredients.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text('• $item', style: TextStyle(fontSize: 13, color: Colors.orange[900])),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: Colors.teal[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Done & Back', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String amount, double pct) {
    final Color barColor = pct > 40
        ? Colors.red
        : (pct > 20 ? Colors.amber[700]! : Colors.teal);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$amount (${pct.toStringAsFixed(0)}% Limit)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: barColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            color: barColor,
          ),
        ),
      ],
    );
  }
}
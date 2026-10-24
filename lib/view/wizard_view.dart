import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../data/services/storage_service.dart';
import 'main_layout.dart';

class WizardView extends StatefulWidget {
  const WizardView({Key? key}) : super(key: key);

  @override
  _WizardViewState createState() => _WizardViewState();
}

class _WizardViewState extends State<WizardView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final UserModel _user = UserModel();
  
  final TextEditingController _otherHealthCtrl = TextEditingController();
  final TextEditingController _otherAllergyCtrl = TextEditingController();
  final TextEditingController _otherDietCtrl = TextEditingController();

  void _nextStep() {
    if (_currentPage < 4) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finishWizard();
    }
  }

  void _prevStep() {
    if (_currentPage > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _finishWizard() async {
      // Masukkan isi TextField "Lainnya" jika ada
      if (_user.healthConditions.contains('Lainnya')) {
        _user.healthConditions.remove('Lainnya');
        if (_otherHealthCtrl.text.trim().isNotEmpty) {
          _user.healthConditions.add(_otherHealthCtrl.text.trim());
        }
      }
      if (_user.allergies.contains('Lainnya')) {
        _user.allergies.remove('Lainnya');
        if (_otherAllergyCtrl.text.trim().isNotEmpty) {
          _user.allergies.add(_otherAllergyCtrl.text.trim());
        }
      }
      if (_user.dietPreferences.contains('Lainnya')) {
        _user.dietPreferences.remove('Lainnya');
        if (_otherDietCtrl.text.trim().isNotEmpty) {
          _user.dietPreferences.add(_otherDietCtrl.text.trim());
        }
      }

      await StorageService.saveUser(_user);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLayout(user: _user)),
      );
    }

  void _toggleSelection(List<String> list, String item) {
    setState(() {
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Personalisasi', 
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[900])),
                      TextButton(
                        onPressed: _finishWizard,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Lewati', style: TextStyle(color: Colors.teal[600], fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          height: 6,
                          decoration: BoxDecoration(
                            color: index <= _currentPage ? Colors.teal[500] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text('LANGKAH ${_currentPage + 1} DARI 5', 
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.2)),
                ],
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  if (_currentPage > 0) ...[
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.grey[100],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _prevStep,
                        child: Text('Kembali', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.teal[600],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _nextStep,
                      child: Text(_currentPage == 4 ? 'Mulai Aplikasi' : 'Selanjutnya', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.grey[50],
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[400]) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade500)),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Data Diri', 'Mari kenalan agar aplikasi lebih personal.'),
          TextField(
            onChanged: (val) => _user.name = val,
            decoration: _inputStyle('Nama Panggilan (Opsional)', prefixIcon: Icons.person_outline),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (val) => _user.age = val,
            keyboardType: TextInputType.number,
            decoration: _inputStyle('Usia (Tahun)'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _user.gender.isEmpty ? null : _user.gender,
            decoration: _inputStyle('Jenis Kelamin'),
            items: ['Laki-laki', 'Perempuan'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (val) => setState(() => _user.gender = val!),
          )
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Profil Tubuh', 'Untuk menghitung IMT & kebutuhan nutrisi harian.'),
          TextField(
            onChanged: (val) => _user.height = val,
            keyboardType: TextInputType.number,
            decoration: _inputStyle('Tinggi Badan (cm)'),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (val) => _user.weight = val,
            keyboardType: TextInputType.number,
            decoration: _inputStyle('Berat Badan (kg)'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return _buildMultiSelectScreen(
      title: 'Kondisi Kesehatan',
      subtitle: 'Pilih kondisi yang Anda miliki (Bisa >1).',
      options: ['Diabetes', 'Hipertensi', 'Kolesterol/Jantung', 'Ginjal', 'Diet Berat Badan', 'Lainnya'],
      targetList: _user.healthConditions,
      otherCtrl: _otherHealthCtrl,
      otherPlaceholder: 'Sebutkan kondisi medis lainnya...',
    );
  }

  Widget _buildStep4() {
    return _buildMultiSelectScreen(
      title: 'Alergen',
      subtitle: 'Penting: Kami akan memberi peringatan untuk ini.',
      options: ['Seafood', 'Susu Sapi/Laktosa', 'Kacang', 'Telur', 'Gluten', 'Lainnya'],
      targetList: _user.allergies,
      otherCtrl: _otherAllergyCtrl,
      otherPlaceholder: 'Sebutkan alergi lainnya...',
    );
  }

  Widget _buildStep5() {
    return _buildMultiSelectScreen(
      title: 'Preferensi Diet',
      subtitle: 'Gaya hidup atau pola makan khusus Anda.',
      options: ['Halal', 'Vegetarian', 'Vegan', 'Lainnya'],
      targetList: _user.dietPreferences,
      otherCtrl: _otherDietCtrl,
      otherPlaceholder: 'Sebutkan diet khusus lainnya...',
    );
  }

  // Helper untuk Chip Multi-select (Step 3, 4, 5)
  Widget _buildMultiSelectScreen({
    required String title,
    required String subtitle,
    required List<String> options,
    required List<String> targetList,
    required TextEditingController otherCtrl,
    required String otherPlaceholder,
  }) {
    bool isOtherSelected = targetList.contains('Lainnya');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(title, subtitle),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: options.map((option) {
              final isSelected = targetList.contains(option);
              return GestureDetector(
                onTap: () {
                  _toggleSelection(targetList, option);
                  if (option == 'Lainnya' && !isSelected == false) {
                    otherCtrl.clear();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.teal[50] : Colors.grey[50],
                    border: Border.all(color: isSelected ? Colors.teal[500]! : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.teal[700] : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (isOtherSelected) ...[
            const SizedBox(height: 20),
            TextField(
              controller: otherCtrl,
              decoration: _inputStyle(otherPlaceholder),
            )
          ]
        ],
      ),
    );
  }
}
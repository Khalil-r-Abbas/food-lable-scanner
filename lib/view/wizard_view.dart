import 'package:flutter/material.dart';
import '../model/user_model.dart';
import 'main_layout.dart';

class WizardView extends StatefulWidget {
  const WizardView({Key? key}) : super(key: key);

  @override
  _WizardViewState createState() => _WizardViewState();
}

class _WizardViewState extends State<WizardView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Inisialisasi data pengguna
  final UserModel _user = UserModel();

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      // Pindah ke halaman utama dan bawa data _user
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLayout(user: _user)),
      );
    }
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
      appBar: AppBar(
        title: Text('Langkah ${_currentPage + 1} dari 5'),
        backgroundColor: Colors.teal[700],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
            backgroundColor: Colors.teal[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[700]!),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildMultiSelect('Kondisi Kesehatan', ['Diabetes', 'Hipertensi', 'Kolesterol', 'Lainnya'], _user.healthConditions),
                _buildMultiSelect('Alergi', ['Kacang', 'Seafood', 'Susu', 'Lainnya'], _user.allergies),
                _buildMultiSelect('Preferensi Diet', ['Halal', 'Vegan', 'Vegetarian', 'Lainnya'], _user.dietPreferences),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.teal[700],
              ),
              onPressed: _nextPage,
              child: Text(_currentPage == 4 ? 'Selesai & Masuk' : 'Lanjut'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (val) => _user.name = val,
            decoration: const InputDecoration(labelText: 'Nama Lengkap (Opsional)'),
          ),
          TextField(
            onChanged: (val) => _user.age = val,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Usia'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (val) => _user.height = val,
            decoration: const InputDecoration(labelText: 'Tinggi Badan (cm)'),
          ),
          TextField(
            onChanged: (val) => _user.weight = val,
            decoration: const InputDecoration(labelText: 'Berat Badan (kg)'),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelect(String title, List<String> options, List<String> targetList) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: options.map((option) {
              final isSelected = targetList.contains(option);
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                selectedColor: Colors.teal[700],
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                onSelected: (bool selected) {
                  _toggleSelection(targetList, option);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../model/user_model.dart';

class ProfileView extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSave;

  const ProfileView({Key? key, required this.user, required this.onSave}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;  
  late TextEditingController _healthCtrl;
  late TextEditingController _allergyCtrl;
  late TextEditingController _dietCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _ageCtrl = TextEditingController(text: widget.user.age);
    _heightCtrl = TextEditingController(text: widget.user.height);
    _weightCtrl = TextEditingController(text: widget.user.weight);
    
    _healthCtrl = TextEditingController(text: widget.user.healthConditions.join(', '));
    _allergyCtrl = TextEditingController(text: widget.user.allergies.join(', '));
    _dietCtrl = TextEditingController(text: widget.user.dietPreferences.join(', '));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _healthCtrl.dispose();
    _allergyCtrl.dispose();
    _dietCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    widget.user.name = _nameCtrl.text;
    widget.user.age = _ageCtrl.text;
    widget.user.height = _heightCtrl.text;
    widget.user.weight = _weightCtrl.text;
    
    // pengubah string jadi array koma
    widget.user.healthConditions = _healthCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    widget.user.allergies = _allergyCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    widget.user.dietPreferences = _dietCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.teal),
    );

    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: const Text('Profil Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(
                  title: 'Data Diri',
                  children: [
                    TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _ageCtrl, decoration: const InputDecoration(labelText: 'Usia'), keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: widget.user.gender.isNotEmpty ? widget.user.gender : null,
                            decoration: const InputDecoration(labelText: 'Gender'),
                            items: ['Laki-laki', 'Perempuan'].map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (val) => setState(() => widget.user.gender = val!),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _heightCtrl, decoration: const InputDecoration(labelText: 'Tinggi (cm)'), keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: _weightCtrl, decoration: const InputDecoration(labelText: 'Berat (kg)'), keyboardType: TextInputType.number)),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _buildProfileCard(
                  title: 'Kesehatan & Preferensi',
                  children: [
                    TextField(
                      controller: _healthCtrl, 
                      decoration: const InputDecoration(labelText: 'Kondisi Medis (Pisahkan koma)', hintText: 'Misal: Diabetes, Hipertensi')
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _allergyCtrl, 
                      decoration: const InputDecoration(labelText: 'Alergen (Pisahkan koma)', hintText: 'Misal: Kacang, Susu')
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dietCtrl, 
                      decoration: const InputDecoration(labelText: 'Preferensi Diet (Pisahkan koma)', hintText: 'Misal: Halal, Vegan')
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Colors.teal[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saveProfile,
                  child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }
}
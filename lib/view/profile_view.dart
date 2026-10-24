import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../data/services/storage_service.dart';

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

  final List<String> _countries = [
    'Indonesia (BPOM)',
    'WHO Global',
    'Singapore (HPB)',
    'USA (FDA)',
  ];

  final List<String> _languages = ['English', 'Indonesia'];

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

  Future<void> _saveProfile() async {
    widget.user.name = _nameCtrl.text.trim();
    widget.user.age = _ageCtrl.text.trim();
    widget.user.height = _heightCtrl.text.trim();
    widget.user.weight = _weightCtrl.text.trim();

    widget.user.healthConditions = _healthCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    widget.user.allergies = _allergyCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    widget.user.dietPreferences = _dietCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Simpan permanen ke SharedPreferences
    await StorageService.saveUser(widget.user);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved permanently!'), backgroundColor: Colors.teal),
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
          child: const Text('My Health Persona', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(
                  title: 'Personal & Country Standard',
                  children: [
                    TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ageCtrl,
                            decoration: const InputDecoration(labelText: 'Age'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: ['Laki-laki', 'Perempuan'].contains(widget.user.gender)
                                ? widget.user.gender
                                : 'Laki-laki',
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
                        Expanded(
                          child: TextField(
                            controller: _heightCtrl,
                            decoration: const InputDecoration(labelText: 'Height (cm)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _weightCtrl,
                            decoration: const InputDecoration(labelText: 'Weight (kg)'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _countries.contains(widget.user.country) ? widget.user.country : _countries.first,
                      decoration: const InputDecoration(labelText: 'Country Reference Standard'),
                      items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => widget.user.country = val!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _languages.contains(widget.user.language) ? widget.user.language : 'English',
                      decoration: const InputDecoration(labelText: 'AI Explanation Language'),
                      items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                      onChanged: (val) => setState(() => widget.user.language = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildProfileCard(
                  title: 'Health, Allergies & Diet',
                  children: [
                    TextField(
                      controller: _healthCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Medical Conditions (Comma separated)',
                        hintText: 'e.g., Diabetes, Hypertension',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _allergyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Allergies (Comma separated)',
                        hintText: 'e.g., Peanuts, Dairy, Seafood',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dietCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Diet Preferences (Comma separated)',
                        hintText: 'e.g., Halal, Vegan',
                      ),
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
                  child: const Text('Save Changes',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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
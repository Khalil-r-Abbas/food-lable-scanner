import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/user_model.dart';

class StorageService {
  static const String _userKey = 'nutriscan_user_profile';
  static const String _onboardedKey = 'nutriscan_is_onboarded';
  static const String _historyKey = 'nutriscan_scan_history';

  // Simpan Profil User
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_onboardedKey, true);
  }

  // Ambil Profil User
  static Future<UserModel?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboarded = prefs.getBool(_onboardedKey) ?? false;
    if (!isOnboarded) return null;

    final data = prefs.getString(_userKey);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  // Simpan Hasil Scan ke Riwayat (Maksimal 20 riwayat terakhir)
  static Future<void> saveScanToHistory(ScanResultModel result) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_historyKey) ?? [];
    current.insert(0, jsonEncode(result.toJson()));
    if (current.length > 20) {
      current.removeLast();
    }
    await prefs.setStringList(_historyKey, current);
  }

  // Ambil Daftar Riwayat Scan
  static Future<List<ScanResultModel>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_historyKey) ?? [];
    return list
        .map((item) => ScanResultModel.fromJson(jsonDecode(item)))
        .toList();
  }

  // Hapus Riwayat
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
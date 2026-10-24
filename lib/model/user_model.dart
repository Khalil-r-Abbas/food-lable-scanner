import 'dart:convert';

class UserModel {
  String name;
  String age;
  String gender;
  String height;
  String weight;
  String country; // Standar negara acuan (Indonesia, WHO, USA, Singapore)
  String language; // English / Indonesia
  List<String> healthConditions;
  List<String> allergies;
  List<String> dietPreferences;

  UserModel({
    this.name = '',
    this.age = '',
    this.gender = 'Laki-laki',
    this.height = '',
    this.weight = '',
    this.country = 'Indonesia (BPOM)',
    this.language = 'English',
    List<String>? healthConditions,
    List<String>? allergies,
    List<String>? dietPreferences,
  })  : healthConditions = healthConditions ?? [],
        allergies = allergies ?? [],
        dietPreferences = dietPreferences ?? [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
        'country': country,
        'language': language,
        'healthConditions': healthConditions,
        'allergies': allergies,
        'dietPreferences': dietPreferences,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      age: json['age'] ?? '',
      gender: json['gender'] ?? 'Laki-laki',
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      country: json['country'] ?? 'Indonesia (BPOM)',
      language: json['language'] ?? 'English',
      healthConditions: List<String>.from(json['healthConditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      dietPreferences: List<String>.from(json['dietPreferences'] ?? []),
    );
  }
}

class ScanResultModel {
  final String productName;
  final double sugarG;
  final double sodiumMg;
  final double saturatedFatG;
  final double caloriesKcal;
  final double servingsPerContainer;
  final List<String> detectedAllergens;
  final List<String> hiddenIngredients;
  final bool isDietCompliant;
  final String dietNote;
  final String summary;
  final double confidence;
  final String timestamp;

  // Hasil kalkulasi deterministik Dart:
  final String trafficLight; // 'GREEN', 'YELLOW', 'RED'
  final String scoreGrade; // 'A', 'B', 'C', 'D', 'E'
  final double sugarDailyPct;
  final double sodiumDailyPct;
  final double satFatDailyPct;
  final List<String> matchedUserAllergies;

  ScanResultModel({
    required this.productName,
    required this.sugarG,
    required this.sodiumMg,
    required this.saturatedFatG,
    required this.caloriesKcal,
    required this.servingsPerContainer,
    required this.detectedAllergens,
    required this.hiddenIngredients,
    required this.isDietCompliant,
    required this.dietNote,
    required this.summary,
    required this.confidence,
    required this.timestamp,
    required this.trafficLight,
    required this.scoreGrade,
    required this.sugarDailyPct,
    required this.sodiumDailyPct,
    required this.satFatDailyPct,
    required this.matchedUserAllergies,
  });

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'sugarG': sugarG,
        'sodiumMg': sodiumMg,
        'saturatedFatG': saturatedFatG,
        'caloriesKcal': caloriesKcal,
        'servingsPerContainer': servingsPerContainer,
        'detectedAllergens': detectedAllergens,
        'hiddenIngredients': hiddenIngredients,
        'isDietCompliant': isDietCompliant,
        'dietNote': dietNote,
        'summary': summary,
        'confidence': confidence,
        'timestamp': timestamp,
        'trafficLight': trafficLight,
        'scoreGrade': scoreGrade,
        'sugarDailyPct': sugarDailyPct,
        'sodiumDailyPct': sodiumDailyPct,
        'satFatDailyPct': satFatDailyPct,
        'matchedUserAllergies': matchedUserAllergies,
      };

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      productName: json['productName'] ?? 'Unknown Product',
      sugarG: (json['sugarG'] ?? 0).toDouble(),
      sodiumMg: (json['sodiumMg'] ?? 0).toDouble(),
      saturatedFatG: (json['saturatedFatG'] ?? 0).toDouble(),
      caloriesKcal: (json['caloriesKcal'] ?? 0).toDouble(),
      servingsPerContainer: (json['servingsPerContainer'] ?? 1).toDouble(),
      detectedAllergens: List<String>.from(json['detectedAllergens'] ?? []),
      hiddenIngredients: List<String>.from(json['hiddenIngredients'] ?? []),
      isDietCompliant: json['isDietCompliant'] ?? true,
      dietNote: json['dietNote'] ?? '',
      summary: json['summary'] ?? '',
      confidence: (json['confidence'] ?? 0.9).toDouble(),
      timestamp: json['timestamp'] ?? '',
      trafficLight: json['trafficLight'] ?? 'YELLOW',
      scoreGrade: json['scoreGrade'] ?? 'C',
      sugarDailyPct: (json['sugarDailyPct'] ?? 0).toDouble(),
      sodiumDailyPct: (json['sodiumDailyPct'] ?? 0).toDouble(),
      satFatDailyPct: (json['satFatDailyPct'] ?? 0).toDouble(),
      matchedUserAllergies: List<String>.from(json['matchedUserAllergies'] ?? []),
    );
  }

  /// KALKULATOR DETERMINISTIK DART (Bukan tebakan LLM!)
  /// Ini adalah nilai jual utama ke juri lomba.
  static ScanResultModel evaluateFromAiJson(
      Map<String, dynamic> aiData, UserModel user) {
    // 1. Standar batas harian berdasarkan Negara (Gula g, Natrium mg, Lemak Jenuh g)
    Map<String, double> limits = {
      'sugar': 50.0,
      'sodium': 2000.0,
      'satFat': 20.0,
    };

    if (user.country.contains('WHO')) {
      limits = {'sugar': 25.0, 'sodium': 2000.0, 'satFat': 20.0};
    } else if (user.country.contains('Singapore')) {
      limits = {'sugar': 40.0, 'sodium': 2000.0, 'satFat': 20.0};
    } else if (user.country.contains('USA')) {
      limits = {'sugar': 50.0, 'sodium': 2300.0, 'satFat': 20.0};
    }

    // 2. Penyesuaian ketat berdasarkan Kondisi Kesehatan Pengguna (Personalisasi)
    final condStr = user.healthConditions.join(' ').toLowerCase();
    if (condStr.contains('diabetes')) {
      limits['sugar'] = 25.0; // Batas gula diperketat 50% untuk diabetes
    }
    if (condStr.contains('hipertensi') || condStr.contains('hypertension') || condStr.contains('ginjal')) {
      limits['sodium'] = 1500.0; // Batas natrium diperketat (AHA/medical standard)
    }
    if (condStr.contains('kolesterol') || condStr.contains('jantung')) {
      limits['satFat'] = 13.0; // Batas lemak jenuh diperketat
    }

    final double sugar = (aiData['sugar_g'] ?? 0).toDouble();
    final double sodium = (aiData['sodium_mg'] ?? 0).toDouble();
    final double satFat = (aiData['saturated_fat_g'] ?? 0).toDouble();
    final double calories = (aiData['calories_kcal'] ?? 0).toDouble();
    final double servings = (aiData['servings_per_container'] ?? 1).toDouble() <= 0
        ? 1.0
        : (aiData['servings_per_container'] ?? 1).toDouble();

    final double sugarPct = (sugar / limits['sugar']!) * 100;
    final double sodiumPct = (sodium / limits['sodium']!) * 100;
    final double satFatPct = (satFat / limits['satFat']!) * 100;

    // 3. Pencocokan Alergen Deterministik + dari deteksi AI
    final List<String> aiAllergens =
        List<String>.from(aiData['detected_allergens'] ?? []);
    final List<String> matchedAllergies = [];

    for (final userAllergy in user.allergies) {
      for (final prodAllergen in aiAllergens) {
        if (prodAllergen.toLowerCase().contains(userAllergy.toLowerCase()) ||
            userAllergy.toLowerCase().contains(prodAllergen.toLowerCase())) {
          if (!matchedAllergies.contains(prodAllergen)) {
            matchedAllergies.add(prodAllergen);
          }
        }
      }
    }
    // Jika AI langsung menandai alergen spesifik milik user:
    if (matchedAllergies.isEmpty &&
        (aiData['triggers_user_allergy'] == true) &&
        aiAllergens.isNotEmpty) {
      matchedAllergies.addAll(aiAllergens);
    }

    final bool dietCompliant = aiData['is_diet_compliant'] ?? true;

    // 4. Penentuan Traffic Light (GREEN / YELLOW / RED) & Grade secara Deterministik
    String light = 'GREEN';
    String grade = 'A';

    if (matchedAllergies.isNotEmpty ||
        !dietCompliant ||
        sugarPct > 40 ||
        sodiumPct > 40 ||
        satFatPct > 40) {
      light = 'RED';
      grade = (matchedAllergies.isNotEmpty || !dietCompliant) ? 'E' : 'D';
    } else if (sugarPct > 20 || sodiumPct > 20 || satFatPct > 20) {
      light = 'YELLOW';
      grade = (sugarPct > 30 || sodiumPct > 30) ? 'C' : 'B';
    } else {
      light = 'GREEN';
      grade = (sugarPct < 10 && sodiumPct < 10) ? 'A' : 'B';
    }

    return ScanResultModel(
      productName: aiData['product_name'] ?? 'Scanned Food Product',
      sugarG: sugar,
      sodiumMg: sodium,
      saturatedFatG: satFat,
      caloriesKcal: calories,
      servingsPerContainer: servings,
      detectedAllergens: aiAllergens,
      hiddenIngredients: List<String>.from(aiData['hidden_ingredients'] ?? []),
      isDietCompliant: dietCompliant,
      dietNote: aiData['diet_note'] ?? '',
      summary: aiData['summary'] ?? '',
      confidence: (aiData['confidence'] ?? 0.9).toDouble(),
      timestamp: DateTime.now().toIso8601String(),
      trafficLight: light,
      scoreGrade: grade,
      sugarDailyPct: sugarPct,
      sodiumDailyPct: sodiumPct,
      satFatDailyPct: satFatPct,
      matchedUserAllergies: matchedAllergies,
    );
  }
}
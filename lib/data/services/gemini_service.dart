import 'dart:convert';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../model/user_model.dart';

class GeminiService {
  // Tukar urutan: posisikan flash-lite di depan jika 3.8 sedang padat
  static const List<String> _supportedModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.8-flash',
  ];

  Future<ScanResultModel> analyzeFoodLabel(String imagePath, UserModel user) async {
    // 1. KOMPRESS GAMBAR TERLEBIH DAHULU (Mencegah Deadline Exceeded / Timeout)
    File imageFile = File(imagePath);
    Uint8List imageBytes;

    try {
      final targetPath = '${imagePath}_compressed.jpg';
      final compressedResult = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 70, // Kompres kualitas ke 70% agar ukuran file < 300KB
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedResult != null) {
        imageBytes = await File(compressedResult.path).readAsBytes();
      } else {
        imageBytes = await imageFile.readAsBytes();
      }
    } catch (e) {
      debugPrint('Kompresi gagal, menggunakan gambar asli: $e');
      imageBytes = await imageFile.readAsBytes();
    }

    final imagePart = InlineDataPart('image/jpeg', imageBytes);

    final prompt = TextPart('''
You are a clinical nutritionist & food safety AI. Analyze this food packaging/nutrition label image for a user with this profile:
- Health Conditions: ${user.healthConditions.isEmpty ? "None" : user.healthConditions.join(", ")}
- Allergies: ${user.allergies.isEmpty ? "None" : user.allergies.join(", ")}
- Diet Preferences: ${user.dietPreferences.isEmpty ? "None" : user.dietPreferences.join(", ")}
- Preferred Output Language: ${user.language}

Tasks:
1. Extract nutrition facts PER SERVING (sugar in grams, sodium in mg, saturated fat in grams, calories in kcal, and servings per container). If salt is listed in grams, convert to sodium_mg (salt_g * 400).
2. Identify any hidden sugars (e.g., maltodextrin, high fructose corn syrup, dextrose, sucrose), hidden sodium (MSG, disodium), or additives risky for the user's health conditions.
3. Check if any ingredients match or are derivatives of the user's allergies (e.g., whey/casein = Dairy/Milk, albumin = Egg, soy lecithin = Soy).
4. Check if the product complies with the user's Diet Preferences (${user.dietPreferences.join(", ")}).

Respond ONLY in valid JSON with this exact structure (write summary, diet_note, and hidden_ingredients in ${user.language}):
{
  "product_name": "Name of product or 'Food Product'",
  "sugar_g": 0.0,
  "sodium_mg": 0.0,
  "saturated_fat_g": 0.0,
  "calories_kcal": 0.0,
  "servings_per_container": 1.0,
  "detected_allergens": ["list of allergens found in product"],
  "triggers_user_allergy": false,
  "hidden_ingredients": ["e.g., Maltodextrin (Hidden Sugar)", "Monosodium Glutamate (Hidden Sodium)"],
  "is_diet_compliant": true,
  "diet_note": "Brief note on Halal/Vegan/diet compliance",
  "summary": "2-sentence personalized health explanation for this user.",
  "confidence": 0.95
}
''');

    GenerateContentResponse? response;
    Object? lastError;

    for (final modelName in _supportedModels) {
      try {
        debugPrint('Mencoba analisis dengan model: $modelName');
        final model = FirebaseAI.googleAI().generativeModel(
          model: modelName,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 0.1,
          ),
        );

        response = await model.generateContent([
          Content.multi([imagePart, prompt])
        ]);

        if (response.text != null && response.text!.isNotEmpty) {
          debugPrint('Berhasil menggunakan model: $modelName');
          break;
        }
      } catch (e) {
        debugPrint('Model $modelName gagal ($e), beralih ke model cadangan...');
        lastError = e;
      }
    }

    if (response == null || response.text == null) {
      throw Exception('Gagal menganalisis gambar. Server sedang sibuk, silakan coba lagi. Detail: $lastError');
    }

    final rawText = response.text!;
    final cleanedJson = rawText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final Map<String, dynamic> aiData = jsonDecode(cleanedJson);
    return ScanResultModel.evaluateFromAiJson(aiData, user);
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'view/wizard_view.dart';
import 'view/main_layout.dart';
import 'model/user_model.dart';
import 'data/services/storage_service.dart';
import 'firebase_options.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error kamera: $e');
  }

  final UserModel? savedUser = await StorageService.loadUser();

  runApp(MyApp(initialUser: savedUser));
}

class MyApp extends StatelessWidget {
  final UserModel? initialUser;

  const MyApp({Key? key, this.initialUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriScan AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: initialUser != null
          ? MainLayout(user: initialUser!)
          : const WizardView(),
    );
  }
}
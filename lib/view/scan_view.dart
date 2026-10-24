import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_model.dart';
import '../data/services/gemini_service.dart';
import '../data/services/storage_service.dart';
import '../main.dart';
import 'result_view.dart';

class ScanView extends StatefulWidget {
  final UserModel user;

  const ScanView({Key? key, required this.user}) : super(key: key);

  @override
  _ScanViewState createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _selectedCameraIdx = 0;
  final ImagePicker _picker = ImagePicker();
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _initCamera(_selectedCameraIdx);
  }

  Future<void> _initCamera(int cameraIndex) async {
    if (cameras.isNotEmpty) {
      final controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      _cameraController = controller;

      try {
        await controller.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } catch (e) {
        debugPrint("Camera init error: $e");
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;
    setState(() => _isCameraInitialized = false);
    _selectedCameraIdx = (_selectedCameraIdx + 1) % cameras.length;
    await _cameraController?.dispose();
    await _initCamera(_selectedCameraIdx);
  }

  // Fungsi utama pemrosesan gambar (dipakai bersama oleh Kamera & Galeri)
  Future<void> _processImagePath(String imagePath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.tealAccent, strokeWidth: 5),
              SizedBox(height: 20),
              Text(
                'Analyzing Nutrition & Ingredients...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Checking hidden sugars, allergens & country thresholds',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final ScanResultModel result =
          await _geminiService.analyzeFoodLabel(imagePath, widget.user);

      // Simpan otomatis ke riwayat lokal
      await StorageService.saveScanToHistory(result);

      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog loading

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultView(
            user: widget.user,
            imagePath: imagePath,
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menganalisis gambar: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _takePictureAndScan() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    try {
      final XFile imageFile = await _cameraController!.takePicture();
      await _processImagePath(imageFile.path);
    } catch (e) {
      debugPrint("Gagal mengambil foto: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        await _processImagePath(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Gagal mengambil dari galeri: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isCameraInitialized && _cameraController != null)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              )
            else
              const Center(child: CircularProgressIndicator(color: Colors.teal)),

            Positioned.fill(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.user.country,
                            style: const TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: _isFlashOn ? Colors.amber : Colors.white,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Align Nutrition Facts / Ingredients inside frame',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: 260,
                            height: 350,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.tealAccent, width: 2),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, left: 32, right: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // TOMBOL GALERI (AKTIF)
                        IconButton(
                          icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 32),
                          tooltip: 'Pick from Gallery',
                          onPressed: _pickFromGallery,
                        ),
                        GestureDetector(
                          onTap: _takePictureAndScan,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 32),
                          onPressed: _switchCamera,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
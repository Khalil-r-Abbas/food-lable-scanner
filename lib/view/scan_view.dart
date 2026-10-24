import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../model/user_model.dart';
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

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _takePictureAndScan() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      XFile imageFile = await _cameraController!.takePicture();
      
      debugPrint("Foto berhasil diambil: ${imageFile.path}");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.tealAccent, strokeWidth: 6),
              const SizedBox(height: 24),
              const Text('Menganalisis Data...', 
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      Navigator.pop(context); 
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => ResultView(user: widget.user))
      );

    } catch (e) {
      debugPrint("Gagal mengambil foto: $e");
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
                        IconButton(
                          icon: const Icon(Icons.flash_off, color: Colors.white),
                          onPressed: () {
                            // flash kalau perlu dibuat disini
                          },
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
                            child: const Text('Arahkan ke tabel Nilai Gizi', 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 24),
                          
                          Container(
                            width: 250,
                            height: 350,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.tealAccent, width: 2),
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withOpacity(0.2),
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
                        IconButton(
                          icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 32),
                          onPressed: () {
                            // galeri pakai image picker
                          },
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
                          onPressed: () {
                            // switch kamera depan belakang
                          },
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
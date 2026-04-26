import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:story_app/l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isCameraInitialized = false;
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      onNewCameraSelected(widget.cameras.first);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    await previousCameraController?.dispose();

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      debugPrint('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        controller = cameraController;
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void _onCameraSwitch() {
    if (widget.cameras.length < 2) return;

    final isFrontCamera =
        controller?.description.lensDirection == CameraLensDirection.front;
    final newCamera = widget.cameras.firstWhere(
      (camera) => isFrontCamera
          ? camera.lensDirection == CameraLensDirection.back
          : camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras[0],
    );

    onNewCameraSelected(newCamera);
  }

  Future<void> _onCameraButtonClick() async {
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }

    final image = await controller?.takePicture();
    if (mounted) {
      Navigator.of(context).pop(image);
    }
  }

  Widget _actionWidget() {
    return FloatingActionButton(
      heroTag: 'take-picture',
      onPressed: _onCameraButtonClick,
      child: const Icon(Icons.camera_alt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.take_photo),
          actions: [
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _onCameraSwitch,
            ),
          ],
        ),
        body: Center(
          child: Stack(
            children: [
              _isCameraInitialized
                  ? CameraPreview(controller!)
                  : const Center(child: CircularProgressIndicator()),
              Align(
                alignment: const Alignment(0, 0.95),
                child: _actionWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

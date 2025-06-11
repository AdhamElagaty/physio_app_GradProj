import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraViewWidget extends StatelessWidget {
  final CameraController cameraController;
  final CustomPainter? painter;

  const CameraViewWidget({
    super.key,
    required this.cameraController,
    this.painter,
  });

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return const Center(child: Text("Camera not initialized"));
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: cameraController.value.aspectRatio,
          child: cameraController.description.lensDirection == CameraLensDirection.front
              ? Transform.scale(
                  scaleX: -1, // Mirror horizontally
                  child: CameraPreview(cameraController),
                )
              : CameraPreview(cameraController),
        ),
        if (painter != null)
          CustomPaint(
            painter: painter,
          ),
      ],
    );
  }
}
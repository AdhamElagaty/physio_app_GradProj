import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:ui'; // For Size

// Function to convert CameraImage to InputImage
InputImage? inputImageFromCameraImage(CameraImage image, CameraDescription cameraDescription) {

  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }

  return InputImage.fromBytes(
    bytes: allBytes.done().buffer.asUint8List(),
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
  );
}
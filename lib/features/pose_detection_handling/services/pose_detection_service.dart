import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import '../data/exceptions/pose_detection_exception.dart';

class PoseDetectionService {
  final PoseDetector _poseDetector;
  final Lock _processingLock = Lock();
  bool _isDisposed = false;

  PoseDetectionService()
      : _poseDetector = PoseDetector(
          options: PoseDetectorOptions(
            mode: PoseDetectionMode.stream,
            model: PoseDetectionModel.accurate,
          ),
        );

  Future<List<Pose>> processImage(InputImage inputImage) async {
    _validateServiceState();
    
    return _processingLock.synchronized(() async {
      try {
        return await _poseDetector.processImage(inputImage);
      } catch (e, stackTrace) {
        debugPrint('Error processing image: $e');
        debugPrint('Stack trace: $stackTrace');
        throw PoseDetectionException(e, stackTrace);
      }
    });
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    
    await _processingLock.synchronized(() async {
      await _poseDetector.close();
    });
  }

  void _validateServiceState() {
    if (_isDisposed) {
      throw const PoseDetectionException.serviceDisposed();
    }
  }
}
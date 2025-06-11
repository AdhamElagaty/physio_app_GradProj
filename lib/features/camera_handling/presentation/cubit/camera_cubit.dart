import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../services/camera_service.dart';
import 'camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  final CameraService _cameraService;
  StreamSubscription? _imageStreamSubscription;
  Function(CameraImage)? _onImageStream;

  CameraCubit(this._cameraService) : super(CameraInitial());

  Future<void> initializeCamera() async {
    emit(CameraLoading());
    final success = await _cameraService.initialize();
    if (success && _cameraService.cameraController != null) {
      emit(CameraReady(
        _cameraService.cameraController!,
        isFrontCamera: _cameraService.currentLensDirection == CameraLensDirection.front,
      ));
    } else {
      emit(const CameraFailure("Failed to initialize camera."));
    }
  }

  Future<void> switchCamera() async {
    if (_cameraService.cameraController == null) return;
    final bool wasStreaming = _cameraService.cameraController!.value.isStreamingImages;
    
    emit(CameraLoading()); // Show loading while switching
    await _cameraService.switchCamera();
    
    if (_cameraService.cameraController != null && _cameraService.cameraController!.value.isInitialized) {
      emit(CameraReady(
        _cameraService.cameraController!,
        isFrontCamera: _cameraService.currentLensDirection == CameraLensDirection.front,
      ));
      if (wasStreaming && _onImageStream != null) {
        startImageStream(_onImageStream!);
      }
    } else {
      emit(const CameraFailure("Failed to switch camera."));
    }
  }

  void startImageStream(Function(CameraImage) onImage) {
    _onImageStream = onImage;
    if (state is CameraReady && _cameraService.cameraController != null) {
      _cameraService.startImageStream(onImage);
    }
  }

  void stopImageStream() {
    _onImageStream = null;
    _cameraService.stopImageStream();
  }

  InputImageRotation getRotation() {
    final int rotation = _cameraService.cameraController!.description.sensorOrientation;
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  Future<void> close() {
    _imageStreamSubscription?.cancel();
    _cameraService.dispose();
    return super.close();
  }
}
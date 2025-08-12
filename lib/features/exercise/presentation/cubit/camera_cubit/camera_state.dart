import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class CameraState extends Equatable {
  const CameraState();
  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;
  final bool isFrontCamera;
  const CameraReady(this.controller, {required this.isFrontCamera});
  @override
  List<Object?> get props => [controller, isFrontCamera];
}

class CameraFailure extends CameraState {
  final String error;
  const CameraFailure(this.error);
  @override
  List<Object?> get props => [error];
}
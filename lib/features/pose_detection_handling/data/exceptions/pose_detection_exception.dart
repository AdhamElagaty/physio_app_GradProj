class PoseDetectionException implements Exception {
  final dynamic cause;
  final StackTrace? stackTrace;
  final String message;

  const PoseDetectionException(this.cause, this.stackTrace)
      : message = 'Pose detection failed: $cause';

  const PoseDetectionException.serviceDisposed()
      : cause = null,
        stackTrace = null,
        message = 'Service has been disposed';

  @override
  String toString() => message;
}
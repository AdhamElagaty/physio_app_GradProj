import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../entities/body_tracker_result.dart';

abstract class BodyTracker {
  final String name;
  
  BodyTracker(this.name);
  
  BodyTrackerResult processLandmarks(Pose pose, Size imageSize);
  
  bool areLandmarksVisible(Pose pose);
  
  void reset();
}

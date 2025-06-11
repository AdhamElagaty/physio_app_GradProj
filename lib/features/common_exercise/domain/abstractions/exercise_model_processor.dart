import '../entities/model_prediction_result.dart';

abstract class ExerciseModelProcessor {
  bool isReady = false;
  
  Future<void> loadModel();
  
  ModelPredictionResult predict(List<double> features);
}
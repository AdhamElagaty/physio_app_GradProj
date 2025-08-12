import 'data/models/model_prediction_result.dart';

abstract class FeatureModelProcessor {
  bool isReady = false;
  
  Future<void> loadModel();
  
  ModelPredictionResult predict(List<double> features);
}
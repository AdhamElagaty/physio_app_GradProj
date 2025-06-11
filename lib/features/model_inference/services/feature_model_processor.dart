import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../../common_exercise/domain/abstractions/exercise_model_processor.dart';
import '../../common_exercise/domain/entities/model_prediction_result.dart';

class FeatureModelProcessor extends ExerciseModelProcessor {
  final String modelPath;
  late OrtSession? _session;
  
  FeatureModelProcessor({
    required this.modelPath
  });
  
  @override
  Future<void> loadModel() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final localModelPath = '${tempDir.path}/${basename(modelPath)}';
      
      final modelData = await rootBundle.load(modelPath);

      final modelFile = File(localModelPath);
      
      await modelFile.writeAsBytes(modelData.buffer.asUint8List());

      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromFile(modelFile, sessionOptions);
      isReady = _session != null;

      log('Model processor initialized: $isReady');
    } catch (e) {
      log('Error loading model: $e');
      isReady = false;
    }
  }
  
  @override
  ModelPredictionResult predict(List<double> features) {
    if (!isReady) {
      return ModelPredictionResult.error("Model not loaded");
    }
    
    try {   
      final inputFloats = Float32List.fromList(features);
      final inputTensor = OrtValueTensor.createTensorWithDataList(
        inputFloats, 
        <int>[1, features.length]
      );
      
      final inputs = {'float_input': inputTensor};
      final outputs = _session!.run(OrtRunOptions(), inputs);
      final prediction = outputs.first?.value as List?;
      
      return ModelPredictionResult(
        isValid: true,
        prediction: prediction?[0]
      );
    } catch (e) {
      return ModelPredictionResult.error("Prediction error: $e");
    }
  }
}
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../../common_exercise/domain/abstractions/exercise_model_processor.dart';
import '../../common_exercise/domain/entities/model_prediction_result.dart';

class ScaledFeatureModelProcessor extends ExerciseModelProcessor {
  final String modelPath;
  final String scalerPath;
  late OrtSession? _session;
  List<double>? _scalerMean;
  List<double>? _scalerScale;
  
  ScaledFeatureModelProcessor({
    required this.modelPath,
    required this.scalerPath
  });
  
  @override
  Future<void> loadModel() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final localModelPath = '${tempDir.path}/${basename(modelPath)}';
      final localScalerPath = '${tempDir.path}/${basename(scalerPath)}';
      
      final modelData = await rootBundle.load(modelPath);
      final scalerData = await rootBundle.load(scalerPath);

      final modelFile = File(localModelPath);
      final scalerFile = File(localScalerPath);
      
      await modelFile.writeAsBytes(modelData.buffer.asUint8List());
      await scalerFile.writeAsBytes(scalerData.buffer.asUint8List());
      
      final scalerJson = jsonDecode(await scalerFile.readAsString());
      _scalerMean = List<double>.from(scalerJson['mean'].map((x) => x.toDouble()));
      _scalerScale = List<double>.from(scalerJson['scale'].map((x) => x.toDouble()));

      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromFile(modelFile, sessionOptions);
      
      isReady = _session != null && _scalerMean != null && _scalerScale != null;
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
      final List<double> featuresScaled = [];
      for (int i = 0; i < features.length; i++) {
        featuresScaled.add((features[i] - _scalerMean![i]) / _scalerScale![i]);
      }
      
      final inputFloats = Float32List.fromList(featuresScaled);
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
class ModelPredictionResult {
  final bool isValid;
  final dynamic prediction;
  final String? errorMessage;
  
  ModelPredictionResult({
    required this.isValid,
    required this.prediction,
    this.errorMessage
  });
  
  factory ModelPredictionResult.error(String message) {
    return ModelPredictionResult(
      isValid: false,
      prediction: null,
      errorMessage: message
    );
  }
}
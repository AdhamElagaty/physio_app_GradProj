import 'package:dio/dio.dart';

import 'api_consumer.dart';

class ApiManager implements ApiConsumer {
  final Dio _dio;

  ApiManager(this._dio);

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return response.data;
  }

  @override
  Future<dynamic> post(String path,
      {dynamic body,
      Map<String, dynamic>? queryParameters,
      bool isFormData = false}) async {
    final response = await _dio.post(
      path,
      queryParameters: queryParameters,
      data: isFormData ? FormData.fromMap(body) : body,
    );
    return response.data;
  }

  @override
  Future<dynamic> put(String path,
      {dynamic body, Map<String, dynamic>? queryParameters}) async {
    final response =
        await _dio.put(path, queryParameters: queryParameters, data: body);
    return response.data;
  }
  
  @override
  Future<dynamic> delete(String path,
      {dynamic body, Map<String, dynamic>? queryParameters}) async {
    final response =
        await _dio.delete(path, queryParameters: queryParameters, data: body);
    return response.data;
  }

  @override
  Future<Response> getWithFullResponse(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
    return response;
  }
}
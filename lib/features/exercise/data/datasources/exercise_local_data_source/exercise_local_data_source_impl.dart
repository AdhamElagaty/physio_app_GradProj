import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/error/exceptions.dart';
import '../../model/exercise_category_model.dart';
import '../../model/exercise_model.dart';
import 'exercise_local_data_source.dart';


class ExerciseLocalDataSourceImpl implements ExerciseLocalDataSource {
  final SharedPreferences _sharedPreferences;

  ExerciseLocalDataSourceImpl(this._sharedPreferences);

  static const _kExercisesCacheKey = 'exercises_cache';
  static const _kCategoriesCacheKey = 'categories_cache';
  static const _exercisesAssetPath = 'assets/data/exercises.json';
  static const _categoriesAssetPath = 'assets/data/categories.json';

  Future<List<T>> _getData<T>({
    required String cacheKey,
    required String assetPath,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final jsonString = _sharedPreferences.getString(cacheKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => fromJson(json)).toList();
      } catch (e) {
        log('Cache corrupted, loading from assets: $e');
      }
    }

    try {
      final assetJsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(assetJsonString);
      return jsonList.map((json) => fromJson(json)).toList();
    } catch (e) {
      throw CacheException();
    }
  }

  Future<void> _cacheData<T>({
    required String cacheKey,
    required List<T> data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final jsonList = data.map((item) => toJson(item)).toList();
    final jsonString = json.encode(jsonList);
    await _sharedPreferences.setString(cacheKey, jsonString);
  }

  @override
  Future<List<ExerciseModel>> getExercises() async {
    return _getData<ExerciseModel>(
      cacheKey: _kExercisesCacheKey,
      assetPath: _exercisesAssetPath,
      fromJson: (json) => ExerciseModel.fromLocalJson(json),
    );
  }

  @override
  Future<void> cacheExercises(List<ExerciseModel> exercises) async {
    await _cacheData<ExerciseModel>(
      cacheKey: _kExercisesCacheKey,
      data: exercises,
      toJson: (exercise) => exercise.toLocalJson(),
    );
  }

  @override
  Future<List<ExerciseCategoryModel>> getCategories() async {
    return _getData<ExerciseCategoryModel>(
      cacheKey: _kCategoriesCacheKey,
      assetPath: _categoriesAssetPath,
      fromJson: (json) => ExerciseCategoryModel.fromLocalJson(json),
    );
  }

  @override
  Future<void> cacheCategories(List<ExerciseCategoryModel> categories) async {
    await _cacheData<ExerciseCategoryModel>(
      cacheKey: _kCategoriesCacheKey,
      data: categories,
      toJson: (category) => category.toLocalJson(),
    );
  }
}

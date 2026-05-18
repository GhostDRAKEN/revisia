import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../models/quiz_model.dart';
import '../models/summary_model.dart';
import 'auth_service.dart';

class GenerationService {
  GenerationService({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  final Dio _dio;

  Future<QuizModel> generateQuiz({
    required String documentId,
    int questionCount = 10,
  }) async {
    try {
      final token = await _requireToken();
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.generateQuiz,
        data: {'document_id': documentId, 'question_count': questionCount},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final json = response.data;
      if (json == null || json['success'] != true) {
        throw const ApiException('Erreur de génération, réessayez');
      }

      return QuizModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw handleDioError(error);
    }
  }

  Future<SummaryModel> generateSummary({required String documentId}) async {
    try {
      final token = await _requireToken();
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.generateSummary,
        data: {'document_id': documentId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final json = response.data;
      if (json == null || json['success'] != true) {
        throw const ApiException('Erreur de génération, réessayez');
      }

      return SummaryModel.fromJson(json['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw handleDioError(error);
    }
  }

  Future<String> _requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.tokenKey);
    if (token == null || token.isEmpty) {
      throw const ApiException(
        'Authentification requise',
        code: 'AUTHENTICATION_REQUIRED',
        statusCode: 401,
      );
    }
    return token;
  }
}

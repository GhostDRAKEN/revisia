import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../models/document_model.dart';
import 'auth_service.dart';

class DocumentService {
  DocumentService({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  final Dio _dio;

  Future<DocumentModel> uploadPdf({
    required String filePath,
    String? fileName,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final token = await _requireToken();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: DioMediaType('application', 'pdf'),
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.uploadDocument,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        onSendProgress: onSendProgress,
      );

      final json = response.data;
      if (json == null || json['success'] != true) {
        throw const ApiException('Une erreur est survenue, réessayez');
      }

      return DocumentModel.fromJson(json['data'] as Map<String, dynamic>);
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

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_constants.dart';
import '../models/document_model.dart';
import 'auth_service.dart';

class DocumentService {
  DocumentService({Dio? dio, FlutterSecureStorage? storage})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)),
      _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

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
    final token = await _storage.read(key: ApiConstants.tokenKey);

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

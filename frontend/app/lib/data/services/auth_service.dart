import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const ApiException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

class AuthResult {
  final String token;
  final UserModel user;
  final String message;

  const AuthResult({
    required this.token,
    required this.user,
    required this.message,
  });
}

class AuthService extends ChangeNotifier {
  AuthService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  final Dio _dio;

  UserModel? _currentUser;
  String? _token;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiConstants.tokenKey);
    notifyListeners();
  }

  Future<AuthResult> register({
    required String firstName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {'first_name': firstName, 'email': email, 'password': password},
      );

      final result = _parseAuthResponse(response.data);
      await _saveToken(result.token);
      _currentUser = result.user;
      notifyListeners();
      return result;
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final result = _parseAuthResponse(response.data);
      await _saveToken(result.token);
      _currentUser = result.user;
      notifyListeners();
      return result;
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  Future<void> logout() async {
    final storedToken = _token;

    try {
      if (storedToken != null) {
        await _dio.post<Map<String, dynamic>>(
          ApiConstants.logout,
          options: Options(
            headers: {'Authorization': 'Bearer $storedToken'},
          ),
        );
      }
    } on DioException catch (error) {
      throw _handleDioError(error);
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConstants.tokenKey);
      _token = null;
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<String> requireToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = _token ?? prefs.getString(ApiConstants.tokenKey);

    if (storedToken == null || storedToken.isEmpty) {
      throw const ApiException(
        'Authentification requise',
        code: 'AUTHENTICATION_REQUIRED',
        statusCode: 401,
      );
    }

    _token = storedToken;
    return storedToken;
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.tokenKey, token);
  }

  AuthResult _parseAuthResponse(Map<String, dynamic>? json) {
    if (json == null || json['success'] != true) {
      throw const ApiException('Une erreur est survenue, réessayez');
    }

    final data = json['data'] as Map<String, dynamic>;

    return AuthResult(
      token: data['token'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }
}

ApiException handleDioError(DioException error) {
  final responseData = error.response?.data;

  if (responseData is Map<String, dynamic>) {
    return ApiException(
      responseData['error']?.toString() ??
          responseData['message']?.toString() ??
          'Une erreur est survenue, réessayez',
      code: responseData['code']?.toString(),
      statusCode: error.response?.statusCode,
    );
  }

  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return const ApiException('La requête a pris trop de temps');
  }

  return const ApiException('Une erreur est survenue, réessayez');
}

ApiException _handleDioError(DioException error) => handleDioError(error);
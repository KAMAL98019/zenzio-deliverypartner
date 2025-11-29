import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'token_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final dynamic error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message ?? 'Success',
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, dynamic error}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode ?? 500,
      error: error,
    );
  }
}

class ApiClient {
  static const String baseUrl = 'https://api.zenzio.in/';

  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status! < 500,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await TokenStorage.getAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          options.headers.addAll({
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'platform': 'Android',
            'User-Agent': 'Android',
            'mode': 'development',
            'clientId': '0fb4e7a0-8ca8-46a3-8ffe-0f4a078bb811',
          });
          debugPrint('📤 [REQUEST] ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('📥 [RESPONSE] ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('❌ [ERROR] ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  String _getErrorMessage(dynamic error, Response? response) {
    String errorMessage = 'An unexpected error occurred';
    
    // Check for network errors (no connection, timeout)
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Network Error: Please check your internet connection.';
        _showErrorToast(errorMessage);
        return errorMessage;
      }
      
      // Check for 502 Bad Gateway (often indicates server is down)
      if (error.response?.statusCode == 502) {
        errorMessage = 'Server is currently down. Please try again later.';
        _showErrorToast(errorMessage);
        return errorMessage;
      }
    }

    try {
      if (response != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final details = data['details'];
        if (details != null && details is List && details.isNotEmpty) {
          // Join the list of details for a more specific error message
          errorMessage = details.join(', ');
        } else {
          errorMessage = data['message'] ?? 'Error occurred';
        }
      } else {
        errorMessage = error.toString();
      }
    } catch (e) {
      errorMessage = error.toString();
    }
    
    // Fallback to show a general toast for other client/server errors if it's not a success and a specific message is available
    if (response != null && response.statusCode! >= 400 && response.statusCode! < 500) {
      // Don't show toast for 4xx errors, assume the UI handles them (e.g., wrong password message)
    } else if (response != null && response.statusCode! >= 500) {
      _showErrorToast('Server Error (${response.statusCode}): $errorMessage');
    } else if (error is! DioException) { // Catch all other unexpected errors
      _showErrorToast(errorMessage);
    }
    
    return errorMessage;
  }

  // =========================
  // 🔹 AUTH MODULE (OLD API)
  // =========================

  Future<ApiResponse<Map<String, dynamic>>> register({
    required dynamic data, // Changed to dynamic to accept FormData
  }) async {
    try {
      final response = await _dio.post('/fleets/auth/signup/email', data: data);
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/fleets/auth/login/email',
        data: {'email': email, 'password': password},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} | ${response.data.runtimeType} | ${response.data}');
      if (response.statusCode == 201) {
        final accessToken = response.data?['accessToken'] as String?;
        final refreshToken = response.data?['refreshToken'] as String?;
        if (accessToken != null && refreshToken != null) {
          await TokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> loginWithOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/fleets/auth/login/otp',
        data: {'phone': phone, 'otp': otp},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 201) {
        final accessToken = response.data?['accessToken'] as String?;
        final refreshToken = response.data?['refreshToken'] as String?;
        if (accessToken != null && refreshToken != null) {
          await TokenStorage.saveTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendOtp({
    required String mobileNumber,
  }) async {
    print("${baseUrl}/otp/send");
    try {
      final response = await _dio.post(
        '/otp/send',
        data: {'phone': mobileNumber.trim()},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/otp/verify',
        data: {'phone': mobileNumber.trim(), 'otp': otp.trim()},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String emailOrMobile,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/delivery/forgot-password/reset-password',
        data: {'emailOrMobile': emailOrMobile, 'newPassword': newPassword},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resendOtp({
    required String emailOrMobile,
  }) async {
    try {
      final response = await _dio.post(
        '/api/delivery/forgot-password/resend-otp',
        data: {'emailOrMobile': emailOrMobile},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  // =============================
  // 🔹 DELIVERY & ATTENDANCE API
  // =============================

  Future<ApiResponse<Map<String, dynamic>>> postAttendance({
    required String partnerId,
    String? photoFilePath,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('partnerId', partnerId));

      if (latitude != null)
        formData.fields.add(MapEntry('latitude', latitude.toString()));
      if (longitude != null)
        formData.fields.add(MapEntry('longitude', longitude.toString()));
      if (photoFilePath != null) {
        formData.files.add(
          MapEntry(
            'attendancePhoto',
            await MultipartFile.fromFile(
              photoFilePath,
              filename: 'attendance.jpg',
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/api/partner/attendance',
        data: formData,
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateAttendanceStatus({
    required String status,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final payload = {
        'status': status,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      final response = await _dio.put(
        '/api/partner/attendance/status',
        data: payload,
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePartnerLocation({
    required String partnerId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.put(
        '/api/partner/attendance/$partnerId/location',
        data: {'latitude': latitude, 'longitude': longitude},
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> acceptDelivery({
    required String deliveryId,
    required String partnerId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/delivery/$deliveryId/accept',
        data: {'deliveryId': deliveryId, 'partnerId': partnerId},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> rejectDelivery({
    required String deliveryId,
    required String partnerId,
    String reason = 'Rejected by partner',
  }) async {
    try {
      final response = await _dio.put(
        '/api/delivery/$deliveryId/reject',
        data: {
          'deliveryId': deliveryId,
          'partnerId': partnerId,
          'reason': reason,
        },
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> markAsPickedUp({
    required String deliveryId,
    required String partnerId,
  }) async {
    try {
      final response = await _dio.put(
        '/api/delivery/$deliveryId/pickedup',
        data: {'deliveryId': deliveryId, 'partnerId': partnerId},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadDeliveryPhoto({
    required String deliveryId,
    required String partnerId,
    required String photoFilePath,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('deliveryId', deliveryId));
      formData.fields.add(MapEntry('partnerId', partnerId));
      formData.files.add(
        MapEntry(
          'deliveryPhoto',
          await MultipartFile.fromFile(photoFilePath, filename: 'delivery.jpg'),
        ),
      );

      final response = await _dio.put(
        '/api/delivery/$deliveryId/photo',
        data: formData,
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getDeliveryHistory({
    required String partnerId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/delivery/history',
        queryParameters: {'partnerId': partnerId},
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data['data'] ?? [] : [];
        return ApiResponse.success(
          List<Map<String, dynamic>>.from(data as List),
        );
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAttendance() async {
    try {
      final response = await _dio.get('/api/partner/attendance');

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> punchAttendance({
    required String eventType,
  }) async {
    try {
      final response = await _dio.post(
        '/attendance/punch',
        data: {
          // "fleet_uid": "FLE001", // Optional based on request, assuming it's handled by auth token or not required
          'event_type': eventType,
        },
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePartnerDetails({
    required String partnerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put(
        '/api/delivery/partner/$partnerId',
        data: data,
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getPartnerDetails({
    required String partnerId,
  }) async {
    try {
      final response = await _dio.get('/api/delivery/partner/$partnerId');

      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      debugPrint('📥 [GET RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadFile({
    required String filePath,
    required String fieldName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
        'file_name': filePath.split('/').last, // Add filename as a field
        'purpose': 'delivery_partner_document', // A generic purpose, can be refined later
      });

      final response = await _dio.post(
        '/api/partner/v1/files', // Using the endpoint found in search results
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getWorkTypes() async {
    try {
      final response = await _dio.get('/work-types');
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> requestResetPassword({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/fleet/auth/request-reset-password',
        data: {'email': email},
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> sendEmailVerification({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/firebase/send-verification',
        data: {
          'email': email,
          'redirectUrl': 'https://zenzio-39b9d.firebaseapp.com/__/auth/action'
        },
      );
      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadSingleImage({
    required String fleetUid,
    required String filePath,
    required String key, // 'type' is the key in the payload example
  }) async {
    try {
      final formData = FormData.fromMap({
        key: await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/fleets/upload-image/$fleetUid',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadDocuments({
    required String fleetUid,
    required String docType,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'fleetUid': fleetUid,
        'docType': docType,
        'files': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/fleets/upload-documents',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      debugPrint('📥 [RESPONSE] ${response.statusCode} ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data);
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
  static const String baseUrl = 'https://backend.zenzio.in';

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
        onRequest: (options, handler) {
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

  String _getErrorMessage(dynamic error, Response? response) {
    try {
      if (response != null && response.data is Map) {
        return response.data['message'] ?? 'Error occurred';
      }
    } catch (e) {}
    return error.toString();
  }

  // =========================
  // 🔹 AUTH MODULE (OLD API)
  // =========================

  Future<ApiResponse<Map<String, dynamic>>> register({
    required dynamic data, // Changed to dynamic to accept FormData
  }) async {
    try {
      final response = await _dio.post('/api/delivery/register', data: data);
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

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String emailOrMobile,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/delivery/login',
        data: {
          'emailOrMobile': emailOrMobile,
          'password': password,
        },
      );
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

  Future<ApiResponse<Map<String, dynamic>>> sendOtp({
    required String emailOrMobile,
  }) async {
    try {
      final response = await _dio.post(
        '/api/delivery/forgot-password/send-otp',
        data: {'emailOrMobile': emailOrMobile},
      );
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

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String emailOrMobile,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/api/delivery/forgot-password/verify-otp',
        data: {
          'emailOrMobile': emailOrMobile,
          'otp': otp,
        },
      );
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

  Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String emailOrMobile,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/delivery/forgot-password/reset-password',
        data: {
          'emailOrMobile': emailOrMobile,
          'newPassword': newPassword,
        },
      );
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

      if (latitude != null) formData.fields.add(MapEntry('latitude', latitude.toString()));
      if (longitude != null) formData.fields.add(MapEntry('longitude', longitude.toString()));
      if (photoFilePath != null) {
        formData.files.add(MapEntry(
          'attendancePhoto',
          await MultipartFile.fromFile(photoFilePath, filename: 'attendance.jpg'),
        ));
      }

      final response = await _dio.post('/api/partner/attendance', data: formData);

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
    required String partnerId,
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

      final response = await _dio.put('/api/partner/attendance/$partnerId/status', data: payload);

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
        data: {'deliveryId': deliveryId, 'partnerId': partnerId, 'reason': reason},
      );
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

      final response = await _dio.put('/api/delivery/$deliveryId/photo', data: formData);

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
      final response =
          await _dio.get('/api/delivery/history', queryParameters: {'partnerId': partnerId});

      if (response.statusCode == 200) {
        final data = response.data is Map ? response.data['data'] ?? [] : [];
        return ApiResponse.success(List<Map<String, dynamic>>.from(data as List));
      } else {
        return ApiResponse.error(_getErrorMessage(null, response));
      }
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e, e.response));
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }
  Future<ApiResponse<Map<String, dynamic>>> getAttendance({
    required String partnerId,
  }) async {
    try {
      final response =
          await _dio.get('/api/partner/attendance/$partnerId');

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

  Future<ApiResponse<Map<String, dynamic>>> updatePartnerDetails({
    required String partnerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put('/api/delivery/partner/$partnerId', data: data);

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
}

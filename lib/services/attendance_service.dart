import 'package:delivery_partner/models/attendance.dart';
import 'package:delivery_partner/utils/api_client.dart';
import 'package:flutter/foundation.dart';

class AttendanceService {
  final ApiClient _apiClient;

  AttendanceService(this._apiClient);

  Future<ApiResponse<DailyLogResponse>> fetchDailyLogs(String date) async {
    try {
      final response = await _apiClient.get(
        '/attendance/daily',
        queryParameters: {'date': date},
      );
      debugPrint(
        '📥 [Daily Logs RESPONSE] ${response.statusCode} ${response.data}',
      );

      if (response.success && response.data != null) {
        final dailyLogResponse = DailyLogResponse.fromJson(response.data!);
        return ApiResponse.success(dailyLogResponse);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to fetch daily logs',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ [Daily Logs ERROR] $e');
      return ApiResponse.error('Exception: $e');
    }
  }
  Future<ApiResponse<DailyLogResponse>> fetchAllLogs() async {
    try {
      final response = await _apiClient.get('/attendance/all');
      debugPrint(
        '📥 [All Logs RESPONSE] ${response.statusCode} ${response.data}',
      );

      if (response.success && response.data != null) {
        // Assuming the response structure is the same as DailyLogResponse,
        // but this should ideally be AllLogsResponse if the API changes.
        final allLogsResponse = DailyLogResponse.fromJson(response.data!);
        return ApiResponse.success(allLogsResponse);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to fetch all logs',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ [All Logs ERROR] $e');
      return ApiResponse.error('Exception: $e');
    }
  }

  Future<ApiResponse<DailySummaryResponse>> fetchDailySummary(
    String date,
  ) async {
    try {
      final response = await _apiClient.get(
        '/attendance/daily-summary',
        queryParameters: {'date': date},
      );
      debugPrint(
        '📥 [Daily Summary RESPONSE] ${response.statusCode} ${response.data}',
      );

      if (response.success && response.data != null) {
        final dailySummaryResponse = DailySummaryResponse.fromJson(
          response.data!,
        );
        return ApiResponse.success(dailySummaryResponse);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to fetch daily summary',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ [Daily Summary ERROR] $e');
      return ApiResponse.error('Exception: $e');
    }
  }

  Future<ApiResponse<HourlySummaryResponse>> fetchHourlySummary(
    String date,
  ) async {
    try {
      final response = await _apiClient.get(
        '/attendance/hourly-status',
        queryParameters: {'date': date},
      );
      debugPrint(
        '📥 [Hourly Summary RESPONSE] ${response.statusCode} ${response.data}',
      );

      if (response.success && response.data != null) {
        final hourlySummaryResponse = HourlySummaryResponse.fromJson(
          response.data!,
        );
        return ApiResponse.success(hourlySummaryResponse);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to fetch hourly summary',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ [Hourly Summary ERROR] $e');
      return ApiResponse.error('Exception: $e');
    }
  }

  Future<ApiResponse<MonthlyLogResponse>> fetchMonthlyLogs(
    int year,
    int month,
  ) async {
    try {
      final response = await _apiClient.get(
        '/attendance/monthly',
        queryParameters: {'year': year, 'month': month},
      );
      debugPrint(
        '📥 [Monthly Logs RESPONSE] ${response.statusCode} ${response.data}',
      );

      if (response.success && response.data != null) {
        final monthlyLogResponse = MonthlyLogResponse.fromJson(response.data!);
        return ApiResponse.success(monthlyLogResponse);
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to fetch monthly logs',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('❌ [Monthly Logs ERROR] $e');
      return ApiResponse.error('Exception: $e');
    }
  }
}

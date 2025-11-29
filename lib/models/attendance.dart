import 'package:json_annotation/json_annotation.dart';

part 'attendance.g.dart';

@JsonSerializable()
class AttendanceEvent {
  final String time;
  final String type;

  AttendanceEvent({required this.time, required this.type});

  factory AttendanceEvent.fromJson(Map<String, dynamic> json) =>
      _$AttendanceEventFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceEventToJson(this);
}

@JsonSerializable()
class AttendanceLogs {
  final List<AttendanceEvent> events;

  AttendanceLogs({required this.events});

  factory AttendanceLogs.fromJson(Map<String, dynamic> json) =>
      _$AttendanceLogsFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceLogsToJson(this);
}

@JsonSerializable()
class DailyLogData {
  @JsonKey(name: 'attendance_uid')
  final String attendanceUid;
  @JsonKey(name: 'fleet_uid')
  final String fleetUid;
  final String date;
  final String? status;
  final AttendanceLogs logs;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  DailyLogData({
    required this.attendanceUid,
    required this.fleetUid,
    required this.date,
    this.status,
    required this.logs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyLogData.fromJson(Map<String, dynamic> json) =>
      _$DailyLogDataFromJson(json);
  Map<String, dynamic> toJson() => _$DailyLogDataToJson(this);
}

@JsonSerializable()
class DailyLogResponse {
  final String status;
  final int code;
  final String message;
  final DailyLogData data;

  DailyLogResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory DailyLogResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyLogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DailyLogResponseToJson(this);
}

@JsonSerializable()
class DailySummaryData {
  @JsonKey(name: 'fleet_uid')
  final String fleetUid;
  final String date;
  @JsonKey(name: 'working_hours')
  final double workingHours;
  @JsonKey(name: 'break_hours')
  final double breakHours;

  DailySummaryData({
    required this.fleetUid,
    required this.date,
    required this.workingHours,
    required this.breakHours,
  });

  factory DailySummaryData.fromJson(Map<String, dynamic> json) =>
      _$DailySummaryDataFromJson(json);
  Map<String, dynamic> toJson() => _$DailySummaryDataToJson(this);
}

@JsonSerializable()
class DailySummaryResponse {
  final String status;
  final int code;
  final String message;
  final DailySummaryData data;

  DailySummaryResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory DailySummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$DailySummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DailySummaryResponseToJson(this);
}

@JsonSerializable()
class HourlyData {
  final String hour;
  @JsonKey(name: 'working_minutes')
  final double workingMinutes;
  @JsonKey(name: 'break_minutes')
  final double breakMinutes;
  @JsonKey(name: 'offline_minutes')
  final double offlineMinutes;

  HourlyData({
    required this.hour,
    required this.workingMinutes,
    required this.breakMinutes,
    required this.offlineMinutes,
  });

  factory HourlyData.fromJson(Map<String, dynamic> json) =>
      _$HourlyDataFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyDataToJson(this);
}

@JsonSerializable()
class HourlyTotals {
  @JsonKey(name: 'working_hours')
  final double workingHours;
  @JsonKey(name: 'break_hours')
  final double breakHours;
  @JsonKey(name: 'offline_hours')
  final double offlineHours;

  HourlyTotals({
    required this.workingHours,
    required this.breakHours,
    required this.offlineHours,
  });

  factory HourlyTotals.fromJson(Map<String, dynamic> json) =>
      _$HourlyTotalsFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyTotalsToJson(this);
}

@JsonSerializable()
class HourlySummaryData {
  @JsonKey(name: 'fleet_uid')
  final String fleetUid;
  final String date;
  final List<HourlyData> hourly;
  final HourlyTotals totals;

  HourlySummaryData({
    required this.fleetUid,
    required this.date,
    required this.hourly,
    required this.totals,
  });

  factory HourlySummaryData.fromJson(Map<String, dynamic> json) =>
      _$HourlySummaryDataFromJson(json);
  Map<String, dynamic> toJson() => _$HourlySummaryDataToJson(this);
}

@JsonSerializable()
class HourlySummaryResponse {
  final String status;
  final int code;
  final String message;
  final HourlySummaryData data;

  HourlySummaryResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory HourlySummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$HourlySummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HourlySummaryResponseToJson(this);
}

@JsonSerializable()
class MonthlyLogData {
  @JsonKey(name: 'attendance_uid')
  final String attendanceUid;
  @JsonKey(name: 'fleet_uid')
  final String fleetUid;
  final String date;
  final AttendanceLogs logs;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  MonthlyLogData({
    required this.attendanceUid,
    required this.fleetUid,
    required this.date,
    required this.logs,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonthlyLogData.fromJson(Map<String, dynamic> json) =>
      _$MonthlyLogDataFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyLogDataToJson(this);
}

@JsonSerializable()
class MonthlyLogResponse {
  final String status;
  final int code;
  final String message;
  final List<MonthlyLogData> data;

  MonthlyLogResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory MonthlyLogResponse.fromJson(Map<String, dynamic> json) =>
      _$MonthlyLogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyLogResponseToJson(this);
}

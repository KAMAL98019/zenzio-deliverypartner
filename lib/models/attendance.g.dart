// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceEvent _$AttendanceEventFromJson(Map<String, dynamic> json) =>
    AttendanceEvent(time: json['time'] as String, type: json['type'] as String);

Map<String, dynamic> _$AttendanceEventToJson(AttendanceEvent instance) =>
    <String, dynamic>{'time': instance.time, 'type': instance.type};

AttendanceLogs _$AttendanceLogsFromJson(Map<String, dynamic> json) =>
    AttendanceLogs(
      events: (json['events'] as List<dynamic>)
          .map((e) => AttendanceEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AttendanceLogsToJson(AttendanceLogs instance) =>
    <String, dynamic>{'events': instance.events};

DailyLogData _$DailyLogDataFromJson(Map<String, dynamic> json) => DailyLogData(
  attendanceUid: json['attendance_uid'] as String,
  fleetUid: json['fleet_uid'] as String,
  date: json['date'] as String,
  status: json['status'] as String?,
  logs: AttendanceLogs.fromJson(json['logs'] as Map<String, dynamic>),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$DailyLogDataToJson(DailyLogData instance) =>
    <String, dynamic>{
      'attendance_uid': instance.attendanceUid,
      'fleet_uid': instance.fleetUid,
      'date': instance.date,
      'status': instance.status,
      'logs': instance.logs,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

DailyLogResponse _$DailyLogResponseFromJson(Map<String, dynamic> json) =>
    DailyLogResponse(
      status: json['status'] as String,
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data: DailyLogData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DailyLogResponseToJson(DailyLogResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

DailySummaryData _$DailySummaryDataFromJson(Map<String, dynamic> json) =>
    DailySummaryData(
      fleetUid: json['fleet_uid'] as String,
      date: json['date'] as String,
      workingHours: (json['working_hours'] as num).toDouble(),
      breakHours: (json['break_hours'] as num).toDouble(),
    );

Map<String, dynamic> _$DailySummaryDataToJson(DailySummaryData instance) =>
    <String, dynamic>{
      'fleet_uid': instance.fleetUid,
      'date': instance.date,
      'working_hours': instance.workingHours,
      'break_hours': instance.breakHours,
    };

DailySummaryResponse _$DailySummaryResponseFromJson(
  Map<String, dynamic> json,
) => DailySummaryResponse(
  status: json['status'] as String,
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: DailySummaryData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DailySummaryResponseToJson(
  DailySummaryResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

HourlyData _$HourlyDataFromJson(Map<String, dynamic> json) => HourlyData(
  hour: json['hour'] as String,
  workingMinutes: (json['working_minutes'] as num).toDouble(),
  breakMinutes: (json['break_minutes'] as num).toDouble(),
  offlineMinutes: (json['offline_minutes'] as num).toDouble(),
);

Map<String, dynamic> _$HourlyDataToJson(HourlyData instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'working_minutes': instance.workingMinutes,
      'break_minutes': instance.breakMinutes,
      'offline_minutes': instance.offlineMinutes,
    };

HourlyTotals _$HourlyTotalsFromJson(Map<String, dynamic> json) => HourlyTotals(
  workingHours: (json['working_hours'] as num).toDouble(),
  breakHours: (json['break_hours'] as num).toDouble(),
  offlineHours: (json['offline_hours'] as num).toDouble(),
);

Map<String, dynamic> _$HourlyTotalsToJson(HourlyTotals instance) =>
    <String, dynamic>{
      'working_hours': instance.workingHours,
      'break_hours': instance.breakHours,
      'offline_hours': instance.offlineHours,
    };

HourlySummaryData _$HourlySummaryDataFromJson(Map<String, dynamic> json) =>
    HourlySummaryData(
      fleetUid: json['fleet_uid'] as String,
      date: json['date'] as String,
      hourly: (json['hourly'] as List<dynamic>)
          .map((e) => HourlyData.fromJson(e as Map<String, dynamic>))
          .toList(),
      totals: HourlyTotals.fromJson(json['totals'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HourlySummaryDataToJson(HourlySummaryData instance) =>
    <String, dynamic>{
      'fleet_uid': instance.fleetUid,
      'date': instance.date,
      'hourly': instance.hourly,
      'totals': instance.totals,
    };

HourlySummaryResponse _$HourlySummaryResponseFromJson(
  Map<String, dynamic> json,
) => HourlySummaryResponse(
  status: json['status'] as String,
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data: HourlySummaryData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HourlySummaryResponseToJson(
  HourlySummaryResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};

MonthlyLogData _$MonthlyLogDataFromJson(Map<String, dynamic> json) =>
    MonthlyLogData(
      attendanceUid: json['attendance_uid'] as String,
      fleetUid: json['fleet_uid'] as String,
      date: json['date'] as String,
      logs: AttendanceLogs.fromJson(json['logs'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$MonthlyLogDataToJson(MonthlyLogData instance) =>
    <String, dynamic>{
      'attendance_uid': instance.attendanceUid,
      'fleet_uid': instance.fleetUid,
      'date': instance.date,
      'logs': instance.logs,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

MonthlyLogResponse _$MonthlyLogResponseFromJson(Map<String, dynamic> json) =>
    MonthlyLogResponse(
      status: json['status'] as String,
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => MonthlyLogData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MonthlyLogResponseToJson(MonthlyLogResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

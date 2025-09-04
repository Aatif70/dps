import 'dart:convert';
import 'dart:developer';
import 'package:AES/constants/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<AttendanceResponse?> getStudentAttendance({
    required String attDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      debugPrint('=== ATTENDANCE SERVICE DEBUG START ===');
      debugPrint('All SharedPreferences keys: ${prefs.getKeys()}');

      // Safe retrieval that handles both string and int types
      String uid = '';
      dynamic idValue;

      // Check if Uid exists and get its value regardless of type
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        debugPrint('Uid raw value: $uidValue (type: ${uidValue.runtimeType})');
        uid = uidValue.toString();
      }

      // Check if Id exists and get its value regardless of type
      if (prefs.containsKey('Id')) {
        idValue = prefs.get('Id');
        debugPrint('Id raw value: $idValue (type: ${idValue.runtimeType})');
      }

      debugPrint('Attendance Service - Processed Uid: $uid');
      debugPrint('Attendance Service - Id value for request: $idValue');

      if (uid.isEmpty || idValue == null) {
        debugPrint('ERROR: Uid or Id not found in SharedPreferences');
        return null;
      }

      final studentId = idValue.toString();
      final url = Uri.parse(
          '$baseUrl/api/User/StudentAttendanceList?studentid=$studentId&AttDate=$attDate'
      );

      debugPrint('=== ATTENDANCE API CALL ===');
      debugPrint('URL: $url');
      debugPrint('Student ID: $studentId');
      debugPrint('Attendance Date: $attDate');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('=== ATTENDANCE API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('=== PARSED JSON DATA ===');
        debugPrint('Success: ${jsonData['success']}');
        debugPrint('Attendance List Count: ${jsonData['AttendanceList']?.length ?? 0}');

        if (jsonData['success'] == true && jsonData['AttendanceList'] != null) {
          final attendanceResponse = AttendanceResponse.fromJson(jsonData);
          debugPrint('=== ATTENDANCE RECORDS ===');
          // for (int i = 0; i < attendanceResponse.attendanceList.length; i++) {
          //   final record = attendanceResponse.attendanceList[i];
          //   debugPrint('Record $i: ${record.subject} - ${record.status} (${record.fromTime}-${record.toTime})');
          // }
          return attendanceResponse;
        } else {
          debugPrint('API returned success=false or null attendance list');
          return null;
        }
      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
        debugPrint('Error body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('=== ATTENDANCE API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<Map<String, double>> getMonthlyAttendanceStats({
    required int year,
    required int month,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Safe retrieval that handles both string and int types
      dynamic idValue;

      // Check if Id exists and get its value regardless of type
      if (prefs.containsKey('Id')) {
        idValue = prefs.get('Id');
        debugPrint('Id raw value: $idValue (type: ${idValue.runtimeType})');
      }

      if (idValue == null) {
        debugPrint('ERROR: Id not found in SharedPreferences');
        return {
          'totalDays': 0.0,
          'presentDays': 0.0,
          'attendancePercentage': 0.0,
        };
      }

      final studentId = idValue.toString();
      debugPrint('=== GETTING MONTHLY STATS ===');
      debugPrint('Student ID: $studentId, Year: $year, Month: $month');

      final daysInMonth = DateTime(year, month + 1, 0).day;
      int totalDays = 0;
      int presentDays = 0;

      // Get attendance for each day of the month
      // for (int day = 1; day <= daysInMonth; day++) {
      //   final date = DateTime(year, month, day);
      //   final dateString = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      //
      //   final attendanceResponse = await getStudentAttendance(
      //     attDate: dateString,
      //   );
      //
      //   if (attendanceResponse != null && attendanceResponse.attendanceList.isNotEmpty) {
      //     totalDays++;
      //     // Count as present if any subject shows present
      //     bool hasPresent = attendanceResponse.attendanceList.any(
      //             (record) => record.status.toLowerCase() == 'present'
      //     );
      //     if (hasPresent) {
      //       presentDays++;
      //     }
      //   }
      //
      //   // Add small delay to avoid overwhelming the API
      //   await Future.delayed(const Duration(milliseconds: 100));
      // }

      final attendancePercentage = totalDays > 0 ? presentDays / totalDays : 0.0;

      debugPrint('=== MONTHLY STATS RESULT ===');
      debugPrint('Total Days: $totalDays');
      debugPrint('Present Days: $presentDays');
      debugPrint('Attendance Percentage: ${(attendancePercentage * 100).toStringAsFixed(1)}%');

      return {
        'totalDays': totalDays.toDouble(),
        'presentDays': presentDays.toDouble(),
        'attendancePercentage': attendancePercentage,
      };
    } catch (e) {
      debugPrint('=== MONTHLY STATS ERROR ===');
      debugPrint('Error: $e');
      return {
        'totalDays': 0.0,
        'presentDays': 0.0,
        'attendancePercentage': 0.0,
      };
    }
  }
}

// Data Models
class AttendanceResponse {
  final bool success;
  final List<AttendanceRecord> attendanceList;

  AttendanceResponse({
    required this.success,
    required this.attendanceList,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      attendanceList: (json['AttendanceList'] as List<dynamic>?)
          ?.map((item) => AttendanceRecord.fromJson(item))
          .toList() ?? [],
    );
  }
}

class AttendanceRecord {
  final String attDate;
  final String subject;
  final String fromTime;
  final String toTime;
  final String status;

  AttendanceRecord({
    required this.attDate,
    required this.subject,
    required this.fromTime,
    required this.toTime,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      attDate: json['AttDate'] ?? '',
      subject: json['Subject'] ?? '',
      fromTime: json['FromTime'] ?? '',
      toTime: json['ToTime'] ?? '',
      status: json['Status'] ?? '',
    );
  }

  DateTime get date => DateTime.parse(attDate);

  AttendanceStatus get attendanceStatus {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.present;
    }
  }
}

enum AttendanceStatus { present, absent, late, holiday }

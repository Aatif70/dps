import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class TimetableService {
  static Future<List<TimetableRecord>> getStudentTimetable() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      debugPrint('=== TIMETABLE SERVICE DEBUG START ===');
      debugPrint('All SharedPreferences keys: ${prefs.getKeys()}');

      // Safe retrieval that handles both string and int types
      String uid = '';

      // Check if Uid exists and get its value regardless of type
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        debugPrint('Uid raw value: $uidValue (type: ${uidValue.runtimeType})');
        uid = uidValue.toString();
      }

      debugPrint('Timetable Service - Processed Uid: $uid');

      if (uid.isEmpty) {
        debugPrint('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentTimetable}');
      debugPrint('Timetable Service - Request URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;

      debugPrint('Timetable Service - Multipart fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Timetable Service - Response status: ${response.statusCode}');
      debugPrint('Timetable Service - Response headers: ${response.headers}');
      debugPrint('Timetable Service - Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('=== PARSED JSON DATA ===');
        debugPrint('Success: ${jsonData['success']}');
        debugPrint('Data Count: ${jsonData['data']?.length ?? 0}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> dataList = jsonData['data'];
          final List<TimetableRecord> timetableRecords = dataList
              .map((item) => TimetableRecord.fromJson(item))
              .toList();

          debugPrint('=== TIMETABLE RECORDS ===');
          for (int i = 0; i < timetableRecords.length; i++) {
            final record = timetableRecords[i];
            debugPrint('Record $i: ${record.subject} - ${record.weekDay} (${record.fromTime}-${record.toTime})');
          }

          return timetableRecords;
        } else {
          debugPrint('API returned success=false or null data');
          return [];
        }
      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
        debugPrint('Error body: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint('=== TIMETABLE API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
}

// Data Models
class TimetableRecord {
  final int timeTableId;
  final String courseName;
  final String className;
  final String batch;
  final String division;
  final String teacherName;
  final String subject;
  final String weekDay;
  final String fromTime;
  final String toTime;
  final String subType;

  TimetableRecord({
    required this.timeTableId,
    required this.courseName,
    required this.className,
    required this.batch,
    required this.division,
    required this.teacherName,
    required this.subject,
    required this.weekDay,
    required this.fromTime,
    required this.toTime,
    required this.subType,
  });

  factory TimetableRecord.fromJson(Map<String, dynamic> json) {
    return TimetableRecord(
      timeTableId: json['TimeTableId'] ?? 0,
      courseName: json['CourseName'] ?? '',
      className: json['Class'] ?? '',
      batch: json['Batch'] ?? '',
      division: json['Division'] ?? '',
      teacherName: json['TeacherName'] ?? '',
      subject: json['Subject'] ?? '',
      weekDay: json['WeekDay'] ?? '',
      fromTime: json['FromTime'] ?? '',
      toTime: json['ToTime'] ?? '',
      subType: json['SubType'] ?? '',
    );
  }

  // Helper method to get day index for sorting
  int get dayIndex {
    const dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return dayOrder.indexOf(weekDay);
  }

  // Helper method to get time in minutes for sorting
  int get timeInMinutes {
    final fromParts = fromTime.split(':');
    return int.parse(fromParts[0]) * 60 + int.parse(fromParts[1]);
  }
} 
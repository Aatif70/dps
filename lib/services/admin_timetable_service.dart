import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class AdminTimetableService {
  static Future<List<TeacherTimetableData>> getTeacherTimetables() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/TimeTable');
      final request = http.MultipartRequest('GET', url);
      request.fields['UId'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((json) => TeacherTimetableData.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching teacher timetables: $e');
      return [];
    }
  }
}

class TeacherTimetableData {
  final int empId;
  final String teacherName;
  final List<TimetableEntry> timetables;

  TeacherTimetableData({
    required this.empId,
    required this.teacherName,
    required this.timetables,
  });

  factory TeacherTimetableData.fromJson(Map<String, dynamic> json) {
    return TeacherTimetableData(
      empId: json['EmpId'] ?? 0,
      teacherName: json['TeacherName'] ?? '',
      timetables: (json['TimeTables'] as List<dynamic>?)
          ?.map((item) => TimetableEntry.fromJson(item))
          .toList() ?? [],
    );
  }
}

class TimetableEntry {
  final int timeTableId;
  final int empId;
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

  TimetableEntry({
    required this.timeTableId,
    required this.empId,
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

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      timeTableId: json['TimeTableId'] ?? 0,
      empId: json['EmpId'] ?? 0,
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
}

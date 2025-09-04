import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:AES/constants/api_constants.dart';

class StudentMetrics {
  final int totalStudent;
  final List<dynamic> todayAttendance; // shape not specified

  StudentMetrics({required this.totalStudent, required this.todayAttendance});

  factory StudentMetrics.fromJson(Map<String, dynamic> json) {
    return StudentMetrics(
      totalStudent: json['TotalStudent'] is int ? json['TotalStudent'] as int : int.tryParse(json['TotalStudent'].toString()) ?? 0,
      todayAttendance: (json['TodayAttendance'] as List?) ?? const [],
    );
  }
}

class AdminStudentMetricsService {
  static Future<StudentMetrics?> fetchStudentMetrics({required String academicYear}) async {
    final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.studentCount)
        .replace(queryParameters: {'academicYear': academicYear});
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;
    final Map<String, dynamic> res = jsonDecode(response.body);
    if (res['success'] != true || res['data'] == null) return null;
    return StudentMetrics.fromJson(res['data'] as Map<String, dynamic>);
  }
}



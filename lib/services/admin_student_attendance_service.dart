import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

class AdminStudentAttendanceService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Get batches for the admin user
  static Future<List<BatchData>> getBatches() async {
    try {
      debugPrint('=== GETTING BATCHES ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        debugPrint('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('Uid: $uid');

      final url = Uri.parse('$baseUrl${ApiConstants.adminBatches}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;

      debugPrint('Batches API URL: $url');

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      debugPrint('Batches API Response Status: ${response.statusCode}');
      debugPrint('Batches API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> batches = jsonData['data'];
          final result = batches.map((b) => BatchData.fromJson(b as Map<String, dynamic>)).toList();
          debugPrint('Successfully parsed ${result.length} batches');
          return result;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting batches: $e');
      return [];
    }
  }

  // Get divisions by class ID
  static Future<List<DivisionData>> getDivisionsByClass(int classId) async {
    try {
      debugPrint('=== GETTING DIVISIONS BY CLASS ===');
      debugPrint('ClassId: $classId');

      final url = Uri.parse('$baseUrl/api/Students/DivByClass?ClassId=$classId');
      
      debugPrint('Divisions API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('Divisions API Response Status: ${response.statusCode}');
      debugPrint('Divisions API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final result = jsonData.map((d) => DivisionData.fromJson(d as Map<String, dynamic>)).toList();
        debugPrint('Successfully parsed ${result.length} divisions');
        return result;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting divisions: $e');
      return [];
    }
  }

  // Get class-wise attendance
  static Future<ClassAttendanceData?> getClassAttendance({
    required int month,
    required int year,
    required int classId,
    required int divisionId,
  }) async {
    try {
      debugPrint('=== GETTING CLASS ATTENDANCE ===');
      debugPrint('Month: $month, Year: $year, ClassId: $classId, DivisionId: $divisionId');

      final url = Uri.parse('$baseUrl/api/Students/classwiseattendance?month=$month&year=$year&classId=$classId&divisionId=$divisionId');
      
      debugPrint('Class Attendance API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('Class Attendance API Response Status: ${response.statusCode}');
      debugPrint('Class Attendance API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final result = ClassAttendanceData.fromJson(jsonData['data'] as Map<String, dynamic>);
          debugPrint('Successfully parsed class attendance data');
          return result;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting class attendance: $e');
      return null;
    }
  }

  // Get student attendance by date or month/year
  static Future<StudentAttendanceData?> getStudentAttendance({
    required String filterOption,
    String? selectedDate,
    int? month,
    int? year,
  }) async {
    try {
      debugPrint('=== GETTING STUDENT ATTENDANCE ===');
      debugPrint('FilterOption: $filterOption, SelectedDate: $selectedDate, Month: $month, Year: $year');

      String url;
      if (filterOption == 'date' && selectedDate != null) {
        url = '$baseUrl/api/Students/GetAttendance?filterOption=$filterOption&selectedDate=$selectedDate';
      } else if (filterOption == 'monthYear' && month != null && year != null) {
        url = '$baseUrl/api/Students/GetAttendance?filterOption=$filterOption&month=$month&year=$year';
      } else {
        debugPrint('ERROR: Invalid parameters for filter option');
        return null;
      }
      
      debugPrint('Student Attendance API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('Student Attendance API Response Status: ${response.statusCode}');
      debugPrint('Student Attendance API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['result'] != null) {
          final result = StudentAttendanceData.fromJson(jsonData);
          debugPrint('Successfully parsed student attendance data');
          return result;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting student attendance: $e');
      return null;
    }
  }
}

class BatchData {
  final int classId;
  final int classMasterId;
  final int courseYear;
  final String batchName;

  BatchData({
    required this.classId,
    required this.classMasterId,
    required this.courseYear,
    required this.batchName,
  });

  factory BatchData.fromJson(Map<String, dynamic> json) {
    return BatchData(
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      classMasterId: int.tryParse((json['ClassMasterId'] ?? '0').toString()) ?? 0,
      courseYear: int.tryParse((json['CourseYear'] ?? '0').toString()) ?? 0,
      batchName: (json['BatchName'] ?? '').toString(),
    );
  }

  @override
  String toString() {
    return 'BatchData{classId: $classId, classMasterId: $classMasterId, courseYear: $courseYear, batchName: $batchName}';
  }
}

class DivisionData {
  final int divisionId;
  final String name;

  DivisionData({
    required this.divisionId,
    required this.name,
  });

  factory DivisionData.fromJson(Map<String, dynamic> json) {
    return DivisionData(
      divisionId: int.tryParse((json['DivisionId'] ?? '0').toString()) ?? 0,
      name: (json['Name'] ?? '').toString(),
    );
  }

  @override
  String toString() {
    return 'DivisionData{divisionId: $divisionId, name: $name}';
  }
}

class ClassAttendanceData {
  final int classId;
  final int divisionId;
  final int totalPresent;
  final int totalAbsent;
  final List<TopStudent> topStudents;

  ClassAttendanceData({
    required this.classId,
    required this.divisionId,
    required this.totalPresent,
    required this.totalAbsent,
    required this.topStudents,
  });

  factory ClassAttendanceData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> topStudentsList = json['TopStudents'] as List<dynamic>? ?? [];
    return ClassAttendanceData(
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      divisionId: int.tryParse((json['DivisionId'] ?? '0').toString()) ?? 0,
      totalPresent: int.tryParse((json['TotalPresent'] ?? '0').toString()) ?? 0,
      totalAbsent: int.tryParse((json['TotalAbsent'] ?? '0').toString()) ?? 0,
      topStudents: topStudentsList.map((s) => TopStudent.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }

  int get totalStudents => totalPresent + totalAbsent;
  double get attendancePercentage => totalStudents > 0 ? (totalPresent / totalStudents) * 100 : 0;

  @override
  String toString() {
    return 'ClassAttendanceData{classId: $classId, divisionId: $divisionId, totalPresent: $totalPresent, totalAbsent: $totalAbsent, topStudents: ${topStudents.length}}';
  }
}

class TopStudent {
  final int studentId;
  final String studentName;
  final int presentDays;

  TopStudent({
    required this.studentId,
    required this.studentName,
    required this.presentDays,
  });

  factory TopStudent.fromJson(Map<String, dynamic> json) {
    return TopStudent(
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      studentName: (json['StudentName'] ?? '').toString(),
      presentDays: int.tryParse((json['PresentDays'] ?? '0').toString()) ?? 0,
    );
  }

  @override
  String toString() {
    return 'TopStudent{studentId: $studentId, studentName: $studentName, presentDays: $presentDays}';
  }
}

class StudentAttendanceData {
  final bool success;
  final String filterOption;
  final String? selectedDate;
  final int? selectedMonth;
  final int? selectedYear;
  final List<ClassAttendanceResult> result;

  StudentAttendanceData({
    required this.success,
    required this.filterOption,
    this.selectedDate,
    this.selectedMonth,
    this.selectedYear,
    required this.result,
  });

  factory StudentAttendanceData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> resultList = json['result'] as List<dynamic>? ?? [];
    return StudentAttendanceData(
      success: json['success'] == true,
      filterOption: (json['filterOption'] ?? '').toString(),
      selectedDate: json['selectedDate']?.toString(),
      selectedMonth: json['selectedMonth'] != null ? int.tryParse(json['selectedMonth'].toString()) : null,
      selectedYear: json['selectedYear'] != null ? int.tryParse(json['selectedYear'].toString()) : null,
      result: resultList.map((r) => ClassAttendanceResult.fromJson(r as Map<String, dynamic>)).toList(),
    );
  }

  @override
  String toString() {
    return 'StudentAttendanceData{success: $success, filterOption: $filterOption, selectedDate: $selectedDate, selectedMonth: $selectedMonth, selectedYear: $selectedYear, result: ${result.length}}';
  }
}

class ClassAttendanceResult {
  final int id;
  final String className;
  final int presentCount;
  final int absentCount;

  ClassAttendanceResult({
    required this.id,
    required this.className,
    required this.presentCount,
    required this.absentCount,
  });

  factory ClassAttendanceResult.fromJson(Map<String, dynamic> json) {
    return ClassAttendanceResult(
      id: int.tryParse((json['Id'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
      presentCount: int.tryParse((json['PresentCount'] ?? '0').toString()) ?? 0,
      absentCount: int.tryParse((json['AbsentCount'] ?? '0').toString()) ?? 0,
    );
  }

  int get totalStudents => presentCount + absentCount;
  double get attendancePercentage => totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;

  @override
  String toString() {
    return 'ClassAttendanceResult{id: $id, className: $className, presentCount: $presentCount, absentCount: $absentCount}';
  }
}

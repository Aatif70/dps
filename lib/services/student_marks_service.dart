import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

class StudentMarksService {
  static Future<List<StudentExam>> getStudentExams() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      int? classId;
      if (prefs.containsKey('ClassId')) {
        final value = prefs.get('ClassId');
        if (value is int) {
          classId = value;
        } else {
          classId = int.tryParse(value.toString());
        }
      }

      if (classId == null) {
        debugPrint('ERROR: Missing ClassId in preferences');
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentExamList}?ClassId=$classId');
      debugPrint('StudentExam list URL: $url');

      final response = await http.get(url);
      debugPrint('StudentExam list status: ${response.statusCode}');
      debugPrint('StudentExam list body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((e) => StudentExam.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e, st) {
      debugPrint('Error fetching student exams: $e\n$st');
      return [];
    }
  }

  static Future<List<StudentSubjectMark>> getStudentMarks({required int examId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String uid = '';
      if (prefs.containsKey('Uid')) {
        uid = prefs.get('Uid').toString();
      }

      if (uid.isEmpty) {
        debugPrint('ERROR: Missing Uid in preferences');
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentExamMarks}');
      debugPrint('StudentExamMarks URL: $url');

      var request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['ExamId'] = examId.toString();

      debugPrint('StudentExamMarks fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('StudentExamMarks status: ${response.statusCode}');
      debugPrint('StudentExamMarks body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((e) => StudentSubjectMark.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e, st) {
      debugPrint('Error fetching student marks: $e\n$st');
      return [];
    }
  }
}

class StudentExam {
  final int examId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime resultDate;
  final List<StudentExamSubject> subjects;

  StudentExam({
    required this.examId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.resultDate,
    required this.subjects,
  });

  factory StudentExam.fromJson(Map<String, dynamic> json) {
    return StudentExam(
      examId: _safeInt(json['ExamId']),
      title: _safeString(json['Title']),
      description: _safeString(json['Description']),
      startDate: _safeDate(json['StartDate']),
      endDate: _safeDate(json['EndDate']),
      resultDate: _safeDate(json['ResultDate']),
      subjects: (json['Subjects'] as List<dynamic>? ?? [])
          .map((e) => StudentExamSubject.fromJson(e))
          .toList(),
    );
  }
}

class StudentExamSubject {
  final String subjectName;
  final DateTime paperDate;
  final int minMarks;
  final int maxMarks;

  StudentExamSubject({
    required this.subjectName,
    required this.paperDate,
    required this.minMarks,
    required this.maxMarks,
  });

  factory StudentExamSubject.fromJson(Map<String, dynamic> json) {
    return StudentExamSubject(
      subjectName: _safeString(json['SubjectName']),
      paperDate: _safeDate(json['PaperDate']),
      minMarks: _safeInt(json['MinMarks']),
      maxMarks: _safeInt(json['MaxMarks']),
    );
  }
}

class StudentSubjectMark {
  final int studentId;
  final int examSubId;
  final int theoryMarks;
  final int minMarks;
  final int maxMarks;
  final String status;
  final int practicalMarks;
  final int pMinMarks;
  final int pMaxMarks;
  final bool isPrac;
  final String subjectName;

  StudentSubjectMark({
    required this.studentId,
    required this.examSubId,
    required this.theoryMarks,
    required this.minMarks,
    required this.maxMarks,
    required this.status,
    required this.practicalMarks,
    required this.pMinMarks,
    required this.pMaxMarks,
    required this.isPrac,
    required this.subjectName,
  });

  factory StudentSubjectMark.fromJson(Map<String, dynamic> json) {
    return StudentSubjectMark(
      studentId: _safeInt(json['StudentId']),
      examSubId: _safeInt(json['ExamSubId']),
      theoryMarks: _safeInt(json['TheoryMarks']),
      minMarks: _safeInt(json['MinMarks']),
      maxMarks: _safeInt(json['MaxMarks']),
      status: _safeString(json['Status']),
      practicalMarks: _safeInt(json['PracticalMarks']),
      pMinMarks: _safeInt(json['PMinMarks']),
      pMaxMarks: _safeInt(json['PMaxMarks']),
      isPrac: json['IsPrac'] == true,
      subjectName: _safeString(json['SubjectName']),
    );
  }

  double get totalMarks => theoryMarks + practicalMarks.toDouble();
  double get percentage => maxMarks > 0 ? (totalMarks / maxMarks) * 100.0 : 0.0;
}

int _safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _safeString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

DateTime _safeDate(dynamic value) {
  if (value == null) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return DateTime.now();
  }
}



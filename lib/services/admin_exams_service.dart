import 'dart:convert';

import 'package:AES/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class AdminExamItem {
  final int examId;
  final int type;
  final String title;
  final String session;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? resultDate;
  final bool isActive;
  final int classId;
  final String className;

  AdminExamItem({
    required this.examId,
    required this.type,
    required this.title,
    required this.session,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.resultDate,
    required this.isActive,
    required this.classId,
    required this.className,
  });

  factory AdminExamItem.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? s) {
      if (s == null || s.isEmpty) return null;
      try { return DateTime.parse(s); } catch (_) { return null; }
    }
    return AdminExamItem(
      examId: int.tryParse((json['ExamId'] ?? '0').toString()) ?? 0,
      type: int.tryParse((json['Type'] ?? '0').toString()) ?? 0,
      title: (json['Title'] ?? '').toString(),
      session: (json['Session'] ?? '').toString(),
      description: (json['Description'] ?? '').toString(),
      startDate: parse(json['StartDate']?.toString()),
      endDate: parse(json['EndDate']?.toString()),
      resultDate: parse(json['ResultDate']?.toString()),
      isActive: (json['IsActive'] as bool?) ?? false,
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
    );
  }
}

class ExamMarksItem {
  final int id;
  final int studentId;
  final String name;
  final List<ExamSubjectMark> subMarks;

  ExamMarksItem({
    required this.id,
    required this.studentId,
    required this.name,
    required this.subMarks,
  });

  factory ExamMarksItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> sub = (json['SubMarks'] as List<dynamic>? ?? <dynamic>[]);
    return ExamMarksItem(
      id: int.tryParse((json['Id'] ?? '0').toString()) ?? 0,
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      name: (json['Name'] ?? '').toString(),
      subMarks: sub.map((e) => ExamSubjectMark.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ExamSubjectMark {
  final int subId;
  final String subjectName;
  final int minMarks;
  final int maxMarks;
  final int attemptMarks;
  final String statusName;
  final bool isPrac;

  ExamSubjectMark({
    required this.subId,
    required this.subjectName,
    required this.minMarks,
    required this.maxMarks,
    required this.attemptMarks,
    required this.statusName,
    required this.isPrac,
  });

  factory ExamSubjectMark.fromJson(Map<String, dynamic> json) {
    return ExamSubjectMark(
      subId: int.tryParse((json['ExamSubId'] ?? '0').toString()) ?? 0,
      subjectName: (json['SubjectName'] ?? json['Name'] ?? '').toString(),
      minMarks: int.tryParse((json['MinMarks'] ?? '0').toString()) ?? 0,
      maxMarks: int.tryParse((json['MaxMarks'] ?? '0').toString()) ?? 0,
      attemptMarks: int.tryParse((json['AttemptMarks'] ?? '0').toString()) ?? 0,
      statusName: (json['StatusName'] ?? '').toString(),
      isPrac: (json['IsPrac'] as bool?) ?? false,
    );
  }
}

class AdminExamsService {
  static Future<List<AdminExamItem>> fetchExams() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.internalExams}');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final decoded = json.decode(res.body) as Map<String, dynamic>;
    if (decoded['success'] == true && decoded['data'] is List) {
      final List<dynamic> data = decoded['data'] as List<dynamic>;
      return data.map((e) => AdminExamItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<List<ExamMarksItem>> fetchExamMarks({required int examId}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.internalExamMarks}?Id=$examId');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final decoded = json.decode(res.body) as Map<String, dynamic>;
    if (decoded['success'] == true && decoded['data'] is List) {
      final List<dynamic> data = decoded['data'] as List<dynamic>;
      return data.map((e) => ExamMarksItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}



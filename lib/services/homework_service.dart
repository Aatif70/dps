import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';
import 'package:intl/intl.dart';

class HomeworkService {
  static Future<List<StudentHomeworkRecord>> getStudentHomework({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('=== HOMEWORK SERVICE DEBUG START ===');
      print('All SharedPreferences keys: ${prefs.getKeys()}');

      // Safe retrieval that handles both string and int types
      String uid = '';
      dynamic idValue;

      // Check if Uid exists and get its value regardless of type
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        print('Uid raw value: $uidValue (type: ${uidValue.runtimeType})');
        uid = uidValue.toString();
      }

      // Check if Id exists and get its value regardless of type
      if (prefs.containsKey('Id')) {
        idValue = prefs.get('Id');
        print('Id raw value: $idValue (type: ${idValue.runtimeType})');
      }

      print('Homework Service - Processed Uid: $uid');
      print('Homework Service - Id value for request: $idValue');

      if (uid.isEmpty || idValue == null) {
        print('ERROR: Uid or Id not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentHomework}');
      print('Homework Service - Request URL: $url');

      // Format dates as dd-MM-yyyy
      final fromDateStr = DateFormat('dd-MM-yyyy').format(fromDate);
      final toDateStr = DateFormat('dd-MM-yyyy').format(toDate);

      print('Homework Service - Date range: $fromDateStr to $toDateStr');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['StudentId'] = idValue.toString();
      request.fields['FD'] = fromDateStr;
      request.fields['TD'] = toDateStr;

      print('Homework Service - Multipart fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Homework Service - Response status: ${response.statusCode}');
      print('Homework Service - Response headers: ${response.headers}');
      print('Homework Service - Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Homework Service - Parsed JSON response: $jsonResponse');

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          print('Homework Service - Data array length: ${data.length}');

          List<StudentHomeworkRecord> homeworkRecords = [];

          for (int i = 0; i < data.length; i++) {
            try {
              print('--- Processing homework record $i ---');
              final item = data[i];
              print('Raw item data: $item');

              final homeworkRecord = StudentHomeworkRecord.fromJson(item);
              print('Successfully parsed homework record $i: ${homeworkRecord.subject}');
              homeworkRecords.add(homeworkRecord);
            } catch (e, stackTrace) {
              print('ERROR parsing homework record $i: $e');
              print('Stack trace: $stackTrace');
              print('Failed item data: ${data[i]}');
            }
          }

          print('Homework Service - Successfully parsed ${homeworkRecords.length} out of ${data.length} records');
          print('=== HOMEWORK SERVICE DEBUG END ===');
          return homeworkRecords;
        } else {
          print('API returned success: false or no data');
          return [];
        }
      } else {
        print('Failed to load student homework. Status code: ${response.statusCode}');
        print('Error response body: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('Error fetching student homework: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}

// Data model for student homework API response
class StudentHomeworkRecord {
  final String className;
  final String batch;
  final String employee;
  final String subject;
  final String division;
  final String homework;
  final DateTime date;
  final String? doc;

  const StudentHomeworkRecord({
    required this.className,
    required this.batch,
    required this.employee,
    required this.subject,
    required this.division,
    required this.homework,
    required this.date,
    this.doc,
  });

  factory StudentHomeworkRecord.fromJson(Map<String, dynamic> json) {
    try {
      print('--- StudentHomeworkRecord.fromJson START ---');
      print('Input JSON: $json');

      final record = StudentHomeworkRecord(
        className: _safeStringExtraction(json, 'ClassName'),
        batch: _safeStringExtraction(json, 'Batch'),
        employee: _safeStringExtraction(json, 'Employee'),
        subject: _safeStringExtraction(json, 'Subject'),
        division: _safeStringExtraction(json, 'Division'),
        homework: _safeStringExtraction(json, 'HomeWork'),
        date: _safeDateTimeExtraction(json, 'Date'),
        doc: json['Doc']?.toString(),
      );

      print('--- StudentHomeworkRecord.fromJson SUCCESS ---');
      return record;
    } catch (e, stackTrace) {
      print('--- StudentHomeworkRecord.fromJson ERROR ---');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Helper methods
  static String _safeStringExtraction(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString().trim();
  }

  static DateTime _safeDateTimeExtraction(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  @override
  String toString() {
    return 'StudentHomeworkRecord(subject: $subject, homework: $homework, employee: $employee, date: $date)';
  }
}

// Subject categorization helper
class SubjectHelper {
  static String getCategoryFromSubject(String subject) {
    final lowerSubject = subject.toLowerCase().trim();

    if (lowerSubject.contains('math')) {
      return 'Mathematics';
    } else if (lowerSubject.contains('science') || lowerSubject.contains('physics') ||
        lowerSubject.contains('chemistry') || lowerSubject.contains('biology')) {
      return 'Science';
    } else if (lowerSubject.contains('english') || lowerSubject.contains('language')) {
      return 'Language';
    } else if (lowerSubject.contains('history') || lowerSubject.contains('social')) {
      return 'Social Studies';
    } else if (lowerSubject.contains('computer') || lowerSubject.contains('coding')) {
      return 'Technology';
    } else {
      return 'Other';
    }
  }

  static Color getSubjectColor(String subject) {
    final category = getCategoryFromSubject(subject);
    switch (category.toLowerCase()) {
      case 'mathematics':
        return const Color(0xFF4A90E2);
      case 'science':
        return const Color(0xFF58CC02);
      case 'language':
        return const Color(0xFFE74C3C);
      case 'social studies':
        return const Color(0xFF8E44AD);
      case 'technology':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF718096);
    }
  }

  static IconData getSubjectIcon(String subject) {
    final category = getCategoryFromSubject(subject);
    switch (category.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'language':
        return Icons.menu_book_rounded;
      case 'social studies':
        return Icons.history_edu_rounded;
      case 'technology':
        return Icons.computer_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}

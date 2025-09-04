import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

class AllocatedSubjectsService {

  static Future<List<AllocatedSubject>> getAllocatedSubjects() async {
    try {
      debugPrint('=== ALLOCATED SUBJECTS API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      debugPrint('Fetching allocated subjects for UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/TeacherAllocatedSubject');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== ALLOCATED SUBJECTS API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => AllocatedSubject.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e, stackTrace) {
      debugPrint('=== ALLOCATED SUBJECTS ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
}

// Data Model
class AllocatedSubject {
  final String className;
  final String subject;
  final String subjectType;

  AllocatedSubject({
    required this.className,
    required this.subject,
    required this.subjectType,
  });

  factory AllocatedSubject.fromJson(Map<String, dynamic> json) {
    return AllocatedSubject(
      className: json['Class'] ?? '',
      subject: json['Subject'] ?? '',
      subjectType: json['SubjectType'] ?? '',
    );
  }
}

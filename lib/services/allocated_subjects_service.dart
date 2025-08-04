import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class AllocatedSubjectsService {

  static Future<List<AllocatedSubject>> getAllocatedSubjects() async {
    try {
      print('=== ALLOCATED SUBJECTS API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      print('Fetching allocated subjects for UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/TeacherAllocatedSubject');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== ALLOCATED SUBJECTS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => AllocatedSubject.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e, stackTrace) {
      print('=== ALLOCATED SUBJECTS ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
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

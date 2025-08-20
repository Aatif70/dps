import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class AdminStudentService {
  static Future<List<StudentSearchResult>> searchStudents({required String term}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.searchStudent}');
      final request = http.MultipartRequest('POST', url);
      request.fields['term'] = term;
      request.fields['UId'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => StudentSearchResult.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

class StudentSearchResult {
  final String name;
  final int id;

  StudentSearchResult({required this.name, required this.id});

  factory StudentSearchResult.fromJson(Map<String, dynamic> json) {
    return StudentSearchResult(
      name: (json['Name'] ?? '').toString(),
      id: (json['ID'] ?? 0) is int ? (json['ID'] as int) : int.tryParse((json['ID'] ?? '0').toString()) ?? 0,
    );
  }
}



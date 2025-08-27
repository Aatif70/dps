import 'dart:convert';

import 'package:dps/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class RegisteredStudentSummary {
  final int studentId;
  final String name;
  final String? category;
  final String? religion;
  final String? studentMobile;
  final String? parentMobile;
  final String? collegePrn;
  final String? className;
  final String? acadYear;
  final String? gender;
  final String? adhaar;
  final String? email;
  final bool approveForAdmission;

  RegisteredStudentSummary({
    required this.studentId,
    required this.name,
    required this.category,
    required this.religion,
    required this.studentMobile,
    required this.parentMobile,
    required this.collegePrn,
    required this.className,
    required this.acadYear,
    required this.gender,
    required this.adhaar,
    required this.email,
    required this.approveForAdmission,
  });

  factory RegisteredStudentSummary.fromJson(Map<String, dynamic> json) {
    return RegisteredStudentSummary(
      studentId: json['StudentId'] as int,
      name: (json['Name'] ?? '').toString().trim(),
      category: json['Category'] as String?,
      religion: json['Religion'] as String?,
      studentMobile: json['StudentMobile'] as String?,
      parentMobile: json['ParentMobile'] as String?,
      collegePrn: json['CollegePRN']?.toString(),
      className: json['ClassName'] as String?,
      acadYear: json['AcadYear'] as String?,
      gender: json['Gender'] as String?,
      adhaar: json['Adhaar'] as String?,
      email: json['Email'] as String?,
      approveForAdmission: (json['ApproveForAdmission'] as bool?) ?? false,
    );
  }
}

class AdminAdmissionsService {
  static Future<List<RegisteredStudentSummary>> fetchRegisteredStudents() async {
    final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.registeredStudents);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load registered students');
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final success = decoded['success'] == true;
    if (!success) {
      throw Exception('API returned unsuccessful response');
    }
    final List<dynamic> data = decoded['data'] as List<dynamic>? ?? <dynamic>[];
    return data.map((e) => RegisteredStudentSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}



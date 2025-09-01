import 'dart:convert';

import 'package:dps/constants/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  // --- Divisions by Class (GET /api/Students/DivByClass?ClassId=...) ---
  static Future<List<DivisionLite>> fetchDivisionsByClass({required int classId}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.divisionsByClass}?ClassId=$classId');
    debugPrint('[Service] GET DivByClass -> $uri');
    final response = await http.get(uri);
    debugPrint('[Service] DivByClass status=${response.statusCode}');
    if (response.statusCode != 200) {
      return [];
    }
    final List<dynamic> data = json.decode(response.body) as List<dynamic>;
    return data.map((e) => DivisionLite.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Classwise subjects (GET /api/Register/GetclasswiseSubject?ClassId=...) ---
  static Future<List<SubjectOption>> fetchClasswiseSubjects({required int classId}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.classwiseSubjects}?ClassId=$classId');
    debugPrint('[Service] GET ClasswiseSubject -> $uri');
    final response = await http.get(uri);
    debugPrint('[Service] ClasswiseSubject status=${response.statusCode}');
    if (response.statusCode != 200) {
      return [];
    }
    final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
    if (decoded['success'] == true && decoded['data'] is List) {
      final List<dynamic> data = decoded['data'] as List<dynamic>;
      return data.map((e) => SubjectOption.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // --- Practical batches by division (GET /api/Register/GetPracticalBatchCP?Id=DivisionId) ---
  static Future<List<PracticalBatch>> fetchPracticalBatches({required int divisionId}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.practicalBatchesByDivision}?Id=$divisionId');
    debugPrint('[Service] GET PracticalBatchCP -> $uri');
    final response = await http.get(uri);
    debugPrint('[Service] PracticalBatchCP status=${response.statusCode}');
    if (response.statusCode != 200) {
      return [];
    }
    final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
    if (decoded['success'] == true && decoded['data'] is List) {
      final List<dynamic> data = decoded['data'] as List<dynamic>;
      return data.map((e) => PracticalBatch.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  // --- Create Admission (POST /api/Register/CreateAdmission) ---
  static Future<bool> createAdmission({
    required int studentId,
    required int classId,
    required int divisionId,
    required int admissionYear,
    required String admissionDateIso,
    required int practicalId,
    required List<SubjectSelection> subjects,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('Uid') ?? '';
    final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.createAdmission);
    final body = {
      'StudentId': studentId,
      'ClassId': classId,
      'DivisionId': divisionId,
      'AdmissionYear': admissionYear,
      'AdmissionDate': admissionDateIso,
      'PracticalId': practicalId,
      'StudSubjects': subjects.map((e) => e.toJson()).toList(),
      'UserId': uid,
    };
    debugPrint('[Service] POST CreateAdmission -> ${ApiConstants.baseUrl + ApiConstants.createAdmission}');
    debugPrint('[Service] CreateAdmission body=${json.encode(body)}');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    debugPrint('[Service] CreateAdmission status=${response.statusCode} body=${response.body}');
    if (response.statusCode != 200) {
      return false;
    }
    final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
    return decoded['success'] == true;
  }
}

class DivisionLite {
  final int divisionId;
  final String name;

  DivisionLite({required this.divisionId, required this.name});

  factory DivisionLite.fromJson(Map<String, dynamic> json) {
    return DivisionLite(
      divisionId: int.tryParse((json['DivisionId'] ?? '0').toString()) ?? 0,
      name: (json['Name'] ?? json['DivName'] ?? '').toString(),
    );
  }
}

class SubjectOption {
  final int subId;
  final String name;
  bool checked;
  final bool repeaterChecked;
  final int isRepeater;

  SubjectOption({
    required this.subId,
    required this.name,
    required this.checked,
    required this.repeaterChecked,
    required this.isRepeater,
  });

  factory SubjectOption.fromJson(Map<String, dynamic> json) {
    return SubjectOption(
      subId: int.tryParse((json['SubId'] ?? '0').toString()) ?? 0,
      name: (json['Name'] ?? '').toString(),
      checked: (json['Checked'] as bool?) ?? false,
      repeaterChecked: (json['RepeaterChecked'] as bool?) ?? false,
      isRepeater: int.tryParse((json['IsRepeater'] ?? '0').toString()) ?? 0,
    );
  }
}

class PracticalBatch {
  final int practicalId;
  final String name;

  PracticalBatch({required this.practicalId, required this.name});

  factory PracticalBatch.fromJson(Map<String, dynamic> json) {
    return PracticalBatch(
      practicalId: int.tryParse((json['PracticalId'] ?? '0').toString()) ?? 0,
      name: (json['Name'] ?? '').toString(),
    );
  }
}

class SubjectSelection {
  final int subId;
  final bool isChecked;

  SubjectSelection({required this.subId, required this.isChecked});

  Map<String, dynamic> toJson() => {
        'SubId': subId,
        'IsChecked': isChecked,
      };
}



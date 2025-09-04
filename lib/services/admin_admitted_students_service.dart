import 'dart:convert';

import 'package:AES/constants/api_constants.dart';
import 'package:http/http.dart' as http;

class AdmittedStudentItem {
  final int admissionId;
  final String className;
  final String batch;
  final String name;
  final int rollNo;
  final int admissionYear;
  final String status;
  final bool isActive;
  final bool isCurrent;
  final int studentId;
  final int classId;
  final DateTime? admissionDate;

  AdmittedStudentItem({
    required this.admissionId,
    required this.className,
    required this.batch,
    required this.name,
    required this.rollNo,
    required this.admissionYear,
    required this.status,
    required this.isActive,
    required this.isCurrent,
    required this.studentId,
    required this.classId,
    required this.admissionDate,
  });

  factory AdmittedStudentItem.fromJson(Map<String, dynamic> json) {
    DateTime? dt;
    final raw = json['AdmissionDate'];
    if (raw != null && raw.toString().isNotEmpty) {
      try { dt = DateTime.parse(raw.toString()); } catch (_) {}
    }
    return AdmittedStudentItem(
      admissionId: int.tryParse((json['AdmissionId'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
      batch: (json['Batch'] ?? '').toString(),
      name: (json['Name'] ?? '').toString(),
      rollNo: int.tryParse((json['RollNo'] ?? '0').toString()) ?? 0,
      admissionYear: int.tryParse((json['AdmissionYear'] ?? '0').toString()) ?? 0,
      status: (json['Status'] ?? '').toString(),
      isActive: (json['IsActive'] as bool?) ?? false,
      isCurrent: (json['IsCurrent'] as bool?) ?? false,
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      admissionDate: dt,
    );
  }
}

class AdminAdmittedStudentsService {
  static Future<List<AdmittedStudentItem>> fetchAdmittedStudents({required int classId}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.admittedStudentsByClass}?CID=$classId');
    final res = await http.get(uri);
    if (res.statusCode != 200) return [];
    final decoded = json.decode(res.body) as Map<String, dynamic>;
    if (decoded['success'] == true && decoded['data'] is List) {
      final List<dynamic> data = decoded['data'] as List<dynamic>;
      return data.map((e) => AdmittedStudentItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}



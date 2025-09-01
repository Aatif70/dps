import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:dps/constants/api_constants.dart';

class TeacherHomeworkService {

  // Fetch homework list for teacher
  static Future<List<TeacherHomework>> getHomeworkList({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      debugPrint('=== HOMEWORK LIST API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      final fd = DateFormat('dd-MM-yyyy').format(fromDate ?? DateTime.now().subtract(const Duration(days: 30)));
      final td = DateFormat('dd-MM-yyyy').format(toDate ?? DateTime.now());

      debugPrint('UID: $uid, EmpId: $empId, FromDate: $fd, ToDate: $td');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.homeworkList}');
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
        'FD': fd,
        'TD': td,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== HOMEWORK LIST API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => TeacherHomework.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e, stackTrace) {
      debugPrint('=== HOMEWORK LIST ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }



  // Fetch classes dropdown for teacher
  static Future<List<Class>> getClasses() async {
    try {
      debugPrint('=== CLASSES API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      debugPrint('Fetching classes for UID: $uid, EmpId: $empId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getClassByEmpId}');
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== CLASSES API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Class.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('=== CLASSES ERROR ===');
      debugPrint('Error: $e');
      return [];
    }
  }

  // Fetch batch list for a class
  static Future<List<Batch>> getBatchList(int classMasterId) async {
    try {
      debugPrint('=== BATCH LIST API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;
      debugPrint('Fetching batches for UID: $uid, EmpId: $empId, ClassMasterId: $classMasterId');
      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/BatchList');
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
        'ClassMasterId': classMasterId.toString(),
      });
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('=== BATCH LIST API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Batch.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('=== BATCH LIST ERROR ===');
      debugPrint('Error: $e');
      return [];
    }
  }

  // Update getDivisions to use ClassId (from batch)
  static Future<List<Division>> getDivisions(int classId) async {
    try {
      debugPrint('=== DIVISIONS API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;
      debugPrint('Fetching divisions for UID: $uid, EmpId: $empId, ClassId: $classId');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.divisionList}');
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
        'ClassId': classId.toString(),
      });
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('=== DIVISIONS API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Division.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('=== DIVISIONS ERROR ===');
      debugPrint('Error: $e');
      return [];
    }
  }

  // Fetch subjects dropdown
  static Future<List<Subject>> getSubjects(int classMasterId) async {
    try {
      debugPrint('=== SUBJECTS API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      debugPrint('Fetching subjects for UID: $uid, EmpId: $empId, ClassMasterId: $classMasterId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.subjectList}');
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
        'ClassMasterId': classMasterId.toString(),
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== SUBJECTS API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Subject.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('=== SUBJECTS ERROR ===');
      debugPrint('Error: $e');
      return [];
    }
  }

  // Add homework
  static Future<bool> addHomework({
    required int subjectId,
    required DateTime date,
    required int classId,
    required int divisionId,
    required String homework,
    File? file,
  }) async {
    try {
      debugPrint('=== ADD HOMEWORK API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final dateString = DateFormat('yyyy-MM-dd').format(date);

      // Organized print statements for all fields
      debugPrint('--- HOMEWORK ADD: FIELD SUMMARY ---');
      debugPrint('CreatedBy: $uid');
      if (uid.isEmpty) debugPrint('[WARNING] CreatedBy (uid) is missing!');
      debugPrint('SubjectId: $subjectId');
      if (subjectId == 0) debugPrint('[WARNING] SubjectId is missing or zero!');
      debugPrint('Date: $dateString');
      if (dateString.isEmpty) debugPrint('[WARNING] Date is missing!');
      debugPrint('ClassId: $classId');
      if (classId == 0) debugPrint('[WARNING] ClassId is missing or zero!');
      debugPrint('DivisionId: $divisionId');
      if (divisionId == 0) debugPrint('[WARNING] DivisionId is missing or zero!');
      debugPrint('HomeWork: $homework');
      if (homework.isEmpty) debugPrint('[WARNING] HomeWork is missing!');
      debugPrint('file: ${file?.path ?? 'No file'}');
      if (file == null) debugPrint('[INFO] No file attached.');
      debugPrint('--- END FIELD SUMMARY ---');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.homeworkAdd}');
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'CreatedBy': uid,
        'SubjectId': subjectId.toString(),
        'Date': dateString,
        'ClassId': classId.toString(),
        'DivisionId': divisionId.toString(),
        'HomeWork': homework,
      });

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        debugPrint('File added to request: ${file.path}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== ADD HOMEWORK API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('=== ADD HOMEWORK ERROR ===');
      debugPrint('Error: $e');
      return false;
    }
  }
}

// Data Models
class TeacherHomework {
  final int hId;
  final String className;
  final String batch;
  final String employee;
  final String subject;
  final String division;
  final String homeWork;
  final DateTime date;
  final String? doc;

  TeacherHomework({
    required this.hId,
    required this.className,
    required this.batch,
    required this.employee,
    required this.subject,
    required this.division,
    required this.homeWork,
    required this.date,
    this.doc,
  });

  factory TeacherHomework.fromJson(Map<String, dynamic> json) {
    return TeacherHomework(
      hId: json['HId'] ?? 0,
      className: json['ClassName'] ?? '',
      batch: json['Batch'] ?? '',
      employee: json['Employee'] ?? '',
      subject: json['Subject'] ?? '',
      division: json['Division'] ?? '',
      homeWork: json['HomeWork'] ?? '',
      date: DateTime.parse(json['Date'] ?? DateTime.now().toIso8601String()),
      doc: json['Doc'],
    );
  }

  String get docUrl => doc != null && doc!.isNotEmpty
      ? '${ApiConstants.baseUrl}$doc'
      : '';
}


class Class {
  final int classMasterId;
  final String className;

  Class({
    required this.classMasterId,
    required this.className,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      classMasterId: json['ClassMasterId'] ?? 0,
      className: json['ClassName'] ?? '',
    );
  }
}

class Batch {
  final int classId;
  final String className;
  Batch({required this.classId, required this.className});
  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      classId: json['ClassId'] ?? 0,
      className: json['ClassName'] ?? '',
    );
  }
}

class Division {
  final int divisionId;
  final String name;

  Division({
    required this.divisionId,
    required this.name,
  });

  factory Division.fromJson(Map<String, dynamic> json) {
    return Division(
      divisionId: json['DivisionId'] ?? 0,
      name: json['Name'] ?? '',
    );
  }
}

class Subject {
  final int subjectId;
  final String subjectName;

  Subject({
    required this.subjectId,
    required this.subjectName,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['SubjectId'] ?? 0,
      subjectName: json['SubjectName'] ?? '',
    );
  }
}

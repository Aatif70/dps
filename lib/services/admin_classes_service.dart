import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class AdminClassesService {
  static Future<List<ClassMasterItem>> fetchClassMasters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.classMasters}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => ClassMasterItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> createClass({
    required String className,
    required String rollNoPrefix,
    required int courseYear,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createClass}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ClassName': className,
          'RollNoPreFix': rollNoPrefix,
          'CourseYear': courseYear,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return (jsonData['success'] == true);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateClass({
    required int classMasterId,
    required String className,
    required String rollNoPrefix,
    required int courseYear,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateClass}');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ClassMasterId': classMasterId,
          'ClassName': className,
          'RollNoPreFix': rollNoPrefix,
          'CourseYear': courseYear,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return (jsonData['success'] == true);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<List<BatchItem>> fetchBatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminBatches}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => BatchItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<DivisionItem>> fetchDivisions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminDivisions}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((e) => DivisionItem.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

class ClassMasterItem {
  final int classMasterId;
  final int courseMasterId;
  final String className;
  final int courseYear;
  final String rollNoPrefix;

  ClassMasterItem({
    required this.classMasterId,
    required this.courseMasterId,
    required this.className,
    required this.courseYear,
    required this.rollNoPrefix,
  });

  factory ClassMasterItem.fromJson(Map<String, dynamic> json) {
    return ClassMasterItem(
      classMasterId: int.tryParse((json['ClassMasterId'] ?? '0').toString()) ?? 0,
      courseMasterId: int.tryParse((json['CourseMasterId'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
      courseYear: int.tryParse((json['CourseYear'] ?? '0').toString()) ?? 0,
      rollNoPrefix: (json['RollNoPreFix'] ?? '').toString(),
    );
  }
}

class BatchItem {
  final int classId;
  final int classMasterId;
  final int courseYear;
  final String batchName;

  BatchItem({
    required this.classId,
    required this.classMasterId,
    required this.courseYear,
    required this.batchName,
  });

  factory BatchItem.fromJson(Map<String, dynamic> json) {
    return BatchItem(
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      classMasterId: int.tryParse((json['ClassMasterId'] ?? '0').toString()) ?? 0,
      courseYear: int.tryParse((json['CourseYear'] ?? '0').toString()) ?? 0,
      batchName: (json['BatchName'] ?? '').toString(),
    );
  }
}

class DivisionItem {
  final int divisionId;
  final int classId;
  final int empId;
  final String divName;

  DivisionItem({
    required this.divisionId,
    required this.classId,
    required this.empId,
    required this.divName,
  });

  factory DivisionItem.fromJson(Map<String, dynamic> json) {
    return DivisionItem(
      divisionId: int.tryParse((json['DivisionId'] ?? '0').toString()) ?? 0,
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      empId: int.tryParse((json['EmpId'] ?? '0').toString()) ?? 0,
      divName: (json['DivName'] ?? '').toString(),
    );
  }
}



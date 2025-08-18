import 'dart:convert';
import 'dart:developer';
import 'package:dps/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeacherAttendanceService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Get classes by employee ID
  static Future<List<ClassData>> getClassesByEmpId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.get('Id')?.toString() ?? '';

      if (uid.isEmpty || empId.isEmpty) {
        print('ERROR: Uid or EmpId not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('$baseUrl/api/User/GetClassByEmpId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'EmpId': empId,
        },
      );

      print('Classes API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as List)
              .map((item) => ClassData.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting classes: $e');
      return [];
    }
  }

  // Get batches by employee ID and class master ID
  static Future<List<BatchData>> getBatchesByEmpId(int classMasterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.get('Id')?.toString() ?? '';

      if (uid.isEmpty || empId.isEmpty) {
        print('ERROR: Uid or EmpId not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('$baseUrl/api/User/BatchByEmpId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'empid': empId,
          'classmid': classMasterId.toString(),
        },
      );

      print('Batches API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as List)
              .map((item) => BatchData.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting batches: $e');
      return [];
    }
  }

  // Get divisions by class ID
  static Future<List<DivisionData>> getDivisionsByClassId(int classId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      if (uid.isEmpty) {
        print('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('$baseUrl/api/User/DivByEmpId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'classId': classId.toString(),
        },
      );

      print('Divisions API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        return jsonData.map((item) => DivisionData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting divisions: $e');
      return [];
    }
  }

  // Get subjects by employee ID and class master ID
  static Future<List<SubjectData>> getSubjectsByEmpId(int classMasterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.get('Id')?.toString() ?? '';

      if (uid.isEmpty || empId.isEmpty) {
        print('ERROR: Uid or EmpId not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('$baseUrl/api/User/SubByEmpId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'classMasterId': classMasterId.toString(),
          'empId': empId,
        },
      );

      print('Subjects API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return (jsonData['data'] as List)
              .map((item) => SubjectData.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting subjects: $e');
      return [];
    }
  }
}

// Data Models
class ClassData {
  final int classMasterId;
  final String className;

  ClassData({
    required this.classMasterId,
    required this.className,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      classMasterId: json['ClassMasterId'] ?? 0,
      className: json['ClassName'] ?? '',
    );
  }
}

class BatchData {
  final int classId;
  final String batch;

  BatchData({
    required this.classId,
    required this.batch,
  });

  factory BatchData.fromJson(Map<String, dynamic> json) {
    return BatchData(
      classId: json['classid'] ?? 0,
      batch: json['batch'] ?? '',
    );
  }
}

class DivisionData {
  final int divisionId;
  final String name;

  DivisionData({
    required this.divisionId,
    required this.name,
  });

  factory DivisionData.fromJson(Map<String, dynamic> json) {
    return DivisionData(
      divisionId: json['DivisionId'] ?? 0,
      name: json['Name'] ?? '',
    );
  }
}

class SubjectData {
  final int subjectId;
  final String subjectName;

  SubjectData({
    required this.subjectId,
    required this.subjectName,
  });

  factory SubjectData.fromJson(Map<String, dynamic> json) {
    return SubjectData(
      subjectId: json['SubjectId'] ?? 0,
      subjectName: json['SubjectName'] ?? '',
    );
  }
}

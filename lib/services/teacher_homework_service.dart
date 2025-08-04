import 'dart:convert';
import 'dart:io';
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
      print('=== HOMEWORK LIST API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      final fd = DateFormat('dd-MM-yyyy').format(fromDate ?? DateTime.now().subtract(const Duration(days: 30)));
      final td = DateFormat('dd-MM-yyyy').format(toDate ?? DateTime.now());

      print('UID: $uid, EmpId: $empId, FromDate: $fd, ToDate: $td');

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

      print('=== HOMEWORK LIST API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => TeacherHomework.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e, stackTrace) {
      print('=== HOMEWORK LIST ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Fetch courses dropdown
  static Future<List<Course>> getCourses() async {
    try {
      print('=== COURSES API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      print('Fetching courses for UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.courseList}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== COURSES API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Course.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e) {
      print('=== COURSES ERROR ===');
      print('Error: $e');
      return [];
    }
  }

  // Fetch batches dropdown
  static Future<List<Batch>> getBatches(int courseMasterId) async {
    try {
      print('=== BATCHES API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      print('Fetching batches for UID: $uid, EmpId: $empId, CourseMasterId: $courseMasterId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.batches}');
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
        'CourseMasterId': courseMasterId.toString(),
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== BATCHES API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Batch.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e) {
      print('=== BATCHES ERROR ===');
      print('Error: $e');
      return [];
    }
  }

  // Fetch divisions dropdown
  static Future<List<Division>> getDivisions(int classId) async {
    try {
      print('=== DIVISIONS API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      print('Fetching divisions for UID: $uid, EmpId: $empId, ClassId: $classId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.divisionList}');
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
        'ClassId': classId.toString(),
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== DIVISIONS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Division.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e) {
      print('=== DIVISIONS ERROR ===');
      print('Error: $e');
      return [];
    }
  }

  // Fetch subjects dropdown
  static Future<List<Subject>> getSubjects(int classMasterId) async {
    try {
      print('=== SUBJECTS API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      print('Fetching subjects for UID: $uid, EmpId: $empId, ClassMasterId: $classMasterId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.subjectList}');
      final request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
        'ClassMasterId': classMasterId.toString(),
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== SUBJECTS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => Subject.fromJson(item)).toList();
        }
      }

      return [];
    } catch (e) {
      print('=== SUBJECTS ERROR ===');
      print('Error: $e');
      return [];
    }
  }

  // Add homework
  static Future<bool> addHomework({
    required int subjectId,
    required DateTime date,
    required int classMasterId,
    required int classId,
    required int divisionId,
    required String homework,
    File? file,
  }) async {
    try {
      print('=== ADD HOMEWORK API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final dateString = DateFormat('yyyy-MM-dd').format(date);

      print('Adding homework with:');
      print('CreatedBy: $uid');
      print('SubjectId: $subjectId');
      print('Date: $dateString');
      print('ClassMasterId: $classMasterId');
      print('ClassId: $classId');
      print('DivisionId: $divisionId');
      print('HomeWork: $homework');
      print('File: ${file?.path ?? 'No file'}');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.homeworkAdd}');
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'CreatedBy': uid,
        'SubjectId': subjectId.toString(),
        'Date': dateString,
        'ClassMasterId': classMasterId.toString(),
        'ClassId': classId.toString(),
        'DivisionId': divisionId.toString(),
        'HomeWork': homework,
      });

      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
        print('File added to request: ${file.path}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== ADD HOMEWORK API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }

      return false;
    } catch (e) {
      print('=== ADD HOMEWORK ERROR ===');
      print('Error: $e');
      return false;
    }
  }
}

// Data Models
class TeacherHomework {
  final String className;
  final String batch;
  final String employee;
  final String subject;
  final String division;
  final String homeWork;
  final DateTime date;
  final String? doc;

  TeacherHomework({
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

class Course {
  final int courseMasterId;
  final String courseName;

  Course({
    required this.courseMasterId,
    required this.courseName,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseMasterId: json['CourseMasterId'] ?? 0,
      courseName: json['CourseName'] ?? '',
    );
  }
}

class Batch {
  final int classId;
  final int classMasterId;
  final int courseYear;
  final String batchName;

  Batch({
    required this.classId,
    required this.classMasterId,
    required this.courseYear,
    required this.batchName,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      classId: json['ClassId'] ?? 0,
      classMasterId: json['ClassMasterId'] ?? 0,
      courseYear: json['CourseYear'] ?? 0,
      batchName: json['BatchName'] ?? '',
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

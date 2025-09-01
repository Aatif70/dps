import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class TeacherStudyMaterialService {
  // Fetch study materials for teacher
  static Future<List<StudyMaterial>> getStudyMaterials() async {
    try {
      debugPrint('=== STUDY MATERIAL LIST API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      debugPrint('UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.teacherStudyMaterial}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== STUDY MATERIAL LIST API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => StudyMaterial.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('=== STUDY MATERIAL LIST ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Fetch classes for class dropdown using GetClassByEmpId API
  static Future<List<ClassData>> getClasses() async {
    try {
      debugPrint('=== GET CLASSES API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      debugPrint('UID: $uid');
      debugPrint('EmpId: $empId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getClassByEmpId}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['EmpId'] = empId.toString();

      debugPrint('=== GET CLASSES REQUEST FIELDS ===');
      debugPrint('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== GET CLASSES API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => ClassData.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('=== GET CLASSES API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Fetch batches for class dropdown (keeping for backward compatibility)
  static Future<List<BatchData>> getBatches() async {
    try {
      debugPrint('=== BATCHES API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      debugPrint('UID: $uid');
      debugPrint('EmpId: $empId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.batches}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['EmpId'] = empId.toString();
      request.fields['CourseMasterId'] = '1'; // Default as mentioned

      debugPrint('=== BATCHES REQUEST FIELDS ===');
      debugPrint('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== BATCHES API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => BatchData.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('=== BATCHES API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Fetch subjects based on selected class
  static Future<List<SubjectData>> getSubjects(int classMasterId) async {
    try {
      debugPrint('=== SUBJECTS API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      debugPrint('UID: $uid');
      debugPrint('EmpId: $empId');
      debugPrint('ClassMasterId: $classMasterId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.subByEmpId}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['classMasterId'] = classMasterId.toString();
      request.fields['empId'] = empId.toString();

      debugPrint('=== SUBJECTS REQUEST FIELDS ===');
      debugPrint('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== SUBJECTS API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => SubjectData.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('=== SUBJECTS API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Add new study material
  static Future<bool> addStudyMaterial({
    required int classMasterId,
    required int subjectId,
    required String chapter,
    required String description,
    required String uploadType,
    String? youtubeLink,
    File? file,
  }) async {
    try {
      debugPrint('=== ADD STUDY MATERIAL API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      debugPrint('UID: $uid');
      debugPrint('EmpId: $empId');
      debugPrint('ClassMasterId: $classMasterId');
      debugPrint('SubjectId: $subjectId');
      debugPrint('Chapter: $chapter');
      debugPrint('Description: $description');
      debugPrint('UploadType: $uploadType');
      debugPrint('YoutubeLink: $youtubeLink');
      debugPrint('File: ${file?.path ?? 'No file'}');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studyMaterialAdd}');
      final request = http.MultipartRequest('POST', url);

      // Add required fields
      request.fields['Uid'] = uid;
      request.fields['ClassMasterId'] = classMasterId.toString();
      request.fields['SubjectId'] = subjectId.toString();
      request.fields['EmpId'] = empId.toString();
      request.fields['Chapter'] = chapter;
      request.fields['Description'] = description;
      request.fields['UploadType'] = uploadType;

      // Add optional fields
      if (youtubeLink != null && youtubeLink.isNotEmpty) {
        request.fields['YoutubeLink'] = youtubeLink;
        debugPrint('Added YoutubeLink: $youtubeLink');
      }

      if (file != null) {
        final fileStream = http.ByteStream(file.openRead());
        final fileLength = await file.length();
        final multipartFile = http.MultipartFile(
          'File',
          fileStream,
          fileLength,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
        debugPrint('Added File: ${file.path.split('/').last}');
      }

      debugPrint('=== ADD STUDY MATERIAL REQUEST FIELDS ===');
      debugPrint('Request Fields: ${request.fields}');
      debugPrint('Request Files: ${request.files.map((f) => f.filename).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== ADD STUDY MATERIAL API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          debugPrint('=== STUDY MATERIAL ADDED SUCCESSFULLY ===');
          return true;
        } else {
          debugPrint('=== ADD STUDY MATERIAL FAILED ===');
          debugPrint('Error: ${jsonData['message'] ?? 'Unknown error'}');
        }
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('=== ADD STUDY MATERIAL ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }
}

// Data Models
class StudyMaterial {
  final int studyMaterialId;
  final int classMasterId;
  final int subjectId;
  final int empId;
  final String className;
  final String subject;
  final String empName;
  final String uploadType;
  final String fileName;
  final String? file;
  final String chapter;
  final String? description;
  final bool isActive;

  StudyMaterial({
    required this.studyMaterialId,
    required this.classMasterId,
    required this.subjectId,
    required this.empId,
    required this.className,
    required this.subject,
    required this.empName,
    required this.uploadType,
    required this.fileName,
    this.file,
    required this.chapter,
    this.description,
    required this.isActive,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      studyMaterialId: json['StudyMaterialId'] ?? 0,
      classMasterId: json['ClassMasterId'] ?? 0,
      subjectId: json['SubjectId'] ?? 0,
      empId: json['EmpId'] ?? 0,
      className: json['ClassName'] ?? '',
      subject: json['Subject'] ?? '',
      empName: json['EmpName'] ?? '',
      uploadType: json['UploadType'] ?? '',
      fileName: json['FileName'] ?? '',
      file: json['File'],
      chapter: json['Chapter'] ?? '',
      description: json['Description'],
      isActive: json['IsActive'] ?? true,
    );
  }

  String get fileUrl => fileName.isNotEmpty
      ? '${ApiConstants.baseUrl}$fileName'
      : '';

  String get fileExtension {
    if (fileName.isEmpty) return '';
    return fileName.split('.').last.toLowerCase();
  }

  StudyMaterialType get materialType {
    switch (fileExtension) {
      case 'pdf':
        return StudyMaterialType.pdf;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return StudyMaterialType.video;
      case 'ppt':
      case 'pptx':
        return StudyMaterialType.presentation;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return StudyMaterialType.image;
      case 'txt':
      case 'doc':
      case 'docx':
        return StudyMaterialType.document;
      default:
        return StudyMaterialType.file;
    }
  }
}

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
  final int classMasterId;
  final int courseYear;
  final String batchName;

  BatchData({
    required this.classId,
    required this.classMasterId,
    required this.courseYear,
    required this.batchName,
  });

  factory BatchData.fromJson(Map<String, dynamic> json) {
    return BatchData(
      classId: json['ClassId'] ?? 0,
      classMasterId: json['ClassMasterId'] ?? 0,
      courseYear: json['CourseYear'] ?? 0,
      batchName: json['BatchName'] ?? '',
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

enum StudyMaterialType { pdf, video, presentation, image, document, file }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class TeacherStudyMaterialService {
  // Fetch study materials for teacher
  static Future<List<StudyMaterial>> getStudyMaterials() async {
    try {
      print('=== STUDY MATERIAL LIST API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      print('UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.teacherStudyMaterial}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== STUDY MATERIAL LIST API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => StudyMaterial.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('=== STUDY MATERIAL LIST ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Fetch batches for class dropdown
  static Future<List<BatchData>> getBatches() async {
    try {
      print('=== BATCHES API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      print('UID: $uid');
      print('EmpId: $empId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.batches}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['EmpId'] = empId.toString();
      request.fields['CourseMasterId'] = '1'; // Default as mentioned

      print('=== BATCHES REQUEST FIELDS ===');
      print('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== BATCHES API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => BatchData.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('=== BATCHES API ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Fetch subjects based on selected class
  static Future<List<SubjectData>> getSubjects(int classMasterId) async {
    try {
      print('=== SUBJECTS API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      print('UID: $uid');
      print('EmpId: $empId');
      print('ClassMasterId: $classMasterId');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.subjectList}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['EmpId'] = empId.toString();
      request.fields['ClassMasterId'] = classMasterId.toString();

      print('=== SUBJECTS REQUEST FIELDS ===');
      print('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== SUBJECTS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => SubjectData.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('=== SUBJECTS API ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
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
      print('=== ADD STUDY MATERIAL API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      print('UID: $uid');
      print('EmpId: $empId');
      print('ClassMasterId: $classMasterId');
      print('SubjectId: $subjectId');
      print('Chapter: $chapter');
      print('Description: $description');
      print('UploadType: $uploadType');
      print('YoutubeLink: $youtubeLink');
      print('File: ${file?.path ?? 'No file'}');

      final url = Uri.parse('${ApiConstants.baseUrl}/api/OnlineExam/AddStudyMaterial');
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
        print('Added YoutubeLink: $youtubeLink');
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
        print('Added File: ${file.path.split('/').last}');
      }

      print('=== ADD STUDY MATERIAL REQUEST FIELDS ===');
      print('Request Fields: ${request.fields}');
      print('Request Files: ${request.files.map((f) => f.filename).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== ADD STUDY MATERIAL API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          print('=== STUDY MATERIAL ADDED SUCCESSFULLY ===');
          return true;
        } else {
          print('=== ADD STUDY MATERIAL FAILED ===');
          print('Error: ${jsonData['message'] ?? 'Unknown error'}');
        }
      }
      return false;
    } catch (e, stackTrace) {
      print('=== ADD STUDY MATERIAL ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
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

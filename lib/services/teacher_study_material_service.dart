import 'dart:convert';
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
      case 'mp3':
      case 'wav':
      case 'aac':
        return StudyMaterialType.audio;
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

enum StudyMaterialType { pdf, video, audio, presentation, image, document, file }

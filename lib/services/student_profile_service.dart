import 'dart:convert';
import 'dart:developer';
import 'package:AES/constants/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfileService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<StudentDetailResponse?> getStudentDetails() async {
    try {
      debugPrint('=== STUDENT DETAILS API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      
      // Handle both string and int types for Id
      String studentId = '';
      if (prefs.containsKey('Id')) {
        final idValue = prefs.get('Id');
        if (idValue != null) {
          studentId = idValue.toString();
        }
      }
      
      // Handle both string and int types for Uid
      String uid = '';
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        if (uidValue != null) {
          uid = uidValue.toString();
        }
      }

      debugPrint('Student ID: $studentId');
      debugPrint('UID: $uid');

      if (studentId.isEmpty || uid.isEmpty) {
        debugPrint('Missing StudentId or UId in preferences');
        return null;
      }

      final url = Uri.parse('$baseUrl/api/user/SearchStudentDetail');
      debugPrint('URL: $url');

      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId;
      request.fields['UId'] = uid;

      debugPrint('=== REQUEST FIELDS ===');
      debugPrint('StudentId: $studentId');
      debugPrint('UId: $uid');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== STUDENT DETAILS API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('=== PARSED JSON DATA ===');
        debugPrint('Success: ${jsonData['success']}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final studentDetail = StudentDetailResponse.fromJson(jsonData);
          debugPrint('=== STUDENT DETAIL PARSED ===');
          debugPrint('Student Name: ${studentDetail.data.studentName}');
          debugPrint('Email: ${studentDetail.data.email}');
          debugPrint('Class: ${studentDetail.data.className}');
          return studentDetail;
        } else {
          debugPrint('API returned success=false or null data');
          return null;
        }
      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
        debugPrint('Error body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('=== STUDENT DETAILS API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<StudentDocumentsResponse?> getStudentDocuments() async {
    try {
      debugPrint('=== STUDENT DOCUMENTS API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      
      // Handle both string and int types for Id
      String studentId = '';
      if (prefs.containsKey('Id')) {
        final idValue = prefs.get('Id');
        if (idValue != null) {
          studentId = idValue.toString();
        }
      }
      
      // Handle both string and int types for Uid
      String uid = '';
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        if (uidValue != null) {
          uid = uidValue.toString();
        }
      }

      debugPrint('Student ID: $studentId');
      debugPrint('UID: $uid');

      if (studentId.isEmpty || uid.isEmpty) {
        debugPrint('Missing StudentId or UId in preferences');
        return null;
      }

      final url = Uri.parse('$baseUrl/api/user/StudentDocuments');
      debugPrint('URL: $url');

      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId;
      request.fields['UId'] = uid;

      debugPrint('=== REQUEST FIELDS ===');
      debugPrint('StudentId: $studentId');
      debugPrint('UId: $uid');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== STUDENT DOCUMENTS API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('=== PARSED JSON DATA ===');
        debugPrint('Success: ${jsonData['success']}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final documentsResponse = StudentDocumentsResponse.fromJson(jsonData);
          debugPrint('=== STUDENT DOCUMENTS PARSED ===');
          debugPrint('Document categories: ${documentsResponse.data.length}');
          for (var category in documentsResponse.data) {
            debugPrint('${category.category}: ${category.documents.length} documents');
          }
          return documentsResponse;
        } else {
          debugPrint('API returned success=false or null data');
          return null;
        }
      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
        debugPrint('Error body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('=== STUDENT DOCUMENTS API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}

// Data Models
class StudentDetailResponse {
  final bool success;
  final StudentDetail data;

  StudentDetailResponse({
    required this.success,
    required this.data,
  });

  factory StudentDetailResponse.fromJson(Map<String, dynamic> json) {
    return StudentDetailResponse(
      success: json['success'] ?? false,
      data: StudentDetail.fromJson(json['data'] ?? {}),
    );
  }
}

class StudentDetail {
  final int studentId;
  final String studentName;
  final String email;
  final String className;
  final int admissionYear;
  final String caste;
  final String category;
  final String photo;
  final String prn;
  final String address;
  final String studentMobile;
  final String parentMobile;

  StudentDetail({
    required this.studentId,
    required this.studentName,
    required this.email,
    required this.className,
    required this.admissionYear,
    required this.caste,
    required this.category,
    required this.photo,
    required this.prn,
    required this.address,
    required this.studentMobile,
    required this.parentMobile,
  });

  factory StudentDetail.fromJson(Map<String, dynamic> json) {
    return StudentDetail(
      studentId: json['StudentId'] ?? 0,
      studentName: json['StudentName'] ?? '',
      email: json['Email'] ?? '',
      className: json['Class'] ?? '',
      admissionYear: json['AdmissionYear'] ?? 0,
      caste: json['Caste'] ?? '',
      category: json['Category'] ?? '',
      photo: json['Photo'] ?? '',
      prn: json['PRN'] ?? '',
      address: json['Address'] ?? '',
      studentMobile: json['StudentMobile'] ?? '',
      parentMobile: json['ParentMobile'] ?? '',
    );
  }

  // String get photoUrl => ' $ApiConstants  $photo';

  String get photoUrl => '${ApiConstants.baseUrl}$photo';


}

class StudentDocumentsResponse {
  final bool success;
  final List<DocumentCategory> data;

  StudentDocumentsResponse({
    required this.success,
    required this.data,
  });

  factory StudentDocumentsResponse.fromJson(Map<String, dynamic> json) {
    return StudentDocumentsResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => DocumentCategory.fromJson(item))
          .toList() ?? [],
    );
  }
}

class DocumentCategory {
  final int id;
  final String category;
  final List<Document> documents;

  DocumentCategory({
    required this.id,
    required this.category,
    required this.documents,
  });

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      id: json['Id'] ?? 0,
      category: json['Category'] ?? '',
      documents: (json['Documents'] as List<dynamic>?)
          ?.map((item) => Document.fromJson(item))
          .toList() ?? [],
    );
  }
}

class Document {
  final int id;
  final int docTypeId;
  final int documentId;
  final String docType;
  final String? documentPath;
  final int sequence;
  final int studentId;
  final int typeId;

  Document({
    required this.id,
    required this.docTypeId,
    required this.documentId,
    required this.docType,
    this.documentPath,
    required this.sequence,
    required this.studentId,
    required this.typeId,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['Id'] ?? 0,
      docTypeId: json['DocTypeId'] ?? 0,
      documentId: json['DocumentId'] ?? 0,
      docType: json['DocType'] ?? '',
      documentPath: json['DocumentPath'],
      sequence: json['Sequence'] ?? 0,
      studentId: json['StudentId'] ?? 0,
      typeId: json['TypeId'] ?? 0,
    );
  }

  bool get isUploaded => documentPath != null && documentPath!.isNotEmpty;

  String get fullDocumentPath =>
      documentPath != null ? '${ApiConstants.baseUrl}/Images/Student/$documentPath' : '';
}

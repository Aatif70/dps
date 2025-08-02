import 'dart:convert';
import 'dart:developer';
import 'package:dps/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfileService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<StudentDetailResponse?> getStudentDetails() async {
    try {
      print('=== STUDENT DETAILS API CALL ===');

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

      print('Student ID: $studentId');
      print('UID: $uid');

      if (studentId.isEmpty || uid.isEmpty) {
        print('Missing StudentId or UId in preferences');
        return null;
      }

      final url = Uri.parse('$baseUrl/api/user/SearchStudentDetail');
      print('URL: $url');

      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId;
      request.fields['UId'] = uid;

      print('=== REQUEST FIELDS ===');
      print('StudentId: $studentId');
      print('UId: $uid');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== STUDENT DETAILS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('=== PARSED JSON DATA ===');
        print('Success: ${jsonData['success']}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final studentDetail = StudentDetailResponse.fromJson(jsonData);
          print('=== STUDENT DETAIL PARSED ===');
          print('Student Name: ${studentDetail.data.studentName}');
          print('Email: ${studentDetail.data.email}');
          print('Class: ${studentDetail.data.className}');
          return studentDetail;
        } else {
          print('API returned success=false or null data');
          return null;
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
        print('Error body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('=== STUDENT DETAILS API ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<StudentDocumentsResponse?> getStudentDocuments() async {
    try {
      print('=== STUDENT DOCUMENTS API CALL ===');

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

      print('Student ID: $studentId');
      print('UID: $uid');

      if (studentId.isEmpty || uid.isEmpty) {
        print('Missing StudentId or UId in preferences');
        return null;
      }

      final url = Uri.parse('$baseUrl/api/user/StudentDocuments');
      print('URL: $url');

      final request = http.MultipartRequest('POST', url);
      request.fields['StudentId'] = studentId;
      request.fields['UId'] = uid;

      print('=== REQUEST FIELDS ===');
      print('StudentId: $studentId');
      print('UId: $uid');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== STUDENT DOCUMENTS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('=== PARSED JSON DATA ===');
        print('Success: ${jsonData['success']}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final documentsResponse = StudentDocumentsResponse.fromJson(jsonData);
          print('=== STUDENT DOCUMENTS PARSED ===');
          print('Document categories: ${documentsResponse.data.length}');
          for (var category in documentsResponse.data) {
            print('${category.category}: ${category.documents.length} documents');
          }
          return documentsResponse;
        } else {
          print('API returned success=false or null data');
          return null;
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
        print('Error body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('=== STUDENT DOCUMENTS API ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
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

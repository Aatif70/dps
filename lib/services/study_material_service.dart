import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class StudyMaterialService {
  static Future<List<ApiStudyMaterialRecord>> getStudyMaterials() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('=== STUDY MATERIAL SERVICE DEBUG START ===');
      print('All SharedPreferences keys: ${prefs.getKeys()}');

      // Safe retrieval that handles both string and int types
      String uid = '';

      // Check if Uid exists and get its value regardless of type
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        print('Uid raw value: $uidValue (type: ${uidValue.runtimeType})');
        uid = uidValue.toString();
      }

      print('Study Material Service - Processed Uid: $uid');

      if (uid.isEmpty) {
        print('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.studentStudyMaterial}');
      print('Study Material Service - Request URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;

      print('Study Material Service - Multipart fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Study Material Service - Response status: ${response.statusCode}');
      print('Study Material Service - Response headers: ${response.headers}');
      print('Study Material Service - Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Study Material Service - Parsed JSON response: $jsonResponse');

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          print('Study Material Service - Data array length: ${data.length}');

          List<ApiStudyMaterialRecord> materialRecords = [];

          for (int i = 0; i < data.length; i++) {
            try {
              print('--- Processing study material record $i ---');
              final item = data[i];
              print('Raw item data: $item');

              final materialRecord = ApiStudyMaterialRecord.fromJson(item);
              print('Successfully parsed study material record $i: ${materialRecord.chapter}');
              materialRecords.add(materialRecord);
            } catch (e, stackTrace) {
              print('ERROR parsing study material record $i: $e');
              print('Stack trace: $stackTrace');
              print('Failed item data: ${data[i]}');
            }
          }

          print('Study Material Service - Successfully parsed ${materialRecords.length} out of ${data.length} records');
          print('=== STUDY MATERIAL SERVICE DEBUG END ===');
          return materialRecords;
        } else {
          print('API returned success: false or no data');
          return [];
        }
      } else {
        print('Failed to load study materials. Status code: ${response.statusCode}');
        print('Error response body: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('Error fetching study materials: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}

// Data model for API study material response
class ApiStudyMaterialRecord {
  final int studyMaterialId;
  final int classMasterId;
  final int subjectId;
  final int? empId;
  final String className;
  final String subject;
  final String empName;
  final String uploadType;
  final String fileName;
  final String? file;
  final String chapter;
  final String description;
  final bool isActive;

  const ApiStudyMaterialRecord({
    required this.studyMaterialId,
    required this.classMasterId,
    required this.subjectId,
    this.empId,
    required this.className,
    required this.subject,
    required this.empName,
    required this.uploadType,
    required this.fileName,
    this.file,
    required this.chapter,
    required this.description,
    required this.isActive,
  });

  factory ApiStudyMaterialRecord.fromJson(Map<String, dynamic> json) {
    try {
      print('--- ApiStudyMaterialRecord.fromJson START ---');
      print('Input JSON: $json');

      final record = ApiStudyMaterialRecord(
        studyMaterialId: _safeIntExtraction(json, 'StudyMaterialId'),
        classMasterId: _safeIntExtraction(json, 'ClassMasterId'),
        subjectId: _safeIntExtraction(json, 'SubjectId'),
        empId: json['EmpId'] != null ? _safeIntExtraction(json, 'EmpId') : null,
        className: _safeStringExtraction(json, 'ClassName'),
        subject: _safeStringExtraction(json, 'Subject'),
        empName: _safeStringExtraction(json, 'EmpName'),
        uploadType: _safeStringExtraction(json, 'UploadType'),
        fileName: _safeStringExtraction(json, 'FileName'),
        file: json['File']?.toString(),
        chapter: _safeStringExtraction(json, 'Chapter'),
        description: _safeStringExtraction(json, 'Description'),
        isActive: json['IsActive'] == true,
      );

      print('--- ApiStudyMaterialRecord.fromJson SUCCESS ---');
      return record;
    } catch (e, stackTrace) {
      print('--- ApiStudyMaterialRecord.fromJson ERROR ---');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Convert to legacy StudyMaterial format for compatibility
  StudyMaterial toLegacyStudyMaterial() {
    return StudyMaterial(
      id: 'SM-$studyMaterialId',
      title: chapter.isNotEmpty ? chapter : 'Study Material',
      description: description.isNotEmpty ? description : 'No description available',
      subject: subject,
      type: _determineFileType(fileName),
      teacherName: empName.isNotEmpty ? empName : 'Unknown Teacher',
      teacherAvatar: _generateAvatar(empName),
      uploadedOn: DateTime.now(), // API doesn't provide upload date
      fileSize: '0 MB', // API doesn't provide file size
      downloadCount: 0, // API doesn't provide download count
      isNew: false,
      isPopular: false,
      tags: [subject.toLowerCase(), className.toLowerCase()],
      difficulty: DifficultyLevel.intermediate,
    );
  }

  // Helper methods
  static String _safeStringExtraction(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString().trim();
  }

  static int _safeIntExtraction(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  static MaterialType _determineFileType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return MaterialType.pdf;
      case 'mp4':
      case 'avi':
      case 'mov':
        return MaterialType.video;
      case 'mp3':
      case 'wav':
        return MaterialType.audio;
      default:
        return MaterialType.pdf;
    }
  }

  static String _generateAvatar(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0].substring(0, 1).toUpperCase();
    }
    return 'SM';
  }

  @override
  String toString() {
    return 'ApiStudyMaterialRecord(studyMaterialId: $studyMaterialId, subject: $subject, chapter: $chapter, empName: $empName)';
  }
}

// Keep existing enums and classes for backward compatibility
enum MaterialType { pdf, video, audio }
enum DifficultyLevel { beginner, intermediate, advanced }

class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final String subject;
  final MaterialType type;
  final String teacherName;
  final String teacherAvatar;
  final DateTime uploadedOn;
  final String fileSize;
  final String? duration;
  final int downloadCount;
  final bool isNew;
  final bool isPopular;
  final List<String> tags;
  final DifficultyLevel difficulty;

  const StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.teacherName,
    required this.teacherAvatar,
    required this.uploadedOn,
    required this.fileSize,
    this.duration,
    required this.downloadCount,
    this.isNew = false,
    this.isPopular = false,
    this.tags = const [],
    this.difficulty = DifficultyLevel.intermediate,
  });
}

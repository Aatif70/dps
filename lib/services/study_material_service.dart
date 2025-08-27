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

  // Method to construct full file URL for viewing
  static String getFileUrl(String fileName) {
    if (fileName.isEmpty) return '';
    
    // Remove leading slash if present to avoid double slashes
    String cleanFileName = fileName.startsWith('/') ? fileName.substring(1) : fileName;
    
    // Construct the full URL
    return '${ApiConstants.baseUrl}/$cleanFileName';
  }

  // Method to check if file is viewable in browser
  static bool isViewableInBrowser(String fileName) {
    if (fileName.isEmpty) return false;
    
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return true;
      default:
        return false;
    }
  }

  // Method to get file type for proper handling
  static String getFileType(String fileName) {
    if (fileName.isEmpty) return 'unknown';
    
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'pdf';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'mkv':
        return 'video';

      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return 'image';
      case 'doc':
      case 'docx':
        return 'document';
      case 'xls':
      case 'xlsx':
        return 'spreadsheet';
      case 'ppt':
      case 'pptx':
        return 'presentation';
      default:
        return 'unknown';
    }
  }

  // Method to validate if URL is accessible
  static Future<bool> isUrlAccessible(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('URL accessibility check failed: $e');
      return false;
    }
  }

  // Method to get file size from URL (if available)
  static Future<String> getFileSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      final contentLength = response.headers['content-length'];
      if (contentLength != null) {
        final sizeInBytes = int.parse(contentLength);
        if (sizeInBytes < 1024) {
          return '${sizeInBytes} B';
        } else if (sizeInBytes < 1024 * 1024) {
          return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
        } else {
          return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      }
      return 'Unknown size';
    } catch (e) {
      return 'Unknown size';
    }
  }

  // Method to get file extension from filename
  static String getFileExtension(String fileName) {
    if (fileName.isEmpty) return '';
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Method to get clean filename without path
  static String getCleanFileName(String fileName) {
    if (fileName.isEmpty) return '';
    final parts = fileName.split('/');
    return parts.last;
  }

  // Test method to verify URL construction
  static void testUrlConstruction() {
    print('=== URL CONSTRUCTION TEST ===');
    
    final testCases = [
      '/StudyMaterial/10002---test.pdf',
      'StudyMaterial/10002---test.pdf',
      '/StudyMaterial/test.jpg',
      'StudyMaterial/test.jpg',
      '',
    ];

    for (final testCase in testCases) {
      final url = getFileUrl(testCase);
      final fileType = getFileType(testCase);
      final isViewable = isViewableInBrowser(testCase);
      
      print('Input: "$testCase"');
      print('URL: "$url"');
      print('Type: $fileType');
      print('Viewable: $isViewable');
      print('---');
    }
    
    print('=== END URL CONSTRUCTION TEST ===');
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
enum MaterialType { pdf, video }
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

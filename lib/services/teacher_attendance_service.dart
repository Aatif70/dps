import 'dart:convert';
import 'package:AES/constants/api_constants.dart';
import 'package:flutter/cupertino.dart';
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
        debugPrint('ERROR: Uid or EmpId not found in SharedPreferences');
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

      debugPrint('Classes API Response: ${response.body}');

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
      debugPrint('Error getting classes: $e');
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
        debugPrint('ERROR: Uid or EmpId not found in SharedPreferences');
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

      debugPrint('Batches API Response: ${response.body}');

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
      debugPrint('Error getting batches: $e');
      return [];
    }
  }

  // Get divisions by class ID
  static Future<List<DivisionData>> getDivisionsByClassId(int classId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      if (uid.isEmpty) {
        debugPrint('ERROR: Uid not found in SharedPreferences');
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

      debugPrint('Divisions API Response: ${response.body}');

      if (response.statusCode == 200) {
        final List jsonData = json.decode(response.body);
        return jsonData.map((item) => DivisionData.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting divisions: $e');
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
        debugPrint('ERROR: Uid or EmpId not found in SharedPreferences');
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

      debugPrint('Subjects API Response: ${response.body}');

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
      debugPrint('Error getting subjects: $e');
      return [];
    }
  }

  // NEW: Get students for attendance
  static Future<List<AttendanceStudent>> getAttendanceStudentList({
    required int subjectId,
    required int classId,
    required int divisionId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      if (uid.isEmpty) {
        debugPrint('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('=== LOADING ATTENDANCE STUDENT LIST ===');
      debugPrint('SubjectId: $subjectId, ClassId: $classId, DivisionId: $divisionId');

      final url = Uri.parse('$baseUrl/api/User/AttendanceStudntList');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'SubjectId': subjectId.toString(),
          'ClassId': classId.toString(),
          'DivisionId': divisionId.toString(),
        },
      );

      debugPrint('Attendance Students API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final students = (jsonData['data'] as List)
              .map((item) => AttendanceStudent.fromJson(item))
              .toList();
          debugPrint('Successfully loaded ${students.length} students');
          return students;
        } else {
          debugPrint('API returned success=false or null data');
        }
      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('Error getting attendance student list: $e');
      return [];
    }
  }

  // NEW: Get students division-wise (alternate endpoint)
  static Future<List<AttendanceStudent>> getDivisionWiseStudents({
    required int classId,
    required int divisionId,
  }) async {
    try {
      debugPrint('=== [DivisionWiseStudent] START ===');
      debugPrint('[DivisionWiseStudent][Config] baseUrl=$baseUrl');
      debugPrint('[DivisionWiseStudent][Params] ClassId=$classId, DivisionId=$divisionId');

      // Helper to perform a POST attempt with detailed logs
      Future<http.Response> _attemptPost(Uri uri) async {
        debugPrint('[DivisionWiseStudent][Request] POST -> $uri');
        final headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        };
        final body = {
          'ClassId': classId.toString(),
          'DivisionId': divisionId.toString(),
        };
        debugPrint('[DivisionWiseStudent][Request][Headers] $headers');
        debugPrint('[DivisionWiseStudent][Request][Body] $body');
        final sw = Stopwatch()..start();
        final res = await http.post(uri, headers: headers, body: body);
        sw.stop();
        debugPrint('[DivisionWiseStudent][Response] code=${res.statusCode} (${sw.elapsedMilliseconds}ms)');
        debugPrint('[DivisionWiseStudent][Response][Body] ${res.body}');
        return res;
      }

      // Try canonical route first
      final attempts = <Uri>[
        Uri.parse('$baseUrl/api/User/DivisionWiseStudent').replace(queryParameters: {
          'ClassId': classId.toString(),
          'DivisionId': divisionId.toString(),
        }),
        // Try trailing slash
        Uri.parse('$baseUrl/api/User/DivisionWiseStudent/').replace(queryParameters: {
          'ClassId': classId.toString(),
          'DivisionId': divisionId.toString(),
        }),
        // Try lowercase controller
        Uri.parse('$baseUrl/api/user/DivisionWiseStudent').replace(queryParameters: {
          'ClassId': classId.toString(),
          'DivisionId': divisionId.toString(),
        }),
        // Try without /api
        Uri.parse('$baseUrl/User/DivisionWiseStudent').replace(queryParameters: {
          'ClassId': classId.toString(),
          'DivisionId': divisionId.toString(),
        }),
      ];

      http.Response? response;
      for (final uri in attempts) {
        response = await _attemptPost(uri);
        // Break if we got a 200 or a body with a plausible data list
        if (response.statusCode == 200) break;
        final bodyText = response.body;
        if (bodyText.contains('No HTTP resource was found') ||
            bodyText.contains('does not support http method')) {
          debugPrint('[DivisionWiseStudent][RouteHint] Route mismatch for $uri, trying next...');
          continue;
        }
        // If other 2xx/3xx, attempt to parse anyway
        if (response.statusCode >= 200 && response.statusCode < 400) break;
      }

      if (response != null && response.statusCode >= 200 && response.statusCode < 400) {
        final dynamic root = json.decode(response.body);
        // API may return { success: false, data: [...] } or just a bare list.
        final dynamic dataNode =
            (root is Map<String, dynamic>) ? root['data'] : root;
        if (dataNode is List) {
          final List<AttendanceStudent> students = dataNode.map((dynamic item) {
            final Map<String, dynamic> m = (item as Map).cast<String, dynamic>();
            // Map minimal fields; fill sensible defaults for missing ones
            final int studentId = (m['StudentId'] ?? 0) as int;
            final String name = (m['Name'] ?? '') as String;
            final String prn = (m['CollegePRN'] ?? '')?.toString() ?? '';
            // Try to infer roll number from name like "Foo Bar (107)"
            int inferredRoll = 0;
            final RegExp rollRegex = RegExp(r'\((\d+)\)');
            final match = rollRegex.firstMatch(name);
            if (match != null) {
              inferredRoll = int.tryParse(match.group(1) ?? '0') ?? 0;
            }
            return AttendanceStudent(
              studentId: studentId,
              name: name,
              classId: classId,
              studentRollNo: inferredRoll,
              admissionId: 0,
              gender: '',
              studentContactNo: '',
              fatherContactNo: '',
              attendanceStatus: false,
              collegePRN: prn,
              detailId: null,
            );
          }).toList();
          debugPrint('Successfully loaded ${students.length} division-wise students');
          debugPrint('=== [DivisionWiseStudent] END (success) ===');
          return students;
        }
      }
      debugPrint('[DivisionWiseStudent][Error] No parseable data returned');
      debugPrint('=== [DivisionWiseStudent] END (no-data) ===');
      return [];
    } catch (e) {
      debugPrint('Error getting division-wise students: $e');
      debugPrint('=== [DivisionWiseStudent] END (exception) ===');
      return [];
    }
  }

  // NEW: Save attendance
  static Future<bool> saveAttendance({
    required String attendanceDate,
    required int subjectId,
    required int classMasterId,
    required int classId,
    required int divisionId,
    required List<AttendanceStudent> students,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.get('Id')?.toString() ?? '';

      if (uid.isEmpty || empId.isEmpty) {
        debugPrint('ERROR: Uid or EmpId not found in SharedPreferences');
        return false;
      }

      debugPrint('=== SAVING ATTENDANCE ===');
      debugPrint('Date: $attendanceDate, SubjectId: $subjectId, ClassId: $classId, DivisionId: $divisionId');

      // Prepare attendance data
      final attendanceData = {
        "DAM": {
          "AttDate": attendanceDate,
          "SubjectId": subjectId,
          "SubTypeId": 1,
          "EmpId": int.parse(empId),
          "TimeFrom": "09:00",
          "TimeTo": "10:00",
          "ClassMasterId": classMasterId,
          "ClassId": classId,
          "DivisionId": divisionId,
          "Batch": null,
          "PracticalId": null,
          "CreatedBy": uid
        },
        "DAD": students.map((student) => {
          "StudentId": student.studentId,
          "Name": student.name,
          "ClassId": student.classId,
          "StudentRollNo": student.studentRollNo,
          "AdmissionId": student.admissionId,
          "AttendanceStatus": student.attendanceStatus.toString()
        }).toList()
      };

      debugPrint('Attendance data to save: ${json.encode(attendanceData)}');

      final url = Uri.parse('$baseUrl/api/User/AttendanceSave');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(attendanceData),
      );

      debugPrint('Save Attendance API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          debugPrint('Attendance saved successfully');
          return true;
        } else {
          debugPrint('API returned success=false: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        debugPrint('Save attendance failed with status: ${response.statusCode}');
      }
      return false;
    } catch (e) {
      debugPrint('Error saving attendance: $e');
      return false;
    }
  }

  // NEW: Get attendance records for date range
  static Future<List<AttendanceRecord>> getAttendanceRecords({
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.get('Id')?.toString() ?? '';

      if (uid.isEmpty || empId.isEmpty) {
        debugPrint('ERROR: Uid or EmpId not found in SharedPreferences');
        return [];
      }

      debugPrint('=== GETTING ATTENDANCE RECORDS ===');
      debugPrint('From Date: $fromDate, To Date: $toDate');

      final url = Uri.parse('$baseUrl${ApiConstants.attendanceEmpIndex}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'EmpId': empId,
          'FD': fromDate,
          'TD': toDate,
        },
      );

      debugPrint('Attendance Records API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final records = (jsonData['data'] as List)
              .map((item) => AttendanceRecord.fromJson(item))
              .toList();
          debugPrint('Successfully loaded ${records.length} attendance records');
          return records;
        } else {
          debugPrint('API returned success=false or null data');
        }
      } else {
        debugPrint('Get attendance records failed with status: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('Error getting attendance records: $e');
      return [];
    }
  }

  // NEW: Get student details for specific attendance
  static Future<List<StudentAttendanceDetail>> getStudentDetails({
    required int attId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      if (uid.isEmpty) {
        debugPrint('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('=== GETTING STUDENT DETAILS ===');
      debugPrint('Attendance ID: $attId');

      final url = Uri.parse('$baseUrl${ApiConstants.studentDetails}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'Attid': attId.toString(),
        },
      );

      debugPrint('Student Details API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final details = (jsonData['data'] as List)
              .map((item) => StudentAttendanceDetail.fromJson(item))
              .toList();
          debugPrint('Successfully loaded ${details.length} student details');
          return details;
        } else {
          debugPrint('API returned success=false or null data');
        }
      } else {
        debugPrint('Get student details failed with status: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('Error getting student details: $e');
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

// NEW: Attendance Student Model
class AttendanceStudent {
  final int studentId;
  final String name;
  final int classId;
  final int studentRollNo;
  final int admissionId;
  final String gender;
  final String studentContactNo;
  final String fatherContactNo;
  bool attendanceStatus;
  final String collegePRN;
  final int? detailId;

  AttendanceStudent({
    required this.studentId,
    required this.name,
    required this.classId,
    required this.studentRollNo,
    required this.admissionId,
    required this.gender,
    required this.studentContactNo,
    required this.fatherContactNo,
    required this.attendanceStatus,
    required this.collegePRN,
    this.detailId,
  });

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) {
    return AttendanceStudent(
      studentId: json['StudentId'] ?? 0,
      name: json['Name'] ?? '',
      classId: json['ClassId'] ?? 0,
      studentRollNo: json['StudentRollNo'] ?? 0,
      admissionId: json['AdmissionId'] ?? 0,
      gender: json['Gender'] ?? '',
      studentContactNo: json['StudentContactNo'] ?? '',
      fatherContactNo: json['FatherContactNo'] ?? '',
      attendanceStatus: json['AttendanceStatus'] ?? false,
      collegePRN: json['CollegePRN'] ?? '',
      detailId: json['DetailId'],
    );
  }
}

// NEW: Attendance Record Model
class AttendanceRecord {
  final String name;
  final DateTime attDate;
  final String className;
  final String batch;
  final String subjectName;
  final String? topicName;
  final String? subTopicName;
  final String timeFrom;
  final String timeTo;
  final int attId;
  final String subTypeName;

  AttendanceRecord({
    required this.name,
    required this.attDate,
    required this.className,
    required this.batch,
    required this.subjectName,
    this.topicName,
    this.subTopicName,
    required this.timeFrom,
    required this.timeTo,
    required this.attId,
    required this.subTypeName,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      name: json['Name'] ?? '',
      attDate: DateTime.tryParse(json['AttDate'] ?? '') ?? DateTime.now(),
      className: json['ClassName'] ?? '',
      batch: json['Batch'] ?? '',
      subjectName: json['SubjectName'] ?? '',
      topicName: json['TopicName'],
      subTopicName: json['SubTopicName'],
      timeFrom: json['TimeFrom'] ?? '',
      timeTo: json['TimeTo'] ?? '',
      attId: json['AttId'] ?? 0,
      subTypeName: json['SubTypeName'] ?? '',
    );
  }
}

// NEW: Student Attendance Detail Model
class StudentAttendanceDetail {
  final int studentId;
  final int? presentRno;
  final bool status;
  final String name;
  final String collegePRN;

  StudentAttendanceDetail({
    required this.studentId,
    this.presentRno,
    required this.status,
    required this.name,
    required this.collegePRN,
  });

  factory StudentAttendanceDetail.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceDetail(
      studentId: json['StudentId'] ?? 0,
      presentRno: json['PresentRno'],
      status: json['Status'] ?? false,
      name: json['Name'] ?? '',
      collegePRN: json['CollegePRN'] ?? '',
    );
  }
}

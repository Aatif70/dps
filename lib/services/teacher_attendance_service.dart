import 'dart:convert';
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
        print('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      print('=== LOADING ATTENDANCE STUDENT LIST ===');
      print('SubjectId: $subjectId, ClassId: $classId, DivisionId: $divisionId');

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

      print('Attendance Students API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final students = (jsonData['data'] as List)
              .map((item) => AttendanceStudent.fromJson(item))
              .toList();
          print('Successfully loaded ${students.length} students');
          return students;
        } else {
          print('API returned success=false or null data');
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('Error getting attendance student list: $e');
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
        print('ERROR: Uid or EmpId not found in SharedPreferences');
        return false;
      }

      print('=== SAVING ATTENDANCE ===');
      print('Date: $attendanceDate, SubjectId: $subjectId, ClassId: $classId, DivisionId: $divisionId');

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

      print('Attendance data to save: ${json.encode(attendanceData)}');

      final url = Uri.parse('$baseUrl/api/User/AttendanceSave');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(attendanceData),
      );

      print('Save Attendance API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          print('Attendance saved successfully');
          return true;
        } else {
          print('API returned success=false: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        print('Save attendance failed with status: ${response.statusCode}');
      }
      return false;
    } catch (e) {
      print('Error saving attendance: $e');
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
        print('ERROR: Uid or EmpId not found in SharedPreferences');
        return [];
      }

      print('=== GETTING ATTENDANCE RECORDS ===');
      print('From Date: $fromDate, To Date: $toDate');

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

      print('Attendance Records API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final records = (jsonData['data'] as List)
              .map((item) => AttendanceRecord.fromJson(item))
              .toList();
          print('Successfully loaded ${records.length} attendance records');
          return records;
        } else {
          print('API returned success=false or null data');
        }
      } else {
        print('Get attendance records failed with status: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('Error getting attendance records: $e');
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
        print('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      print('=== GETTING STUDENT DETAILS ===');
      print('Attendance ID: $attId');

      final url = Uri.parse('$baseUrl${ApiConstants.studentDetails}');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'Attid': attId.toString(),
        },
      );

      print('Student Details API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final details = (jsonData['data'] as List)
              .map((item) => StudentAttendanceDetail.fromJson(item))
              .toList();
          print('Successfully loaded ${details.length} student details');
          return details;
        } else {
          print('API returned success=false or null data');
        }
      } else {
        print('Get student details failed with status: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('Error getting student details: $e');
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

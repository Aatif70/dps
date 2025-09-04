import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

class AdminEmployeeDetailsService {
  static Future<EmployeeDetailsResponse?> fetchEmployeeDetails({required int empId}) async {
    try {
      debugPrint('AdminEmployeeDetailsService.fetchEmployeeDetails() called with EmpId: $empId');
      // Switch to GET with query parameter as per API contract
      final Uri url = Uri.parse('${ApiConstants.baseUrl}/api/Employee/EmpDetails?EmpId=$empId');
      debugPrint('Employee Details URL (GET): $url');

      final http.Response response = await http.get(url);
      debugPrint('EmpDetails statusCode: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        final String preview = response.body.length > 500 ? ('${response.body.substring(0, 500)}...') : response.body;
        debugPrint('EmpDetails raw response preview: $preview');
      } else {
        debugPrint('EmpDetails empty response body');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (jsonData['success'] == true && jsonData['data'] != null) {
          try {
            final data = jsonData['data'] as Map<String, dynamic>;
            debugPrint('EmpDetails success=true; Keys: ' + data.keys.join(', '));
          } catch (_) {}
          return EmployeeDetailsResponse.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
        debugPrint('EmpDetails success!=true or data==null. success=' + (jsonData['success']?.toString() ?? 'null'));
      }
      debugPrint('EmpDetails non-200 status or parsing failed');
    } catch (_) {}
    return null;
  }
}

class EmployeeDetailsResponse {
  final List<PersonalDetail> personalDetails;
  final List<ClassAndSubject> classAndSubject;
  final List<EmployeeTimeTable> empTimeTable;

  EmployeeDetailsResponse({
    required this.personalDetails,
    required this.classAndSubject,
    required this.empTimeTable,
  });

  factory EmployeeDetailsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> personal = (json['PersonalDetails'] as List? ?? <dynamic>[]);
    final List<dynamic> classes = (json['ClassAndSubject'] as List? ?? <dynamic>[]);
    final List<dynamic> timeTables = (json['EmpTimeTable'] as List? ?? <dynamic>[]);

    return EmployeeDetailsResponse(
      personalDetails: personal.map((e) => PersonalDetail.fromJson(e as Map<String, dynamic>)).toList(),
      classAndSubject: classes.map((e) => ClassAndSubject.fromJson(e as Map<String, dynamic>)).toList(),
      empTimeTable: timeTables.map((e) => EmployeeTimeTable.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class PersonalDetail {
  final int empId;
  final String name;
  final String gender;
  final String joiningDate;
  final String dob;
  final String email;
  final String designation;

  PersonalDetail({
    required this.empId,
    required this.name,
    required this.gender,
    required this.joiningDate,
    required this.dob,
    required this.email,
    required this.designation,
  });

  factory PersonalDetail.fromJson(Map<String, dynamic> json) {
    return PersonalDetail(
      empId: int.tryParse((json['EmpId'] ?? '0').toString()) ?? 0,
      name: (json['Name'] ?? '').toString(),
      gender: (json['Gender'] ?? '').toString(),
      joiningDate: (json['JoiningDate'] ?? '').toString(),
      dob: (json['DOB'] ?? '').toString(),
      email: (json['Email'] ?? '').toString(),
      designation: (json['Designation'] ?? '').toString(),
    );
  }
}

class ClassAndSubject {
  final int classMasterId;
  final String className;
  final List<SubjectItem> subjects;

  ClassAndSubject({
    required this.classMasterId,
    required this.className,
    required this.subjects,
  });

  factory ClassAndSubject.fromJson(Map<String, dynamic> json) {
    final List<dynamic> subs = (json['Subjects'] as List? ?? <dynamic>[]);
    return ClassAndSubject(
      classMasterId: int.tryParse((json['ClassMasterId'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
      subjects: subs.map((e) => SubjectItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class SubjectItem {
  final String subjectName;
  final String subTypeName;

  SubjectItem({
    required this.subjectName,
    required this.subTypeName,
  });

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      subjectName: (json['SubjectName'] ?? '').toString(),
      subTypeName: (json['SubTypeName'] ?? '').toString(),
    );
  }
}

class EmployeeTimeTable {
  final int empId;
  final String teacherName;
  final List<TimeTableItem> timeTables;

  EmployeeTimeTable({
    required this.empId,
    required this.teacherName,
    required this.timeTables,
  });

  factory EmployeeTimeTable.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = (json['TimeTables'] as List? ?? <dynamic>[]);
    return EmployeeTimeTable(
      empId: int.tryParse((json['EmpId'] ?? '0').toString()) ?? 0,
      teacherName: (json['TeacherName'] ?? '').toString(),
      timeTables: list.map((e) => TimeTableItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class TimeTableItem {
  final int timeTableId;
  final int empId;
  final String courseName;
  final String className;
  final String batch;
  final String division;
  final String teacherName;
  final String subject;
  final String weekDay;
  final String fromTime;
  final String toTime;
  final String subType;

  TimeTableItem({
    required this.timeTableId,
    required this.empId,
    required this.courseName,
    required this.className,
    required this.batch,
    required this.division,
    required this.teacherName,
    required this.subject,
    required this.weekDay,
    required this.fromTime,
    required this.toTime,
    required this.subType,
  });

  factory TimeTableItem.fromJson(Map<String, dynamic> json) {
    return TimeTableItem(
      timeTableId: int.tryParse((json['TimeTableId'] ?? '0').toString()) ?? 0,
      empId: int.tryParse((json['EmpId'] ?? '0').toString()) ?? 0,
      courseName: (json['CourseName'] ?? '').toString(),
      className: (json['Class'] ?? '').toString(),
      batch: (json['Batch'] ?? '').toString(),
      division: (json['Division'] ?? '').toString(),
      teacherName: (json['TeacherName'] ?? '').toString(),
      subject: (json['Subject'] ?? '').toString(),
      weekDay: (json['WeekDay'] ?? '').toString(),
      fromTime: (json['FromTime'] ?? '').toString(),
      toTime: (json['ToTime'] ?? '').toString(),
      subType: (json['SubType'] ?? '').toString(),
    );
  }
}



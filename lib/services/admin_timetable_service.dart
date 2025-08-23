import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class AdminTimetableService {
  static Future<List<TeacherTimetableData>> getTeacherTimetables() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/TimeTable');
      final request = http.MultipartRequest('GET', url);
      request.fields['UId'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((json) => TeacherTimetableData.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching teacher timetables: $e');
      return [];
    }
  }

  // Add new timetable
  static Future<Map<String, dynamic>> addTimetable({
    required int classId,
    required int batchId,
    required int divisionId,
    required int empId,
    required String weekDay,
    required int subId,
    required String fromTime,
    required String toTime,
    required int subTypeId,
  }) async {
    try {
      print('=== ADDING TIMETABLE ===');
      print('ClassId: $classId');
      print('BatchId: $batchId');
      print('DivisionId: $divisionId');
      print('EmpId: $empId');
      print('WeekDay: $weekDay');
      print('SubId: $subId');
      print('FromTime: $fromTime');
      print('ToTime: $toTime');
      print('SubTypeId: $subTypeId');

      final url = Uri.parse('${ApiConstants.baseUrl}/api/Teacher/AddTimeTable');
      
      final body = {
        "ClassId": classId,
        "BatchId": batchId,
        "DivisionId": divisionId,
        "EmpId": empId,
        "WeekDay": weekDay,
        "SubId": subId,
        "FromTime": fromTime,
        "ToTime": toTime,
        "SubTypeId": subTypeId
      };

      print('Request body: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      print('Add Timetable API Response Status: ${response.statusCode}');
      print('Add Timetable API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        print('Error: HTTP ${response.statusCode}');
        return {'success': false, 'message': 'HTTP ${response.statusCode} error'};
      }
    } catch (e) {
      print('Error adding timetable: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get all classes
  static Future<List<ClassMasterItem>> getClasses() async {
    try {
      print('🔍 === GETTING CLASSES ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        print('❌ ERROR: Uid not found in SharedPreferences');
        return [];
      }

      print('   🔑 Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.classMasters}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      print('   🌐 Classes API URL: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('   📥 Classes API Response Status: ${response.statusCode}');
      print('   📄 Classes API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('   🔍 Response JSON: $jsonData');
        
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          print('   📊 Data list length: ${data.length}');
          
          final result = data.map((c) => ClassMasterItem.fromJson(c as Map<String, dynamic>)).toList();
          print('   ✅ Successfully parsed ${result.length} classes');
          
          for (int i = 0; i < result.length; i++) {
            final cls = result[i];
            print('     📚 Class $i: ID=${cls.classMasterId}, Name="${cls.className}", Year=${cls.courseYear}');
          }
          
          return result;
        } else {
          print('   ❌ API returned success=false or data is not a list');
          print('   🔍 Success: ${jsonData['success']}');
          print('   🔍 Data type: ${jsonData['data']?.runtimeType}');
        }
      } else {
        print('   ❌ HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('❌ === ERROR GETTING CLASSES ===');
      print('   Error: $e');
      print('   Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get batches by class master ID
  static Future<List<BatchItem>> getBatchesByClassMaster(int classMasterId) async {
    try {
      print('=== GETTING BATCHES BY CLASS MASTER ===');
      print('ClassMasterId: $classMasterId');
      
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        print('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      print('Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminBatches}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      print('Batches API URL: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Batches API Response Status: ${response.statusCode}');
      print('Batches API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          final allBatches = data.map((b) => BatchItem.fromJson(b as Map<String, dynamic>)).toList();
          
          // Filter batches by class master ID
          final filteredBatches = allBatches.where((batch) => batch.classMasterId == classMasterId).toList();
          print('Found ${filteredBatches.length} batches for class master $classMasterId');
          return filteredBatches;
        }
      }
      return [];
    } catch (e) {
      print('Error getting batches: $e');
      return [];
    }
  }

  // Get divisions by class ID
  static Future<List<DivisionItem>> getDivisionsByClass(int classId) async {
    try {
      print('=== GETTING DIVISIONS BY CLASS ===');
      print('ClassId: $classId');
      
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        print('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      print('Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminDivisions}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      print('Divisions API URL: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Divisions API Response Status: ${response.statusCode}');
      print('Divisions API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          final allDivisions = data.map((d) => DivisionItem.fromJson(d as Map<String, dynamic>)).toList();
          
          // Filter divisions by class ID
          final filteredDivisions = allDivisions.where((div) => div.classId == classId).toList();
          print('Found ${filteredDivisions.length} divisions for class $classId');
          return filteredDivisions;
        }
      }
      return [];
    } catch (e) {
      print('Error getting divisions: $e');
      return [];
    }
  }

  // Get all employees
  static Future<List<EmployeeItem>> getEmployees() async {
    try {
      print('=== GETTING EMPLOYEES ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        print('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      print('Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.employeesList}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      print('Employees API URL: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Employees API Response Status: ${response.statusCode}');
      print('Employees API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          final result = data.map((e) => EmployeeItem.fromJson(e as Map<String, dynamic>)).toList();
          print('Successfully parsed ${result.length} employees');
          return result;
        }
      }
      return [];
    } catch (e) {
      print('Error getting employees: $e');
      return [];
    }
  }

  // Get subjects by class master ID
  static Future<List<SubjectItem>> getSubjectsByClassMaster(int classMasterId) async {
    try {
      print('🔍 === GETTING SUBJECTS BY CLASS MASTER ===');
      print('   📚 ClassMasterId: $classMasterId');
      
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        print('❌ ERROR: Uid not found in SharedPreferences');
        return [];
      }

      print('    Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/Subjects');
      
      print('   🌐 Subjects API URL: $url');
      print('   📤 Request body: Uid=$uid');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
        },
      );

      print('   📥 Subjects API Response Status: ${response.statusCode}');
      print('   📄 Subjects API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('   🔍 Response JSON: $jsonData');
        
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          print('   📊 Data list length: ${data.length}');
          
          final result = data.map((s) => SubjectItem.fromJson(s as Map<String, dynamic>)).toList();
          print('   ✅ Successfully parsed ${result.length} subjects');
          
          for (int i = 0; i < result.length; i++) {
            final subject = result[i];
            print('     📖 Subject $i: ID=${subject.subjectId}, Name="${subject.subjectName}"');
          }
          
          return result;
        } else {
          print('   ❌ API returned success=false or data is not a list');
          print('   🔍 Success: ${jsonData['success']}');
          print('   🔍 Data type: ${jsonData['data']?.runtimeType}');
        }
      } else {
        print('   ❌ HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('❌ === ERROR GETTING SUBJECTS ===');
      print('   Error: $e');
      print('   Stack trace: ${StackTrace.current}');
      return [];
    }
  }
}

// Data models for timetable creation
class ClassMasterItem {
  final int classMasterId;
  final int courseMasterId;
  final String className;
  final int courseYear;
  final String rollNoPrefix;

  ClassMasterItem({
    required this.classMasterId,
    required this.courseMasterId,
    required this.className,
    required this.courseYear,
    required this.rollNoPrefix,
  });

  factory ClassMasterItem.fromJson(Map<String, dynamic> json) {
    return ClassMasterItem(
      classMasterId: int.tryParse((json['ClassMasterId'] ?? '0').toString()) ?? 0,
      courseMasterId: int.tryParse((json['CourseMasterId'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
      courseYear: int.tryParse((json['CourseYear'] ?? '0').toString()) ?? 0,
      rollNoPrefix: (json['RollNoPreFix'] ?? '').toString(),
    );
  }
}

class BatchItem {
  final int classId;
  final int classMasterId;
  final int courseYear;
  final String batchName;

  BatchItem({
    required this.classId,
    required this.classMasterId,
    required this.courseYear,
    required this.batchName,
  });

  factory BatchItem.fromJson(Map<String, dynamic> json) {
    return BatchItem(
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      classMasterId: int.tryParse((json['ClassMasterId'] ?? '0').toString()) ?? 0,
      courseYear: int.tryParse((json['CourseYear'] ?? '0').toString()) ?? 0,
      batchName: (json['BatchName'] ?? '').toString(),
    );
  }
}

class DivisionItem {
  final int divisionId;
  final int classId;
  final int empId;
  final String divName;

  DivisionItem({
    required this.divisionId,
    required this.classId,
    required this.empId,
    required this.divName,
  });

  factory DivisionItem.fromJson(Map<String, dynamic> json) {
    return DivisionItem(
      divisionId: int.tryParse((json['DivisionId'] ?? '0').toString()) ?? 0,
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      empId: int.tryParse((json['EmpId'] ?? '0').toString()) ?? 0,
      divName: (json['DivName'] ?? '').toString(),
    );
  }
}

class EmployeeItem {
  final int empId;
  final String name;
  final String mobile;
  final String email;
  final String? phoneNo;
  final String designationName;

  EmployeeItem({
    required this.empId,
    required this.name,
    required this.mobile,
    required this.email,
    required this.phoneNo,
    required this.designationName,
  });

  factory EmployeeItem.fromJson(Map<String, dynamic> json) {
    return EmployeeItem(
      empId: int.tryParse((json['EmpId'] ?? '0').toString()) ?? 0,
      name: (json['Name'] ?? '').toString(),
      mobile: (json['Mobile'] ?? '').toString(),
      email: (json['Email'] ?? '').toString(),
      phoneNo: json['PhoneNo']?.toString(),
      designationName: (json['DesignationName'] ?? '').toString(),
    );
  }
}

class SubjectItem {
  final int subjectId;
  final String subjectName;

  SubjectItem({
    required this.subjectId,
    required this.subjectName,
  });

  factory SubjectItem.fromJson(Map<String, dynamic> json) {
    return SubjectItem(
      subjectId: json['SubjectId'] ?? 0,
      subjectName: json['SubjectName'] ?? '',
    );
  }
}

class TeacherTimetableData {
  final int empId;
  final String teacherName;
  final List<TimetableEntry> timetables;

  TeacherTimetableData({
    required this.empId,
    required this.teacherName,
    required this.timetables,
  });

  factory TeacherTimetableData.fromJson(Map<String, dynamic> json) {
    return TeacherTimetableData(
      empId: json['EmpId'] ?? 0,
      teacherName: json['TeacherName'] ?? '',
      timetables: (json['TimeTables'] as List<dynamic>?)
          ?.map((item) => TimetableEntry.fromJson(item))
          .toList() ?? [],
    );
  }
}

class TimetableEntry {
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

  TimetableEntry({
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

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      timeTableId: json['TimeTableId'] ?? 0,
      empId: json['EmpId'] ?? 0,
      courseName: json['CourseName'] ?? '',
      className: json['Class'] ?? '',
      batch: json['Batch'] ?? '',
      division: json['Division'] ?? '',
      teacherName: json['TeacherName'] ?? '',
      subject: json['Subject'] ?? '',
      weekDay: json['WeekDay'] ?? '',
      fromTime: json['FromTime'] ?? '',
      toTime: json['ToTime'] ?? '',
      subType: json['SubType'] ?? '',
    );
  }
}

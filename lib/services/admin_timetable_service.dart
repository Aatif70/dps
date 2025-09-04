import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

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

      debugPrint('🔍 === GET TEACHER TIMETABLES ===');
      debugPrint('   🌐 URL: $url');
      debugPrint('   🔑 UId: $uid');
      debugPrint('   📥 Status: ${response.statusCode}');
      debugPrint('   📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          final list = data.map((json) => TeacherTimetableData.fromJson(json)).toList();
          debugPrint('   ✅ Parsed teachers: ${list.length}');
          for (int i = 0; i < list.length; i++) {
            final t = list[i];
            debugPrint('     👤 [$i] EmpId=${t.empId}, Name=${t.teacherName}, classes=${t.timetables.length}');
          }
          return list;
        } else {
          debugPrint('   ❌ Unexpected JSON shape for teacher timetables');
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching teacher timetables: $e');
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
      debugPrint('=== ADDING TIMETABLE ===');
      debugPrint('ClassId: $classId');
      debugPrint('BatchId: $batchId');
      debugPrint('DivisionId: $divisionId');
      debugPrint('EmpId: $empId');
      debugPrint('WeekDay: $weekDay');
      debugPrint('SubId: $subId');
      debugPrint('FromTime: $fromTime');
      debugPrint('ToTime: $toTime');
      debugPrint('SubTypeId: $subTypeId');

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

      debugPrint('Request body: ${json.encode(body)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('Add Timetable API Response Status: ${response.statusCode}');
      debugPrint('Add Timetable API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        debugPrint('Error: HTTP ${response.statusCode}');
        return {'success': false, 'message': 'HTTP ${response.statusCode} error'};
      }
    } catch (e) {
      debugPrint('Error adding timetable: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get all classes
  static Future<List<ClassMasterItem>> getClasses() async {
    try {
      debugPrint('🔍 === GETTING CLASSES ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        debugPrint('❌ ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('   🔑 Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.classMasters}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      debugPrint('   🌐 Classes API URL: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('   📥 Classes API Response Status: ${response.statusCode}');
      debugPrint('   📄 Classes API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('   🔍 Response JSON: $jsonData');
        
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          debugPrint('   📊 Data list length: ${data.length}');
          
          final result = data.map((c) => ClassMasterItem.fromJson(c as Map<String, dynamic>)).toList();
          debugPrint('   ✅ Successfully parsed ${result.length} classes');
          
          for (int i = 0; i < result.length; i++) {
            final cls = result[i];
            debugPrint('     📚 Class $i: ID=${cls.classMasterId}, Name="${cls.className}", Year=${cls.courseYear}');
          }
          
          return result;
        } else {
          debugPrint('   ❌ API returned success=false or data is not a list');
          debugPrint('   🔍 Success: ${jsonData['success']}');
          debugPrint('   🔍 Data type: ${jsonData['data']?.runtimeType}');
        }
      } else {
        debugPrint('   ❌ HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('❌ === ERROR GETTING CLASSES ===');
      debugPrint('   Error: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get batches by class master ID
  static Future<List<BatchItem>> getBatchesByClassMaster(int classMasterId) async {
    try {
      debugPrint('=== GETTING BATCHES BY CLASS MASTER ===');
      debugPrint('ClassMasterId: $classMasterId');
      
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        debugPrint('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminBatches}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      debugPrint('Batches API URL: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Batches API Response Status: ${response.statusCode}');
      debugPrint('Batches API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          final allBatches = data.map((b) => BatchItem.fromJson(b as Map<String, dynamic>)).toList();
          
          // Filter batches by class master ID
          final filteredBatches = allBatches.where((batch) => batch.classMasterId == classMasterId).toList();
          debugPrint('Found ${filteredBatches.length} batches for class master $classMasterId');
          return filteredBatches;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting batches: $e');
      return [];
    }
  }

  // Get divisions by class ID
  static Future<List<DivisionItem>> getDivisionsByClass(int classId) async {
    try {
      debugPrint('=== GETTING DIVISIONS BY CLASS ===');
      debugPrint('ClassId: $classId');
      
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        debugPrint('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminDivisions}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      debugPrint('Divisions API URL: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Divisions API Response Status: ${response.statusCode}');
      debugPrint('Divisions API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          final allDivisions = data.map((d) => DivisionItem.fromJson(d as Map<String, dynamic>)).toList();
          
          // Filter divisions by class ID
          final filteredDivisions = allDivisions.where((div) => div.classId == classId).toList();
          debugPrint('Found ${filteredDivisions.length} divisions for class $classId');
          return filteredDivisions;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting divisions: $e');
      return [];
    }
  }

  // Get all employees
  static Future<List<EmployeeItem>> getEmployees() async {
    try {
      debugPrint('=== GETTING EMPLOYEES ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        debugPrint('ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.employeesList}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      debugPrint('Employees API URL: $url');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Employees API Response Status: ${response.statusCode}');
      debugPrint('Employees API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          final result = data.map((e) => EmployeeItem.fromJson(e as Map<String, dynamic>)).toList();
          debugPrint('Successfully parsed ${result.length} employees');
          return result;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting employees: $e');
      return [];
    }
  }

  // Get subjects by class master ID and employee ID
  static Future<List<SubjectItem>> getSubjectsByClassMasterAndEmployee(int classMasterId, int empId) async {
    try {
      debugPrint('🔍 === GETTING SUBJECTS BY CLASS MASTER AND EMPLOYEE ===');
      debugPrint('   📚 ClassMasterId: $classMasterId');
      debugPrint('    EmployeeId: $empId');
      
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        debugPrint('❌ ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('    Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/SubByEmpId');
      
      debugPrint('   🌐 Subjects API URL: $url');
      debugPrint('   📤 Request body: Uid=$uid, classMasterId=$classMasterId, empId=$empId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'classMasterId': classMasterId.toString(),
          'empId': empId.toString(),
        },
      );

      debugPrint('   📥 Subjects API Response Status: ${response.statusCode}');
      debugPrint('   📄 Subjects API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('   🔍 Response JSON: $jsonData');
        
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          debugPrint('   📊 Data list length: ${data.length}');
          
          final result = data.map((s) => SubjectItem.fromJson(s as Map<String, dynamic>)).toList();
          debugPrint('   ✅ Successfully parsed ${result.length} subjects');
          
          for (int i = 0; i < result.length; i++) {
            final subject = result[i];
            debugPrint('     📖 Subject $i: ID=${subject.subjectId}, Name="${subject.subjectName}"');
          }
          
          return result;
        } else {
          debugPrint('   ❌ API returned success=false or data is not a list');
          debugPrint('   🔍 Success: ${jsonData['success']}');
          debugPrint('   🔍 Data type: ${jsonData['data']?.runtimeType}');
        }
      } else {
        debugPrint('   ❌ HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('❌ === ERROR GETTING SUBJECTS ===');
      debugPrint('   Error: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get subject types by subject ID
  static Future<List<SubjectTypeItem>> getSubjectTypesBySubject(int subjectId) async {
    try {
      debugPrint('🔍 === GETTING SUBJECT TYPES BY SUBJECT ===');
      debugPrint('   📖 SubjectId: $subjectId');
      
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      
      if (uid.isEmpty) {
        debugPrint('❌ ERROR: Uid not found in SharedPreferences');
        return [];
      }

      debugPrint('    Uid: $uid');
      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/Subject');
      
      debugPrint('   🌐 Subject Types API URL: $url');
      debugPrint('   📤 Request body: Uid=$uid, subjectId=$subjectId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'subjectId': subjectId.toString(),
        },
      );

      debugPrint('   📥 Subject Types API Response Status: ${response.statusCode}');
      debugPrint('   📄 Subject Types API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('   🔍 Response JSON: $jsonData');
        
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          debugPrint('   📊 Data list length: ${data.length}');
          
          final result = data.map((st) => SubjectTypeItem.fromJson(st as Map<String, dynamic>)).toList();
          debugPrint('   ✅ Successfully parsed ${result.length} subject types');
          
          for (int i = 0; i < result.length; i++) {
            final subjectType = result[i];
            debugPrint('     🏷️ Subject Type $i: ID=${subjectType.subTypeId}, Name="${subjectType.subTypeName}"');
          }
          
          return result;
        } else {
          debugPrint('   ❌ API returned success=false or data is not a list');
          debugPrint('   🔍 Success: ${jsonData['success']}');
          debugPrint('   🔍 Data type: ${jsonData['data']?.runtimeType}');
        }
      } else {
        debugPrint('   ❌ HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('❌ === ERROR GETTING SUBJECT TYPES ===');
      debugPrint('   Error: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Keep the old method for backward compatibility but mark it as deprecated
  @deprecated
  static Future<List<SubjectItem>> getSubjectsByClassMaster(int classMasterId) async {
    debugPrint('⚠️ DEPRECATED: Use getSubjectsByClassMasterAndEmployee instead');
    return getSubjectsByClassMasterAndEmployee(classMasterId, 0);
  }

  // Get classes by employee ID
  static Future<List<ClassMasterItem>> getClassesByEmployee(int empId) async {
    try {
      debugPrint('🔍 === GETTING CLASSES BY EMPLOYEE ===');
      debugPrint('   👤 EmpId: $empId');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      if (uid.isEmpty) {
        debugPrint('❌ ERROR: Uid not found in SharedPreferences');
        return [];
      }
      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/GetClassByEmpId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'EmpId': empId.toString(),
        },
      );
      debugPrint('   📥 ClassesByEmp API Response Status: ${response.statusCode}');
      debugPrint('   📄 ClassesByEmp API Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((c) => ClassMasterItem.fromJson(c as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ === ERROR GETTING CLASSES BY EMPLOYEE ===');
      debugPrint('   Error: $e');
      return [];
    }
  }

  // Get batches by employee ID and class master ID
  static Future<List<BatchItem>> getBatchesByEmployeeAndClass(int empId, int classMasterId) async {
    try {
      debugPrint('🔍 === GETTING BATCHES BY EMPLOYEE AND CLASS ===');
      debugPrint('   👤 EmpId: $empId, 🏫 ClassMasterId: $classMasterId');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      if (uid.isEmpty) {
        debugPrint('❌ ERROR: Uid not found in SharedPreferences');
        return [];
      }
      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/BatchByEmpId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'empid': empId.toString(),
          'classmid': classMasterId.toString(),
        },
      );
      debugPrint('   📥 BatchByEmp API Response Status: ${response.statusCode}');
      debugPrint('   📄 BatchByEmp API Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data.map((b) => BatchItem.fromJson(b as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ === ERROR GETTING BATCHES BY EMPLOYEE AND CLASS ===');
      debugPrint('   Error: $e');
      return [];
    }
  }

  // Get divisions by class ID
  static Future<List<DivisionItem>> getDivisionsByClassId(int classId) async {
    try {
      debugPrint('🔍 === GETTING DIVISIONS BY CLASS ID ===');
      debugPrint('   🏫 ClassId: $classId');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      if (uid.isEmpty) {
        debugPrint('❌ ERROR: Uid not found in SharedPreferences');
        return [];
      }
      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/DivByEmpId');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'Uid': uid,
          'classId': classId.toString(),
        },
      );
      debugPrint('   📥 DivByEmp API Response Status: ${response.statusCode}');
      debugPrint('   📄 DivByEmp API Response Body: ${response.body}');
      final decoded = json.decode(response.body);
      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic> &&
            decoded['success'] == true &&
            decoded['data'] is List) {
          final List<dynamic> data = decoded['data'];
          final allDivisions = data.map((d) => DivisionItem.fromJson(d as Map<String, dynamic>)).toList();
          // Do not filter by classId, just return all divisions
          debugPrint('Found ${allDivisions.length} divisions');
          return allDivisions;
        } else if (decoded is List) {
          // API returned a raw list
          final List<dynamic> data = decoded;
          final allDivisions = data.map((d) => DivisionItem.fromJson(d as Map<String, dynamic>)).toList();
          debugPrint('Found ${allDivisions.length} divisions (raw list)');
          return allDivisions;
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ === ERROR GETTING DIVISIONS BY CLASS ID ===');
      debugPrint('   Error: $e');
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
      classId: int.tryParse((json['classid'] ?? json['ClassId'] ?? '0').toString()) ?? 0,
      classMasterId: int.tryParse((json['ClassMasterId'] ?? '0').toString()) ?? 0,
      courseYear: int.tryParse((json['CourseYear'] ?? '0').toString()) ?? 0,
      batchName: (json['batch'] ?? json['BatchName'] ?? '').toString(),
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
    // Map both 'DivName' and 'Name' from API to divName for dropdown display
    return DivisionItem(
      divisionId: int.tryParse((json['DivisionId'] ?? '0').toString()) ?? 0,
      classId: int.tryParse((json['ClassId'] ?? '0').toString()) ?? 0,
      empId: int.tryParse((json['EmpId'] ?? '0').toString()) ?? 0,
      divName: (json['DivName'] ?? json['Name'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivisionItem &&
          runtimeType == other.runtimeType &&
          divisionId == other.divisionId;

  @override
  int get hashCode => divisionId.hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectItem &&
          runtimeType == other.runtimeType &&
          subjectId == other.subjectId;

  @override
  int get hashCode => subjectId.hashCode;
}

class SubjectTypeItem {
  final int subTypeId;
  final String subTypeName;

  SubjectTypeItem({
    required this.subTypeId,
    required this.subTypeName,
  });

  factory SubjectTypeItem.fromJson(Map<String, dynamic> json) {
    return SubjectTypeItem(
      subTypeId: int.tryParse((json['SubTypeId'] ?? '0').toString()) ?? 0,
      subTypeName: (json['SubTypeName'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectTypeItem &&
          runtimeType == other.runtimeType &&
          subTypeId == other.subTypeId;

  @override
  int get hashCode => subTypeId.hashCode;
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

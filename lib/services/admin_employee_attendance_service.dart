import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

class AdminEmployeeAttendanceService {
  static final DateFormat _dateParamFormat = DateFormat('dd-MM-yyyy');

  static Future<List<AttendanceDay>> getAttendanceList({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.employeeAttendanceList}');
      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['FD'] = _dateParamFormat.format(fromDate);
      request.fields['TD'] = _dateParamFormat.format(toDate);

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> days = jsonData['data'];
          return days.map((d) => AttendanceDay.fromJson(d as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> addAttendance({
    required DateTime date,
    required String inTime, // e.g. "09:05"
    required String outTime, // e.g. "17:10"
    required List<AttendancePostEmployee> employees,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addEmpAttendance}');
      final body = {
        'AttDate': DateFormat('yyyy-MM-dd').format(date),
        'InTime': inTime,
        'OutTime': outTime,
        'Employees': employees.map((e) => e.toJson()).toList(),
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateAttendance({
    required int attId,
    required int empId,
    required DateTime attDate,
    required bool isPresent,
    required String inTime,
    required String outTime,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateEmpAttendance}');
      final body = {
        'AttId': attId,
        'EmpId': empId,
        'AttDate': DateFormat('yyyy-MM-dd').format(attDate),
        'IsPresent': isPresent,
        'InTime': inTime,
        'OutTime': outTime,
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<EmployeeAttendanceReport?> getEmployeeAttendanceReport({
    required int empId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.empAttendanceReport}');
      final body = {
        'EmpId': empId,
        'StartDate': DateFormat('yyyy-MM-dd').format(startDate),
        'EndDate': DateFormat('yyyy-MM-dd').format(endDate),
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return EmployeeAttendanceReport.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class AttendanceDay {
  final DateTime date;
  final List<AttendanceEmployee> employees;

  AttendanceDay({required this.date, required this.employees});

  factory AttendanceDay.fromJson(Map<String, dynamic> json) {
    final String dateStr = (json['Date'] ?? '').toString();
    final DateTime date = DateTime.tryParse(dateStr) ?? DateTime.now();
    final List<dynamic> list = json['Employees'] as List<dynamic>? ?? [];
    return AttendanceDay(
      date: date,
      employees: list
          .map((e) => AttendanceEmployee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get formattedDate => DateFormat('dd MMM, yyyy').format(date);
}

class AttendanceEmployee {
  final int attId;
  final int? empId; // might not be present in list response
  final DateTime attDate;
  final String? inTime; // "09:05"
  final String? outTime; // "17:10"
  final String employeeName;
  final bool isPresent;

  AttendanceEmployee({
    required this.attId,
    required this.empId,
    required this.attDate,
    required this.inTime,
    required this.outTime,
    required this.employeeName,
    required this.isPresent,
  });

  factory AttendanceEmployee.fromJson(Map<String, dynamic> json) {
    final String isPresentStr = (json['IsPresent'] ?? '').toString();
    return AttendanceEmployee(
      attId: int.tryParse((json['AttId'] ?? '0').toString()) ?? 0,
      empId: json['EmpId'] == null ? null : int.tryParse((json['EmpId']).toString()),
      attDate: DateTime.tryParse((json['AttDate'] ?? '').toString()) ?? DateTime.now(),
      inTime: json['InTime']?.toString(),
      outTime: json['OutTime']?.toString(),
      employeeName: (json['EmployeeName'] ?? '').toString(),
      isPresent: isPresentStr.toLowerCase() == 'present' || isPresentStr == 'true',
    );
  }
}

class AttendancePostEmployee {
  final int empId;
  final bool isPresent;

  AttendancePostEmployee({required this.empId, required this.isPresent});

  Map<String, dynamic> toJson() => {
        'EmpId': empId,
        'IsPresent': isPresent,
      };
}

class EmployeeAttendanceReport {
  final bool success;
  final int employeeId;
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? evaluatedTill;
  final int totalWorkingDays;
  final int totalPresentDays;
  final int totalAbsentDays;

  EmployeeAttendanceReport({
    required this.success,
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.evaluatedTill,
    required this.totalWorkingDays,
    required this.totalPresentDays,
    required this.totalAbsentDays,
  });

  factory EmployeeAttendanceReport.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendanceReport(
      success: json['success'] == true,
      employeeId: int.tryParse((json['EmployeeId'] ?? '0').toString()) ?? 0,
      employeeName: (json['EmployeeName'] ?? '').toString(),
      startDate: DateTime.tryParse((json['StartDate'] ?? '').toString()) ?? DateTime.now(),
      endDate: DateTime.tryParse((json['EndDate'] ?? '').toString()) ?? DateTime.now(),
      evaluatedTill: json['EvaluatedTill'] != null
          ? DateTime.tryParse(json['EvaluatedTill'].toString())
          : null,
      totalWorkingDays: int.tryParse((json['TotalWorkingDays'] ?? '0').toString()) ?? 0,
      totalPresentDays: int.tryParse((json['TotalPresentDays'] ?? '0').toString()) ?? 0,
      totalAbsentDays: int.tryParse((json['TotalAbsentDays'] ?? '0').toString()) ?? 0,
    );
  }
}



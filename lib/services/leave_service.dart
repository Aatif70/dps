import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

class LeaveService {
  static Future<List<StudentLeaveRecord>> getStudentLeaves() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      debugPrint('=== STUDENT LEAVE SERVICE DEBUG START ===');
      debugPrint('All SharedPreferences keys: ${prefs.getKeys()}');

      // Safe retrieval that handles both string and int types
      String uid = '';
      dynamic idValue;

      // Check if Uid exists and get its value regardless of type
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        debugPrint('Uid raw value: $uidValue (type: ${uidValue.runtimeType})');
        uid = uidValue.toString();
      }

      // Check if Id exists and get its value regardless of type
      if (prefs.containsKey('Id')) {
        idValue = prefs.get('Id');
        debugPrint('Id raw value: $idValue (type: ${idValue.runtimeType})');
      }

      debugPrint('Student Leave Service - Processed Uid: $uid');
      debugPrint('Student Leave Service - Id value for request: $idValue');

      if (uid.isEmpty || idValue == null) {
        debugPrint('ERROR: Uid or Id not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/StudentLeave');
      debugPrint('Student Leave Service - Request URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['StudentId'] = idValue.toString();

      debugPrint('Student Leave Service - Multipart fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Student Leave Service - Response status: ${response.statusCode}');
      debugPrint('Student Leave Service - Response headers: ${response.headers}');
      debugPrint('Student Leave Service - Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        debugPrint('Student Leave Service - Parsed JSON response: $jsonResponse');

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          debugPrint('Student Leave Service - Data array length: ${data.length}');

          List<StudentLeaveRecord> leaveRecords = [];

          for (int i = 0; i < data.length; i++) {
            try {
              debugPrint('--- Processing student leave record $i ---');
              final item = data[i];
              debugPrint('Raw item data: $item');

              final leaveRecord = StudentLeaveRecord.fromJson(item);
              debugPrint('Successfully parsed student leave record $i: ${leaveRecord.sleaveId}');
              leaveRecords.add(leaveRecord);
            } catch (e, stackTrace) {
              debugPrint('ERROR parsing student leave record $i: $e');
              debugPrint('Stack trace: $stackTrace');
              debugPrint('Failed item data: ${data[i]}');
            }
          }

          debugPrint('Student Leave Service - Successfully parsed ${leaveRecords.length} out of ${data.length} records');
          debugPrint('=== STUDENT LEAVE SERVICE DEBUG END ===');
          return leaveRecords;
        } else {
          debugPrint('API returned success: false or no data');
          return [];
        }
      } else {
        debugPrint('Failed to load student leaves. Status code: ${response.statusCode}');
        debugPrint('Error response body: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching student leaves: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<bool> addLeave({
    required String fromDate,
    required String toDate,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      debugPrint('=== ADD LEAVE SERVICE DEBUG START ===');

      // Safe retrieval that handles both string and int types
      String uid = '';
      dynamic idValue;

      // Check if Uid exists and get its value regardless of type
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        debugPrint('Uid raw value: $uidValue (type: ${uidValue.runtimeType})');
        uid = uidValue.toString();
      }

      // Check if Id exists and get its value regardless of type
      if (prefs.containsKey('Id')) {
        idValue = prefs.get('Id');
        debugPrint('Id raw value: $idValue (type: ${idValue.runtimeType})');
      }

      debugPrint('Add Leave Service - Processed Uid: $uid');
      debugPrint('Add Leave Service - Id value for request: $idValue');

      if (uid.isEmpty || idValue == null) {
        debugPrint('ERROR: Uid or Id not found in SharedPreferences');
        return false;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/AddLeaveMobile');
      debugPrint('Add Leave Service - Request URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.fields['CreatedBy'] = uid;
      request.fields['StudentId'] = idValue.toString();
      request.fields['FromDate'] = fromDate;
      request.fields['ToDate'] = toDate;
      request.fields['Description'] = description;

      debugPrint('Add Leave Service - Multipart fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Add Leave Service - Response status: ${response.statusCode}');
      debugPrint('Add Leave Service - Response headers: ${response.headers}');
      debugPrint('Add Leave Service - Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        debugPrint('Add Leave Service - Parsed JSON response: $jsonResponse');

        final success = jsonResponse['success'] == true;
        debugPrint('Add Leave Service - Success: $success');
        debugPrint('=== ADD LEAVE SERVICE DEBUG END ===');
        return success;
      } else {
        debugPrint('Failed to add leave. Status code: ${response.statusCode}');
        debugPrint('Error response body: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error adding leave: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }
}

// Data model for student leave API response
class StudentLeaveRecord {
  final int sleaveId;
  final String student;
  final String className;
  final String division;
  final String employee;
  final String? doc;
  final String status;
  final String description;
  final DateTime toDate;
  final DateTime fromDate;

  const StudentLeaveRecord({
    required this.sleaveId,
    required this.student,
    required this.className,
    required this.division,
    required this.employee,
    this.doc,
    required this.status,
    required this.description,
    required this.toDate,
    required this.fromDate,
  });

  factory StudentLeaveRecord.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint('--- StudentLeaveRecord.fromJson START ---');
      debugPrint('Input JSON: $json');

      final record = StudentLeaveRecord(
        sleaveId: _safeIntExtraction(json, 'SleaveId'),
        student: _safeStringExtraction(json, 'Student'),
        className: _safeStringExtraction(json, 'ClassName'),
        division: _safeStringExtraction(json, 'Division'),
        employee: _safeStringExtraction(json, 'Employee'),
        doc: json['Doc']?.toString(),
        status: _safeStringExtraction(json, 'Status'),
        description: _safeStringExtraction(json, 'Description'),
        toDate: _safeDateTimeExtraction(json, 'ToDate'),
        fromDate: _safeDateTimeExtraction(json, 'FromDate'),
      );

      debugPrint('--- StudentLeaveRecord.fromJson SUCCESS ---');
      return record;
    } catch (e, stackTrace) {
      debugPrint('--- StudentLeaveRecord.fromJson ERROR ---');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Convert to legacy LeaveRequest format for compatibility
  LeaveRequest toLegacyLeaveRequest() {
    return LeaveRequest(
      id: 'SL-${sleaveId.toString().padLeft(6, '0')}',
      reason: _generateReasonFromDescription(description),
      description: description,
      fromDate: fromDate,
      toDate: toDate,
      status: _mapStatus(status),
      appliedOn: fromDate.subtract(const Duration(days: 1)), // Estimate applied date
      leaveType: _inferLeaveType(description),
      actionBy: employee.isNotEmpty ? employee : null,
      actionOn: status.toLowerCase() != 'pending' ? DateTime.now() : null,
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

  static DateTime _safeDateTimeExtraction(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static String _generateReasonFromDescription(String description) {
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('sick') || lowerDesc.contains('medical') || lowerDesc.contains('fever')) {
      return 'Medical Leave';
    } else if (lowerDesc.contains('family') || lowerDesc.contains('wedding') || lowerDesc.contains('personal')) {
      return 'Family Function';
    } else if (lowerDesc.contains('emergency')) {
      return 'Emergency Leave';
    } else {
      return 'Personal Leave';
    }
  }

  static LeaveStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return LeaveStatus.pending;
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }

  static LeaveType _inferLeaveType(String description) {
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('sick') || lowerDesc.contains('medical') || lowerDesc.contains('fever')) {
      return LeaveType.sick;
    } else if (lowerDesc.contains('emergency')) {
      return LeaveType.emergency;
    } else {
      return LeaveType.personal;
    }
  }

  @override
  String toString() {
    return 'StudentLeaveRecord(sleaveId: $sleaveId, student: $student, status: $status, fromDate: $fromDate, toDate: $toDate)';
  }
}

// Keep the existing enums and LeaveRequest class for backward compatibility
enum LeaveStatus { pending, approved, rejected }
enum LeaveType { sick, personal, emergency }

class LeaveRequest {
  final String id;
  final String reason;
  final String description;
  final DateTime fromDate;
  final DateTime toDate;
  final LeaveStatus status;
  final DateTime appliedOn;
  final String? actionBy;
  final DateTime? actionOn;
  final String? remarks;
  final LeaveType leaveType;
  final List<String> attachments;

  const LeaveRequest({
    required this.id,
    required this.reason,
    required this.description,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.appliedOn,
    this.actionBy,
    this.actionOn,
    this.remarks,
    this.leaveType = LeaveType.personal,
    this.attachments = const [],
  });
}

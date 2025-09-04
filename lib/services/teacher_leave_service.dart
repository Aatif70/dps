import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:AES/constants/api_constants.dart';

class TeacherLeaveService {
  // Fetch leave list for teacher
  static Future<List<LeaveRequest>> getLeaveList({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      debugPrint('=== LEAVE LIST API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final empId = prefs.getInt('Id') ?? 0;

      final fd = DateFormat('yyyy-MM-dd').format(fromDate ?? DateTime.now().subtract(const Duration(days: 30)));
      final td = DateFormat('yyyy-MM-dd').format(toDate ?? DateTime.now());

      debugPrint('UID: $uid, EmpId: $empId, FromDate: $fd, ToDate: $td');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.leaveList}');
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'Uid': uid,
        'EmpId': empId.toString(),
        'FD': fd,
        'TD': td,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== LEAVE LIST API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => LeaveRequest.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      debugPrint('=== LEAVE LIST ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  // Approve or reject leave
  static Future<bool> approveOrRejectLeave({
    required int leaveId,
    required String status, // 'Approved' or 'Rejected'
  }) async {
    try {
      debugPrint('=== APPROVE/REJECT LEAVE API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final empId = prefs.getInt('Id') ?? 0;

      debugPrint('LeaveId: $leaveId, Status: $status, EmpId: $empId');

      // Build URL with query parameters
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.approveOrRejectLeave}?leaveId=$leaveId&Status=${Uri.encodeComponent(status)}&empId=${empId}'
      );

      final response = await http.post(url);

      debugPrint('=== APPROVE/REJECT LEAVE API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('=== APPROVE/REJECT LEAVE ERROR ===');
      debugPrint('Error: $e');
      return false;
    }
  }
}

// Data Models
enum LeaveStatus { pending, approved, rejected }

class LeaveRequest {
  final int sleaveId;
  final String student;
  final String className;
  final String division;
  final String? employee;
  final String? doc;
  final LeaveStatus status;
  final String description;
  final DateTime toDate;
  final DateTime fromDate;

  LeaveRequest({
    required this.sleaveId,
    required this.student,
    required this.className,
    required this.division,
    this.employee,
    this.doc,
    required this.status,
    required this.description,
    required this.toDate,
    required this.fromDate,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      sleaveId: json['SleaveId'] ?? 0,
      student: json['Student'] ?? '',
      className: json['ClassName'] ?? '',
      division: json['Division'] ?? '',
      employee: json['Employee'],
      doc: json['Doc'],
      status: _parseStatus(json['Status'] ?? ''),
      description: json['Description'] ?? '',
      toDate: DateTime.parse(json['ToDate'] ?? DateTime.now().toIso8601String()),
      fromDate: DateTime.parse(json['FromDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  static LeaveStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return LeaveStatus.approved;
      case 'rejected':
        return LeaveStatus.rejected;
      default:
        return LeaveStatus.pending;
    }
  }

  String get docUrl => doc != null && doc!.isNotEmpty
      ? '${ApiConstants.baseUrl}$doc'
      : '';
}

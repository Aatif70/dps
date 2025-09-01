import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:dps/constants/api_constants.dart';
import 'package:dps/models/employee_attendance_models.dart';

class EmployeeAttendanceService {
  // Get employee attendance for date range
  static Future<EmployeeAttendanceResponse?> getEmployeeAttendance({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('=== EMPLOYEE ATTENDANCE API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final empId = prefs.getInt('Id') ?? 0;

      final startDateString = DateFormat('yyyy-MM-dd').format(startDate);
      final endDateString = DateFormat('yyyy-MM-dd').format(endDate);

      debugPrint('EmpId: $empId');
      debugPrint('StartDate: $startDateString');
      debugPrint('EndDate: $endDateString');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.employeeAttendance}');
      
      final requestBody = {
        'EmpId': empId,
        'StartDate': startDateString,
        'EndDate': endDateString,
      };

      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      debugPrint('=== EMPLOYEE ATTENDANCE API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return EmployeeAttendanceResponse.fromJson(jsonData);
      } else {
        debugPrint('API call failed with status code: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('=== EMPLOYEE ATTENDANCE ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}

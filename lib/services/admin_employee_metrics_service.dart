import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:dps/constants/api_constants.dart';

class AdminEmployeeMetricsService {
  static Future<EmployeeMetrics?> fetchMetrics() async {
    try {
      final Uri url = Uri.parse(ApiConstants.baseUrl + ApiConstants.employeeCount);
      debugPrint('[AdminEmployeeMetrics] GET ' + url.toString());
      final http.Response response = await http.get(url);
      debugPrint('[AdminEmployeeMetrics] status=' + response.statusCode.toString());
      if (response.body.isNotEmpty) {
        final String preview = response.body.length > 400 ? response.body.substring(0, 400) + '...' : response.body;
        debugPrint('[AdminEmployeeMetrics] body=' + preview);
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body) as Map<String, dynamic>;
        if (jsonData['success'] == true && jsonData['data'] is Map<String, dynamic>) {
          return EmployeeMetrics.fromJson(jsonData['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('[AdminEmployeeMetrics] error=' + e.toString());
    }
    return null;
  }
}

class EmployeeMetrics {
  final int empCount;
  final int presentCount;
  final int absentCount;

  EmployeeMetrics({required this.empCount, required this.presentCount, required this.absentCount});

  factory EmployeeMetrics.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => int.tryParse((v ?? '0').toString()) ?? 0;
    return EmployeeMetrics(
      empCount: toInt(json['EmpCount']),
      presentCount: toInt(json['presentCount']),
      absentCount: toInt(json['absentCount']),
    );
  }
}



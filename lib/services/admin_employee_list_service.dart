import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class AdminEmployeeListService {
  static Future<List<EmployeeItem>> fetchEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.employeesList}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] is List) {
          final List<dynamic> data = jsonData['data'];
          return data
              .map((e) => EmployeeItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
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



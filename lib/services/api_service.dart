import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

class ApiService {
  static Future<bool> login({required String email, required String password}) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.login);
    debugPrint('Attempting login at: ' + url.toString());
    debugPrint('Sending email: $email');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Email': email,
          'Password': password,
        }),
      );
      debugPrint('Response status: \'${response.statusCode}\'');
      debugPrint('Response body: ${response.body}');
      final Map<String, dynamic> res = jsonDecode(response.body);
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('Uid', data['Uid'] ?? '');
        await prefs.setString('Email', data['Email'] ?? '');
        await prefs.setString('FullName', data['FullName'] ?? '');
        await prefs.setString('Role', data['Role'] ?? '');
        await prefs.setInt('Id', data['Id'] ?? 0);
        // Persist ClassId if provided by login response (needed for exam APIs)
        try {
          final dynamic classIdValue = data['ClassId'] ?? data['ClassMasterId'];
          if (classIdValue != null) {
            int? classIdInt;
            if (classIdValue is int) {
              classIdInt = classIdValue;
            } else if (classIdValue is String) {
              classIdInt = int.tryParse(classIdValue);
            }
            if (classIdInt != null) {
              await prefs.setInt('ClassId', classIdInt);
              debugPrint('Stored ClassId: $classIdInt');
            }
          }
        } catch (_) {}
        debugPrint('Login successful, Uid stored: ${data['Uid']}');
        return true;
      } else {
        debugPrint('Login failed: ${res['success']}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }
} 
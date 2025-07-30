import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class ApiService {
  static Future<bool> login({required String email, required String password}) async {
    final url = Uri.parse(ApiConstants.baseUrl + ApiConstants.login);
    print('Attempting login at: ' + url.toString());
    print('Sending email: $email');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Email': email,
          'Password': password,
        }),
      );
      print('Response status: \'${response.statusCode}\'');
      print('Response body: ${response.body}');
      final Map<String, dynamic> res = jsonDecode(response.body);
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('Uid', data['Uid'] ?? '');
        await prefs.setString('Email', data['Email'] ?? '');
        await prefs.setString('FullName', data['FullName'] ?? '');
        await prefs.setString('Role', data['Role'] ?? '');
        await prefs.setInt('Id', data['Id'] ?? 0);
        print('Login successful, Uid stored: ${data['Uid']}');
        return true;
      } else {
        print('Login failed: ${res['success']}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
} 
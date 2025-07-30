import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';
import 'package:flutter/material.dart';

class FeeService {
  static Future<List<PaidFeeRecord>> getPaidFees() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('=== FEE SERVICE DEBUG START ===');
      print('All SharedPreferences keys: ${prefs.getKeys()}');

      // Safe retrieval that handles both string and int types
      String uid = '';
      dynamic idValue;

      // Check if Uid exists and get its value regardless of type
      if (prefs.containsKey('Uid')) {
        final uidValue = prefs.get('Uid');
        print('Uid raw value: $uidValue (type: ${uidValue.runtimeType})');
        uid = uidValue.toString();
      }

      // Check if Id exists and get its value regardless of type
      if (prefs.containsKey('Id')) {
        idValue = prefs.get('Id');
        print('Id raw value: $idValue (type: ${idValue.runtimeType})');
      }

      print('Fee Service - Processed Uid: $uid');
      print('Fee Service - Id value for request: $idValue');

      if (uid.isEmpty || idValue == null) {
        print('ERROR: Uid or Id not found in SharedPreferences');
        print('Uid isEmpty: ${uid.isEmpty}, Id is null: ${idValue == null}');
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/PaidFees');
      print('Fee Service - Request URL: $url');

      // Try multiple request formats
      return await _tryMultipleRequestFormats(url, uid, idValue);

    } catch (e, stackTrace) {
      print('Error fetching paid fees: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<List<PaidFeeRecord>> _tryMultipleRequestFormats(
      Uri url,
      String uid,
      dynamic idValue
      ) async {

    // Format 3: Form data
    print('\n--- TRYING FORMAT 3: Form data ---');
    try {
      final formData = {
        'Uid': uid,
        'Id': idValue.toString(),
      };

      final result3 = await _makeRequest(url, formData, 'application/x-www-form-urlencoded', isJson: false);
      if (result3.isNotEmpty) return result3;
    } catch (e) {
      print('Format 3 failed: $e');
    }



    print('All request formats failed. Returning empty list.');
    return [];
  }

  static Future<List<PaidFeeRecord>> _makeRequest(
      Uri url,
      Map<String, dynamic> data,
      String contentType,
      {required bool isJson}
      ) async {
    print('Making request with content-type: $contentType');
    print('Request data: $data');

    final headers = {
      'Content-Type': contentType,
      'Accept': 'application/json',
    };

    String body;
    if (isJson) {
      body = jsonEncode(data);
    } else {
      // Form URL encoded
      body = data.entries
          .map((e) => '${Uri.encodeComponent(e.key.toString())}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
    }

    print('Request headers: $headers');
    print('Request body: $body');

    final response = await http.post(url, headers: headers, body: body);

    return _processResponse(response);
  }

  static Future<List<PaidFeeRecord>> _makeRequestWithAuth(
      Uri url,
      Map<String, dynamic> data
      ) async {
    final prefs = await SharedPreferences.getInstance();

    // Try to get any potential authentication tokens
    final token = prefs.getString('token') ?? prefs.getString('auth_token') ?? prefs.getString('access_token') ?? '';

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('Added Authorization header');
    }

    print('Making authenticated request');
    print('Request headers: $headers');
    print('Request data: $data');

    final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data)
    );

    return _processResponse(response);
  }

  static Future<List<PaidFeeRecord>> _processResponse(http.Response response) async {
    print('Response status: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Raw response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Parsed JSON response: $jsonResponse');

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          print('Data array length: ${data.length}');

          List<PaidFeeRecord> feeRecords = [];

          for (int i = 0; i < data.length; i++) {
            try {
              print('--- Processing record $i ---');
              final item = data[i];
              print('Raw item data: $item');

              final feeRecord = PaidFeeRecord.fromJson(item);
              print('Successfully parsed record $i: ${feeRecord.receiptNo}');
              feeRecords.add(feeRecord);
            } catch (e, stackTrace) {
              print('ERROR parsing record $i: $e');
              print('Stack trace: $stackTrace');
              print('Failed item data: ${data[i]}');
            }
          }

          print('Successfully parsed ${feeRecords.length} out of ${data.length} records');
          return feeRecords;
        } else {
          print('API returned success: false or no data');
          print('Success value: ${jsonResponse['success']}');
          print('Data value: ${jsonResponse['data']}');
          return [];
        }
      } catch (e) {
        print('Error parsing JSON response: $e');
        return [];
      }
    } else if (response.statusCode == 500) {
      print('Server error (500). Response body: ${response.body}');
      // Try to parse error message
      try {
        final errorResponse = jsonDecode(response.body);
        print('Parsed error: $errorResponse');
      } catch (e) {
        print('Could not parse error response');
      }
      return [];
    } else {
      print('Failed to load paid fees. Status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      return [];
    }
  }
}

// Keep the rest of the classes unchanged (PaidFeeRecord, FeeCategory, etc.)
class PaidFeeRecord {
  final String receiptNo;
  final String particular;
  final String className;
  final String paymentMode;
  final double amount;
  final DateTime paymentDate;
  final int headId;

  const PaidFeeRecord({
    required this.receiptNo,
    required this.particular,
    required this.className,
    required this.paymentMode,
    required this.amount,
    required this.paymentDate,
    required this.headId,
  });

  factory PaidFeeRecord.fromJson(Map<String, dynamic> json) {
    try {
      print('--- PaidFeeRecord.fromJson START ---');
      print('Input JSON: $json');

      final receiptNo = _safeStringExtraction(json, 'ReceiptNo');
      final particular = _safeStringExtraction(json, 'Particular');
      final className = _safeStringExtraction(json, 'ClassName');
      final paymentMode = _safeStringExtraction(json, 'PaymentMode');
      final amount = _safeDoubleExtraction(json, 'Amount');
      final paymentDate = _safeDateTimeExtraction(json, 'PaymentDate');
      final headId = _safeIntExtraction(json, 'HeadId');

      final record = PaidFeeRecord(
        receiptNo: receiptNo,
        particular: particular,
        className: className,
        paymentMode: paymentMode,
        amount: amount,
        paymentDate: paymentDate,
        headId: headId,
      );

      print('--- PaidFeeRecord.fromJson SUCCESS ---');
      return record;
    } catch (e, stackTrace) {
      print('--- PaidFeeRecord.fromJson ERROR ---');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static String _safeStringExtraction(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  static double _safeDoubleExtraction(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
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

  @override
  String toString() {
    return 'PaidFeeRecord(receiptNo: $receiptNo, particular: $particular, className: $className, paymentMode: $paymentMode, amount: $amount, paymentDate: $paymentDate, headId: $headId)';
  }
}

class FeeCategory {
  static String getCategoryFromParticular(String particular) {
    final lowerParticular = particular.toLowerCase().trim();

    if (lowerParticular.contains('tuition') || lowerParticular.contains('academic')) {
      return 'Tuition';
    } else if (lowerParticular.contains('transport')) {
      return 'Transport';
    } else if (lowerParticular.contains('library')) {
      return 'Library';
    } else if (lowerParticular.contains('computer') || lowerParticular.contains('lab')) {
      return 'Computer';
    } else if (lowerParticular.contains('sports') || lowerParticular.contains('game')) {
      return 'Sports';
    } else if (lowerParticular.contains('exam') || lowerParticular.contains('test')) {
      return 'Examination';
    } else {
      return 'Other';
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tuition': return const Color(0xFF4A90E2);
      case 'transport': return const Color(0xFFFF9500);
      case 'library': return const Color(0xFF58CC02);
      case 'computer': return const Color(0xFFE74C3C);
      case 'sports': return const Color(0xFF8E44AD);
      case 'examination': return const Color(0xFF17A2B8);
      default: return const Color(0xFF6C757D);
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tuition': return Icons.school_rounded;
      case 'transport': return Icons.directions_bus_rounded;
      case 'library': return Icons.menu_book_rounded;
      case 'computer': return Icons.computer_rounded;
      case 'sports': return Icons.sports_soccer_rounded;
      case 'examination': return Icons.quiz_rounded;
      default: return Icons.receipt_rounded;
    }
  }
}

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

      final url = Uri.parse(ApiConstants.baseUrl + 'remainingfees');
      print('Fee Service - Request URL: $url');

      // Try multiple request formats
      return await _tryMultipleRequestFormats(url, uid, idValue);

    } catch (e, stackTrace) {
      print('Error fetching paid fees: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<List<RemainingFeeRecord>> getRemainingFees() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('=== REMAINING FEES SERVICE DEBUG START ===');
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

      print('Remaining Fees Service - Processed Uid: $uid');
      print('Remaining Fees Service - Id value for request: $idValue');

      if (uid.isEmpty || idValue == null) {
        print('ERROR: Uid or Id not found in SharedPreferences');
        return [];
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/RemainingFees');
      print('Remaining Fees Service - Request URL: $url');

      // Create multipart request
      var request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['Id'] = idValue.toString();

      print('Remaining Fees Service - Multipart fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Remaining Fees Service - Response status: ${response.statusCode}');
      print('Remaining Fees Service - Response headers: ${response.headers}');
      print('Remaining Fees Service - Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Remaining Fees Service - Parsed JSON response: $jsonResponse');

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          print('Remaining Fees Service - Data array length: ${data.length}');

          List<RemainingFeeRecord> feeRecords = [];

          for (int i = 0; i < data.length; i++) {
            try {
              print('--- Processing remaining fee record $i ---');
              final item = data[i];
              print('Raw item data: $item');

              final feeRecord = RemainingFeeRecord.fromJson(item);
              print('Successfully parsed remaining fee record $i: ${feeRecord.particular}');
              feeRecords.add(feeRecord);
            } catch (e, stackTrace) {
              print('ERROR parsing remaining fee record $i: $e');
              print('Stack trace: $stackTrace');
              print('Failed item data: ${data[i]}');
            }
          }

          print('Remaining Fees Service - Successfully parsed ${feeRecords.length} out of ${data.length} records');
          print('=== REMAINING FEES SERVICE DEBUG END ===');
          return feeRecords;
        } else {
          print('API returned success: false or no data');
          return [];
        }
      } else {
        print('Failed to load remaining fees. Status code: ${response.statusCode}');
        print('Error response body: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('Error fetching remaining fees: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<List<PaidFeeRecord>> _tryMultipleRequestFormats(
      Uri url,
      String uid,
      dynamic idValue
      ) async {
    // Format 1: JSON with Id as integer
    print('\n--- TRYING FORMAT 1: JSON with Id as integer ---');
    try {
      final requestBody1 = {
        'Uid': uid,
        'Id': idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0,
      };

      final result1 = await _makeRequest(url, requestBody1, 'application/json', isJson: true);
      if (result1.isNotEmpty) return result1;
    } catch (e) {
      print('Format 1 failed: $e');
    }

    // Format 2: JSON with Id as string
    print('\n--- TRYING FORMAT 2: JSON with Id as string ---');
    try {
      final requestBody2 = {
        'Uid': uid,
        'Id': idValue.toString(),
      };

      final result2 = await _makeRequest(url, requestBody2, 'application/json', isJson: true);
      if (result2.isNotEmpty) return result2;
    } catch (e) {
      print('Format 2 failed: $e');
    }

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
    } else {
      print('Failed to load paid fees. Status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      return [];
    }
  }
}

// Data model for the API response
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
    return value.toString().trim();
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

// Data model for remaining fees API response
class RemainingFeeRecord {
  final int feeId;
  final int classId;
  final int studentId;
  final double amount;
  final String? payMode;
  final double fixedFee;
  final double balanceFee;
  final String particular;
  final String feeType;
  final int feesTypeId;
  final bool isLateFee;
  final double? lateFeeAmount;
  final String? lastDate;
  final bool isPerDay;
  final bool isLate;
  final double? lateAmount;
  final int feeHead;
  final String? paymentMode;
  final String? details;
  final String? bankName;
  final String? chequeNo;
  final String className;

  const RemainingFeeRecord({
    required this.feeId,
    required this.classId,
    required this.studentId,
    required this.amount,
    this.payMode,
    required this.fixedFee,
    required this.balanceFee,
    required this.particular,
    required this.feeType,
    required this.feesTypeId,
    required this.isLateFee,
    this.lateFeeAmount,
    this.lastDate,
    required this.isPerDay,
    required this.isLate,
    this.lateAmount,
    required this.feeHead,
    this.paymentMode,
    this.details,
    this.bankName,
    this.chequeNo,
    required this.className,
  });

  factory RemainingFeeRecord.fromJson(Map<String, dynamic> json) {
    try {
      print('--- RemainingFeeRecord.fromJson START ---');
      print('Input JSON: $json');

      final record = RemainingFeeRecord(
        feeId: _safeIntExtraction(json, 'FeeId'),
        classId: _safeIntExtraction(json, 'ClassId'),
        studentId: _safeIntExtraction(json, 'StudentId'),
        amount: _safeDoubleExtraction(json, 'Amount'),
        payMode: json['PayMode']?.toString(),
        fixedFee: _safeDoubleExtraction(json, 'FixedFee'),
        balanceFee: _safeDoubleExtraction(json, 'BalanceFee'),
        particular: _safeStringExtraction(json, 'Particular'),
        feeType: _safeStringExtraction(json, 'FeeType'),
        feesTypeId: _safeIntExtraction(json, 'FeesTypeId'),
        isLateFee: json['IsLateFee'] == true,
        lateFeeAmount: json['LateFeeAmount'] != null ? _safeDoubleExtraction(json, 'LateFeeAmount') : null,
        lastDate: json['LastDate']?.toString(),
        isPerDay: json['IsPerDay'] == true,
        isLate: json['IsLate'] == true,
        lateAmount: json['LateAmount'] != null ? _safeDoubleExtraction(json, 'LateAmount') : null,
        feeHead: _safeIntExtraction(json, 'FeeHead'),
        paymentMode: json['PaymentMode']?.toString(),
        details: json['Details']?.toString(),
        bankName: json['BankName']?.toString(),
        chequeNo: json['ChequeNo']?.toString(),
        className: _safeStringExtraction(json, 'ClassName'),
      );

      print('--- RemainingFeeRecord.fromJson SUCCESS ---');
      return record;
    } catch (e, stackTrace) {
      print('--- RemainingFeeRecord.fromJson ERROR ---');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Helper methods (same as PaidFeeRecord)
  static String _safeStringExtraction(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString().trim();
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
    return 'RemainingFeeRecord(particular: $particular, balanceFee: $balanceFee, fixedFee: $fixedFee, className: $className, isLate: $isLate)';
  }
}

// Helper class for categorizing fees
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

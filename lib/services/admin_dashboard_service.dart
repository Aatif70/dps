import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class AdminDashboardService {
  // Get dashboard counter stats
  static Future<DashboardCounterData?> getDashboardCounter() async {
    try {
      print('=== DASHBOARD COUNTER API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      print('UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.dashboardcounter}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      print('=== DASHBOARD COUNTER REQUEST FIELDS ===');
      print('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== DASHBOARD COUNTER API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return DashboardCounterData.fromJson(jsonData['data']);
        }
      }
      return null;
    } catch (e, stackTrace) {
      print('=== DASHBOARD COUNTER ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Get last 10 fees receipts
  static Future<List<FeesReceiptData>> getLast10FeesReceipt() async {
    try {
      print('=== LAST 10 FEES RECEIPT API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      print('UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.last10feesreceipt}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      print('=== LAST 10 FEES RECEIPT REQUEST FIELDS ===');
      print('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== LAST 10 FEES RECEIPT API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => FeesReceiptData.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('=== LAST 10 FEES RECEIPT ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Get last 10 concession fees receipts
  static Future<List<FeesReceiptData>> getLast10ConcessionFeesReceipt() async {
    try {
      print('=== LAST 10 CONCESSION FEES RECEIPT API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      print('UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.last10concessionfeesreceipt}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      print('=== LAST 10 CONCESSION FEES RECEIPT REQUEST FIELDS ===');
      print('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== LAST 10 CONCESSION FEES RECEIPT API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => FeesReceiptData.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('=== LAST 10 CONCESSION FEES RECEIPT ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Get last 10 payment vouchers
  static Future<List<PaymentVoucherData>> getLast10PaymentVouchers() async {
    try {
      print('=== LAST 10 PAYMENT VOUCHERS API CALL ===');
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      print('UID: $uid');

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.last10paymentvouchers}');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;

      print('=== LAST 10 PAYMENT VOUCHERS REQUEST FIELDS ===');
      print('Request Fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== LAST 10 PAYMENT VOUCHERS API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((item) => PaymentVoucherData.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      print('=== LAST 10 PAYMENT VOUCHERS ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}

// Data Models
class DashboardCounterData {
  final String todayFees;
  final String lastSevenDays;
  final int totalStudent;
  final int activeStudent;

  DashboardCounterData({
    required this.todayFees,
    required this.lastSevenDays,
    required this.totalStudent,
    required this.activeStudent,
  });

  factory DashboardCounterData.fromJson(Map<String, dynamic> json) {
    return DashboardCounterData(
      todayFees: json['TodayFees'] ?? '0.00',
      lastSevenDays: json['LastSevendays'] ?? '0.00',
      totalStudent: json['TotalStudent'] ?? 0,
      activeStudent: json['ActiveStudent'] ?? 0,
    );
  }
}

class FeesReceiptData {
  final String studentName;
  final String receiptNo;
  final double amount;
  final String date;

  FeesReceiptData({
    required this.studentName,
    required this.receiptNo,
    required this.amount,
    required this.date,
  });

  factory FeesReceiptData.fromJson(Map<String, dynamic> json) {
    return FeesReceiptData(
      studentName: json['StudentName'] ?? '',
      receiptNo: json['ReceiptNo'] ?? '',
      amount: (json['Amount'] ?? 0.0).toDouble(),
      date: json['Date'] ?? '',
    );
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  String get formattedAmount {
    return '₹${amount.toStringAsFixed(2)}';
  }
}

class PaymentVoucherData {
  final String paidTo;
  final String mHead;
  final double amount;
  final String paymentDate;

  PaymentVoucherData({
    required this.paidTo,
    required this.mHead,
    required this.amount,
    required this.paymentDate,
  });

  factory PaymentVoucherData.fromJson(Map<String, dynamic> json) {
    return PaymentVoucherData(
      paidTo: json['PaidTo'] ?? '',
      mHead: json['MHead'] ?? '',
      amount: (json['Amount'] ?? 0.0).toDouble(),
      paymentDate: json['PaymentDate'] ?? '',
    );
  }

  String get formattedDate {
    try {
      final dateTime = DateTime.parse(paymentDate);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return paymentDate;
    }
  }

  String get formattedAmount {
    return '₹${amount.toStringAsFixed(2)}';
  }
}

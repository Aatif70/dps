import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dps/constants/api_constants.dart';

class ClassWiseFeeSummaryItem {
  final int id;
  final String className;
  final num totalPaidFees;
  final num totalPendingFees;

  ClassWiseFeeSummaryItem({
    required this.id,
    required this.className,
    required this.totalPaidFees,
    required this.totalPendingFees,
  });

  factory ClassWiseFeeSummaryItem.fromJson(Map<String, dynamic> json) {
    return ClassWiseFeeSummaryItem(
      id: json['Id'] is int ? json['Id'] as int : int.tryParse(json['Id'].toString()) ?? 0,
      className: json['ClassName']?.toString() ?? '-',
      totalPaidFees: json['TotalPaidFees'] ?? 0,
      totalPendingFees: json['TotalPendingFees'] ?? 0,
    );
  }
}

class AdminFeesSummaryService {
  static Future<List<ClassWiseFeeSummaryItem>> fetchClassWiseSummary({required String academicYear}) async {
    final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.classWiseFeeSummary)
        .replace(queryParameters: {'academicYear': academicYear});
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return [];
    }
    final Map<String, dynamic> res = jsonDecode(response.body);
    if (res['success'] != true || res['data'] == null) return [];
    final List<dynamic> list = res['data'] as List<dynamic>;
    return list.map((e) => ClassWiseFeeSummaryItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}



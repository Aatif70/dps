import 'dart:convert';

import 'package:dps/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AdminHomeworkService {
  static Future<List<AdminHomeworkItem>> fetchHomework({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      // API expects mm/dd/yyyy
      final String fd = DateFormat('MM/dd/yyyy').format(fromDate);
      final String td = DateFormat('MM/dd/yyyy').format(toDate);

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminHomeworkList}?FD=$fd&TD=$td');
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return [];
      }
      final Map<String, dynamic> decoded = json.decode(response.body) as Map<String, dynamic>;
      if (decoded['success'] == true && decoded['data'] is List) {
        final List<dynamic> data = decoded['data'] as List<dynamic>;
        return data.map((e) => AdminHomeworkItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

class AdminHomeworkItem {
  final int hId;
  final String className;
  final String batch;
  final String employee;
  final String subject;
  final String division;
  final String homework;
  final DateTime date;
  final String? doc;

  AdminHomeworkItem({
    required this.hId,
    required this.className,
    required this.batch,
    required this.employee,
    required this.subject,
    required this.division,
    required this.homework,
    required this.date,
    required this.doc,
  });

  factory AdminHomeworkItem.fromJson(Map<String, dynamic> json) {
    return AdminHomeworkItem(
      hId: int.tryParse((json['HId'] ?? '0').toString()) ?? 0,
      className: (json['ClassName'] ?? '').toString(),
      batch: (json['Batch'] ?? '').toString(),
      employee: (json['Employee'] ?? '').toString(),
      subject: (json['Subject'] ?? '').toString(),
      division: (json['Division'] ?? '').toString(),
      homework: (json['HomeWork'] ?? '').toString(),
      date: DateTime.tryParse((json['Date'] ?? '').toString()) ?? DateTime.now(),
      doc: json['Doc']?.toString(),
    );
  }
}



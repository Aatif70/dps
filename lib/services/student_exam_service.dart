import 'dart:convert';
import 'package:dps/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentExamItem {
  final int examId;
  final String title;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? resultDate;
  final List<StudentExamSubject> subjects;

  StudentExamItem({
    required this.examId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.resultDate,
    required this.subjects,
  });

  factory StudentExamItem.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? s) {
      if (s == null || s.isEmpty) return null;
      try { return DateTime.parse(s); } catch (_) { return null; }
    }
    
    final List<dynamic> subjectsData = (json['Subjects'] as List<dynamic>? ?? <dynamic>[]);
    
    return StudentExamItem(
      examId: int.tryParse((json['ExamId'] ?? '0').toString()) ?? 0,
      title: (json['Title'] ?? '').toString(),
      description: (json['Description'] ?? '').toString(),
      startDate: parse(json['StartDate']?.toString()),
      endDate: parse(json['EndDate']?.toString()),
      resultDate: parse(json['ResultDate']?.toString()),
      subjects: subjectsData.map((e) => StudentExamSubject.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class StudentExamSubject {
  final String subjectName;
  final DateTime? paperDate;
  final int minMarks;
  final int maxMarks;

  StudentExamSubject({
    required this.subjectName,
    required this.paperDate,
    required this.minMarks,
    required this.maxMarks,
  });

  factory StudentExamSubject.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? s) {
      if (s == null || s.isEmpty) return null;
      try { return DateTime.parse(s); } catch (_) { return null; }
    }
    
    return StudentExamSubject(
      subjectName: (json['SubjectName'] ?? '').toString(),
      paperDate: parse(json['PaperDate']?.toString()),
      minMarks: int.tryParse((json['MinMarks'] ?? '0').toString()) ?? 0,
      maxMarks: int.tryParse((json['MaxMarks'] ?? '0').toString()) ?? 0,
    );
  }
}

class StudentExamMarksItem {
  final int studentId;
  final int examSubId;
  final int theoryMarks;
  final int minMarks;
  final int maxMarks;
  final String status;
  final int practicalMarks;
  final int pMinMarks;
  final int pMaxMarks;
  final bool isPrac;
  final String subjectName;

  StudentExamMarksItem({
    required this.studentId,
    required this.examSubId,
    required this.theoryMarks,
    required this.minMarks,
    required this.maxMarks,
    required this.status,
    required this.practicalMarks,
    required this.pMinMarks,
    required this.pMaxMarks,
    required this.isPrac,
    required this.subjectName,
  });

  factory StudentExamMarksItem.fromJson(Map<String, dynamic> json) {
    return StudentExamMarksItem(
      studentId: int.tryParse((json['StudentId'] ?? '0').toString()) ?? 0,
      examSubId: int.tryParse((json['ExamSubId'] ?? '0').toString()) ?? 0,
      theoryMarks: int.tryParse((json['TheoryMarks'] ?? '0').toString()) ?? 0,
      minMarks: int.tryParse((json['MinMarks'] ?? '0').toString()) ?? 0,
      maxMarks: int.tryParse((json['MaxMarks'] ?? '0').toString()) ?? 0,
      status: (json['Status'] ?? '').toString(),
      practicalMarks: int.tryParse((json['PracticalMarks'] ?? '0').toString()) ?? 0,
      pMinMarks: int.tryParse((json['PMinMarks'] ?? '0').toString()) ?? 0,
      pMaxMarks: int.tryParse((json['PMaxMarks'] ?? '0').toString()) ?? 0,
      isPrac: (json['IsPrac'] as bool?) ?? false,
      subjectName: (json['SubjectName'] ?? '').toString(),
    );
  }
}

class StudentExamService {
  static Future<List<StudentExamItem>> fetchStudentExams() async {
    try {
      // Get ClassId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final classId = prefs.getInt('ClassId') ?? prefs.getString('ClassId') ?? 27; // Handle both int and string
      final classIdString = classId.toString();
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/OnlineExam/StudentExam?ClassId=$classIdString');
      
      // Debug: Print request details
      print('🔍 [STUDENT EXAMS API] Request Details:');
      print('   📍 URL: $uri');
      print('   🔑 ClassId: $classIdString');
      print('   📝 Method: GET');
      print('   ⏰ Timestamp: ${DateTime.now()}');
      print('');
      
      final res = await http.get(uri);
      
      // Debug: Print response details
      print('📡 [STUDENT EXAMS API] Response Details:');
      print('   📊 Status Code: ${res.statusCode}');
      print('   📏 Content Length: ${res.body.length}');
      print('   📄 Response Body:');
      print('   ${res.body}');
      print('');
      
      if (res.statusCode != 200) {
        print('❌ [STUDENT EXAMS API] Error: Status code ${res.statusCode}');
        return [];
      }
      
      final decoded = json.decode(res.body) as Map<String, dynamic>;
      
      // Debug: Print parsed response
      print('✅ [STUDENT EXAMS API] Parsed Response:');
      print('   🎯 Success: ${decoded['success']}');
      print('   📊 Data Type: ${decoded['data'].runtimeType}');
      if (decoded['data'] is List) {
        print('   📋 Data Count: ${(decoded['data'] as List).length}');
        for (int i = 0; i < (decoded['data'] as List).length; i++) {
          final exam = decoded['data'][i];
          print('   📝 Exam ${i + 1}: ${exam['Title']} (ID: ${exam['ExamId']})');
        }
      }
      print('');
      
      if (decoded['success'] == true && decoded['data'] is List) {
        final List<dynamic> data = decoded['data'] as List<dynamic>;
        final exams = data.map((e) => StudentExamItem.fromJson(e as Map<String, dynamic>)).toList();
        
        print('🎉 [STUDENT EXAMS API] Successfully parsed ${exams.length} exams');
        print('');
        
        return exams;
      }
      
      print('⚠️ [STUDENT EXAMS API] No valid data found in response');
      print('');
      return [];
    } catch (e) {
      print('💥 [STUDENT EXAMS API] Exception occurred:');
      print('   🚨 Error: $e');
      print('   📍 Stack Trace: ${StackTrace.current}');
      print('');
      return [];
    }
  }

  static Future<List<StudentExamMarksItem>> fetchStudentExamMarks({required int examId}) async {
    try {
      // Get Uid from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getInt('Uid') ?? prefs.getString('Uid') ?? ''; // Handle both int and string
      final uidString = uid.toString();
      
      if (uidString.isEmpty) {
        print('❌ [STUDENT EXAM MARKS API] Uid not found in SharedPreferences');
        return [];
      }
      
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/User/StudentExamMarks');
      
      // Create form data
      final request = http.MultipartRequest('POST', uri);
      request.fields['Uid'] = uidString;
      request.fields['ExamId'] = examId.toString();
      
      // Debug: Print request details
      print('🔍 [STUDENT EXAM MARKS API] Request Details:');
      print('   📍 URL: $uri');
      print('   🔑 Uid: $uidString');
      print('   📝 ExamId: $examId');
      print('   📝 Method: POST');
      print('   📋 Form Data:');
      print('     - Uid: $uidString');
      print('     - ExamId: $examId');
      print('   ⏰ Timestamp: ${DateTime.now()}');
      print('');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Debug: Print response details
      print('📡 [STUDENT EXAM MARKS API] Response Details:');
      print('   📊 Status Code: ${response.statusCode}');
      print('   📏 Content Length: ${response.body.length}');
      print('   📄 Response Body:');
      print('   ${response.body}');
      print('');
      
      if (response.statusCode != 200) {
        print('❌ [STUDENT EXAM MARKS API] Error: Status code ${response.statusCode}');
        return [];
      }
      
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      
      // Debug: Print parsed response
      print('✅ [STUDENT EXAM MARKS API] Parsed Response:');
      print('   🎯 Success: ${decoded['success']}');
      print('   📊 Data Type: ${decoded['data'].runtimeType}');
      if (decoded['data'] is List) {
        print('   📋 Data Count: ${(decoded['data'] as List).length}');
        for (int i = 0; i < (decoded['data'] as List).length; i++) {
          final mark = decoded['data'][i];
          print('   📝 Subject ${i + 1}: ${mark['SubjectName']} - ${mark['TheoryMarks']}/${mark['MaxMarks']} (${mark['Status']})');
        }
      }
      print('');
      
      if (decoded['success'] == true && decoded['data'] is List) {
        final List<dynamic> data = decoded['data'] as List<dynamic>;
        final marks = data.map((e) => StudentExamMarksItem.fromJson(e as Map<String, dynamic>)).toList();
        
        print('🎉 [STUDENT EXAM MARKS API] Successfully parsed ${marks.length} subject marks');
        print('');
        
        return marks;
      }
      
      print('⚠️ [STUDENT EXAM MARKS API] No valid data found in response');
      print('');
      return [];
    } catch (e) {
      print('💥 [STUDENT EXAM MARKS API] Exception occurred:');
      print('   🚨 Error: $e');
      print('   📍 Stack Trace: ${StackTrace.current}');
      print('');
      return [];
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class CalendarService {
  static Future<List<EventData>> getEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/Events');
      final request = http.MultipartRequest('GET', url);
      request.fields['UId'] = uid;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'];
          return data.map((json) => EventData.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  static Future<AnnualCalendarData> getAnnualCalendar(int year) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/AnnualCalendarAdmin');
      final request = http.MultipartRequest('POST', url);
      request.fields['UId'] = uid;
      request.fields['Year'] = year.toString();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return AnnualCalendarData.fromJson(jsonData['data']);
        }
      }
      throw Exception('Failed to load annual calendar');
    } catch (e) {
      print('Error fetching annual calendar: $e');
      rethrow;
    }
  }
}

class EventData {
  final int eventId;
  final String eventName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final String venue;
  final String className;

  EventData({
    required this.eventId,
    required this.eventName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.className,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      eventId: json['EventId'] ?? 0,
      eventName: json['EventName'] ?? '',
      description: json['Description'] ?? '',
      startDate: DateTime.parse(json['StartDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['EndDate'] ?? DateTime.now().toIso8601String()),
      startTime: json['StartTime'] ?? '',
      endTime: json['EndTime'] ?? '',
      venue: json['Venue'] ?? '',
      className: json['ClassName'] ?? '',
    );
  }
}

class AnnualCalendarData {
  final List<CalendarItem> holidays;
  final List<CalendarItem> events;
  final List<CalendarItem> exams;

  AnnualCalendarData({
    required this.holidays,
    required this.events,
    required this.exams,
  });

  factory AnnualCalendarData.fromJson(Map<String, dynamic> json) {
    return AnnualCalendarData(
      holidays: (json['holidays'] as List<dynamic>?)
          ?.map((item) => CalendarItem.fromJson(item))
          .toList() ?? [],
      events: (json['events'] as List<dynamic>?)
          ?.map((item) => CalendarItem.fromJson(item))
          .toList() ?? [],
      exams: (json['exams'] as List<dynamic>?)
          ?.map((item) => CalendarItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class CalendarItem {
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? backgroundColor;

  CalendarItem({
    required this.title,
    required this.start,
    this.end,
    this.backgroundColor,
  });

  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    return CalendarItem(
      title: json['title'] ?? '',
      start: DateTime.parse(json['start'] ?? DateTime.now().toIso8601String()),
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
      backgroundColor: json['backgroundColor'],
    );
  }
}

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/api_constants.dart';

class EventsService {
  static Future<EventCalendarResponse?> getEventCalendar({int? year}) async {
    try {
      debugPrint('=== EVENT CALENDAR API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final currentYear = year ?? DateTime.now().year;

      debugPrint('UID: $uid');
      debugPrint('Year: $currentYear');

      if (uid.isEmpty) {
        debugPrint('Missing UID in preferences');
        return null;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.eventCalendar}');
      debugPrint('URL: $url');

      final request = http.MultipartRequest('POST', url);
      request.fields['Uid'] = uid;
      request.fields['Year'] = currentYear.toString();

      debugPrint('=== REQUEST FIELDS ===');
      debugPrint('Uid: $uid');
      debugPrint('Year: $currentYear');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('=== EVENT CALENDAR API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('=== PARSED JSON DATA ===');
        debugPrint('Success: ${jsonData['success']}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final eventCalendar = EventCalendarResponse.fromJson(jsonData);
          debugPrint('=== EVENT CALENDAR PARSED ===');
          debugPrint('Holidays: ${eventCalendar.data.holidays.length}');
          debugPrint('Events: ${eventCalendar.data.events.length}');
          debugPrint('Exams: ${eventCalendar.data.exams.length}');
          return eventCalendar;
        } else {
          debugPrint('API returned success=false or null data');
          return null;
        }
      } else {
        debugPrint('API call failed with status: ${response.statusCode}');
        debugPrint('Error body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('=== EVENT CALENDAR API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}

// Data Models
class EventCalendarResponse {
  final bool success;
  final EventCalendarData data;

  EventCalendarResponse({
    required this.success,
    required this.data,
  });

  factory EventCalendarResponse.fromJson(Map<String, dynamic> json) {
    return EventCalendarResponse(
      success: json['success'] ?? false,
      data: EventCalendarData.fromJson(json['data'] ?? {}),
    );
  }
}

class EventCalendarData {
  final List<CalendarEvent> holidays;
  final List<CalendarEvent> events;
  final List<CalendarEvent> exams;

  EventCalendarData({
    required this.holidays,
    required this.events,
    required this.exams,
  });

  factory EventCalendarData.fromJson(Map<String, dynamic> json) {
    return EventCalendarData(
      holidays: (json['holidays'] as List<dynamic>?)
          ?.map((item) => CalendarEvent.fromJson(item, EventType.holiday))
          .toList() ?? [],
      events: (json['events'] as List<dynamic>?)
          ?.map((item) => CalendarEvent.fromJson(item, EventType.event))
          .toList() ?? [],
      exams: (json['exams'] as List<dynamic>?)
          ?.map((item) => CalendarEvent.fromJson(item, EventType.exam))
          .toList() ?? [],
    );
  }

  List<CalendarEvent> get allEvents => [...holidays, ...events, ...exams];
}

class CalendarEvent {
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? backgroundColor;
  final EventType type;

  CalendarEvent({
    required this.title,
    required this.start,
    this.end,
    this.backgroundColor,
    required this.type,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json, EventType type) {
    return CalendarEvent(
      title: json['title'] ?? '',
      start: DateTime.parse(json['start'] ?? DateTime.now().toIso8601String()),
      end: json['end'] != null ? DateTime.parse(json['end']) : null,
      backgroundColor: json['backgroundColor'],
      type: type,
    );
  }

  // Get color based on event type
  Color get color {
    switch (type) {
      case EventType.holiday:
        return const Color(0xFFE74C3C); // Red
      case EventType.event:
        return const Color(0xFF4A90E2); // Blue
      case EventType.exam:
        return const Color(0xFFFF9500); // Orange
    }
  }

  // Check if event is multi-day
  bool get isMultiDay => end != null && !isSameDay(start, end!);

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

enum EventType { holiday, event, exam }

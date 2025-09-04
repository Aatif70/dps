import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:AES/constants/api_constants.dart';

class GalleryService {
  static Future<GalleryResponse?> getGallery() async {
    try {
      debugPrint('=== GALLERY API CALL ===');

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';

      debugPrint('UID: $uid');

      if (uid.isEmpty) {
        debugPrint('Missing UID in preferences');
        return null;
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/api/User/Gallery?Uid=$uid');
      debugPrint('URL: $url');

      final response = await http.get(url);

      debugPrint('=== GALLERY API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        debugPrint('=== PARSED JSON DATA ===');
        debugPrint('Success: ${jsonData['success']}');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final galleryResponse = GalleryResponse.fromJson(jsonData);
          debugPrint('=== GALLERY PARSED ===');
          debugPrint('Events: ${galleryResponse.data.length}');

          // Count total media
          int totalMedia = 0;
          for (var event in galleryResponse.data) {
            totalMedia += event.media.length;
            debugPrint('${event.title}: ${event.media.length} media items');
          }
          debugPrint('Total media items: $totalMedia');

          return galleryResponse;
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
      debugPrint('=== GALLERY API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}

// Data Models
class GalleryResponse {
  final bool success;
  final List<GalleryEvent> data;

  GalleryResponse({
    required this.success,
    required this.data,
  });

  factory GalleryResponse.fromJson(Map<String, dynamic> json) {
    return GalleryResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => GalleryEvent.fromJson(item))
          .toList() ?? [],
    );
  }

  // Get all media items from all events
  List<MediaItem> get allMedia {
    List<MediaItem> allMediaItems = [];
    for (var event in data) {
      for (var media in event.media) {
        allMediaItems.add(media);
      }
    }
    return allMediaItems;
  }

  // Get only images
  List<MediaItem> get allImages {
    return allMedia.where((media) => media.mediaType == 'image').toList();
  }
}

class GalleryEvent {
  final int eventId;
  final String title;
  final String date;
  final List<MediaItem> media;

  GalleryEvent({
    required this.eventId,
    required this.title,
    required this.date,
    required this.media,
  });

  factory GalleryEvent.fromJson(Map<String, dynamic> json) {
    return GalleryEvent(
      eventId: json['EventId'] ?? 0,
      title: json['Title'] ?? '',
      date: json['Date'] ?? '',
      media: (json['Media'] as List<dynamic>?)
          ?.map((item) => MediaItem.fromJson(item))
          .toList() ?? [],
    );
  }

  DateTime get parsedDate {
    try {
      // Parse date format "20-Mar-2025"
      final parts = date.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final monthStr = parts[1];
        final year = int.parse(parts[2]);

        final monthMap = {
          'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
        };

        final month = monthMap[monthStr] ?? 1;
        return DateTime(year, month, day);
      }
    } catch (e) {
      debugPrint('Error parsing date: $date');
    }
    return DateTime.now();
  }
}

class MediaItem {
  final String mediaType;
  final String filePath;

  MediaItem({
    required this.mediaType,
    required this.filePath,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      mediaType: json['MediaType'] ?? '',
      filePath: json['FilePath'] ?? '',
    );
  }

  String get fullUrl {
    if (filePath.startsWith('http')) {
      return filePath;
    } else {
      return '${ApiConstants.baseUrl}$filePath';
    }
  }

  bool get isImage => mediaType.toLowerCase() == 'image';
  bool get isVideo => mediaType.toLowerCase() == 'video';
  bool get isYoutube => mediaType.toLowerCase() == 'youtube';
}

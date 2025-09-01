class EmployeeAttendanceResponse {
  final bool success;
  final EmployeeAttendanceData data;

  EmployeeAttendanceResponse({
    required this.success,
    required this.data,
  });

  factory EmployeeAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendanceResponse(
      success: json['success'] ?? false,
      data: EmployeeAttendanceData.fromJson(json['data'] ?? {}),
    );
  }
}

class EmployeeAttendanceData {
  final bool success;
  final int employeeId;
  final String employeeName;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime evaluatedTill;
  final int totalWorkingDays;
  final int totalPresentDays;
  final int totalAbsentDays;
  final List<DailyAttendanceDetail> dailyDetails;

  EmployeeAttendanceData({
    required this.success,
    required this.employeeId,
    required this.employeeName,
    required this.startDate,
    required this.endDate,
    required this.evaluatedTill,
    required this.totalWorkingDays,
    required this.totalPresentDays,
    required this.totalAbsentDays,
    required this.dailyDetails,
  });

  factory EmployeeAttendanceData.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendanceData(
      success: json['success'] ?? false,
      employeeId: json['EmployeeId'] ?? 0,
      employeeName: json['EmployeeName'] ?? '',
      startDate: DateTime.parse(json['StartDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['EndDate'] ?? DateTime.now().toIso8601String()),
      evaluatedTill: DateTime.parse(json['EvaluatedTill'] ?? DateTime.now().toIso8601String()),
      totalWorkingDays: json['TotalWorkingDays'] ?? 0,
      totalPresentDays: json['TotalPresentDays'] ?? 0,
      totalAbsentDays: json['TotalAbsentDays'] ?? 0,
      dailyDetails: (json['DailyDetails'] as List<dynamic>?)
          ?.map((item) => DailyAttendanceDetail.fromJson(item))
          .toList() ?? [],
    );
  }
}

class DailyAttendanceDetail {
  final DateTime date;
  final String dayName;
  final String status;
  final String? inTime;
  final String? outTime;

  DailyAttendanceDetail({
    required this.date,
    required this.dayName,
    required this.status,
    this.inTime,
    this.outTime,
  });

  factory DailyAttendanceDetail.fromJson(Map<String, dynamic> json) {
    return DailyAttendanceDetail(
      date: DateTime.parse(json['Date'] ?? DateTime.now().toIso8601String()),
      dayName: json['DayName'] ?? '',
      status: json['Status'] ?? '',
      inTime: json['InTime'],
      outTime: json['OutTime'],
    );
  }

  // Helper getter for status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'present':
        return '0xFF10B981'; // Green
      case 'absent':
        return '0xFFEF4444'; // Red
      case 'sunday':
        return '0xFF6B7280'; // Gray
      default:
        return '0xFF6B7280'; // Gray
    }
  }

  // Helper getter for status icon
  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'present':
        return 'check_circle';
      case 'absent':
        return 'cancel';
      case 'sunday':
        return 'weekend';
      default:
        return 'help';
    }
  }
}

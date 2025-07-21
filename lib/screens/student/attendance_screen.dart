import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // Mock data for attendance
  final Map<String, double> monthlyAttendance = {
    'Apr': 0.92,
    'May': 0.88,
    'Jun': 0.75,
    'Jul': 0.95,
    'Aug': 0.85,
    'Sep': 0.78,
  };

  // Mock attendance records
  final List<AttendanceRecord> attendanceRecords = [
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: AttendanceStatus.absent,
      subject: 'All Classes',
      reason: 'Medical Leave',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 4)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 6)),
      status: AttendanceStatus.halfDay,
      subject: 'All Classes',
      reason: 'Left after Lunch',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 7)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 8)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 9)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 10)),
      status: AttendanceStatus.absent,
      subject: 'All Classes',
      reason: 'Family Function',
    ),
  ];

  String _selectedMonth = DateFormat('MMM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final attendancePercentage = monthlyAttendance[_selectedMonth] ?? 0.0;
    final presentDays = (attendancePercentage * 30).round();
    final absentDays = 30 - presentDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.attendance),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAttendanceOverview(attendancePercentage, presentDays, absentDays),
            _buildMonthSelector(),
            _buildAttendanceGraph(),
            _buildAttendanceHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceOverview(double percentage, int presentDays, int absentDays) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Month',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('MMMM').format(DateTime.now())} ${DateTime.now().year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}% Attendance',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttendanceStat(
                'Present',
                presentDays.toString(),
                const Color(0xFF4ade80),
              ),
              _buildAttendanceStat(
                'Absent',
                absentDays.toString(),
                const Color(0xFFf87171),
              ),
              _buildAttendanceStat(
                'Half Day',
                '2',
                const Color(0xFFfbbf24),
              ),
              _buildAttendanceStat(
                'Holidays',
                '4',
                const Color(0xFFa78bfa),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: monthlyAttendance.keys.map((month) {
          final isSelected = month == _selectedMonth;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMonth = month;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  else
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                month,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttendanceGraph() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: monthlyAttendance.entries.map((entry) {
                final isSelected = entry.key == _selectedMonth;
                return _buildBar(entry.key, entry.value, isSelected);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String month, double percentage, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 150 * percentage,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4A90E2)
                : const Color(0xFF4A90E2).withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF718096),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceHistory() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View complete history
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendanceRecords.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: _getStatusColor(record.status).withOpacity(0.2),
                  child: Icon(
                    _getStatusIcon(record.status),
                    color: _getStatusColor(record.status),
                    size: 18,
                  ),
                ),
                title: Text(
                  DateFormat('EEEE, d MMMM').format(record.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  record.reason.isNotEmpty
                      ? '${_getStatusText(record.status)} - ${record.reason}'
                      : _getStatusText(record.status),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                trailing: Text(
                  DateFormat('h:mm a').format(record.date),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF4ade80);
      case AttendanceStatus.absent:
        return const Color(0xFFf87171);
      case AttendanceStatus.halfDay:
        return const Color(0xFFfbbf24);
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline;
      case AttendanceStatus.absent:
        return Icons.cancel_outlined;
      case AttendanceStatus.halfDay:
        return Icons.timelapse_outlined;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.halfDay:
        return 'Half Day';
    }
  }
}

enum AttendanceStatus { present, absent, halfDay }

class AttendanceRecord {
  final DateTime date;
  final AttendanceStatus status;
  final String subject;
  final String reason;

  AttendanceRecord({
    required this.date,
    required this.status,
    required this.subject,
    this.reason = '',
  });
} 
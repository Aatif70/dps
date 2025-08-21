import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';

class AdminEmployeeAttendanceHubScreen extends StatelessWidget {
  const AdminEmployeeAttendanceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AttendanceItem(
        title: 'Employee Attendance',
        subtitle: 'Browse attendance by date range',
        icon: Icons.event_available_rounded,
        color: const Color(0xFF6C5CE7),
        route: AppRoutes.adminEmployeeAttendanceList,
      ),
      _AttendanceItem(
        title: 'Add Attendance',
        subtitle: 'Mark present/absent with time',
        icon: Icons.playlist_add_check_rounded,
        color: const Color(0xFF2ECC71),
        route: AppRoutes.adminAddEmployeeAttendance,
      ),
      _AttendanceItem(
        title: 'Update Attendance',
        subtitle: 'Edit existing records',
        icon: Icons.edit_calendar_rounded,
        color: const Color(0xFFE17055),
        route: AppRoutes.adminUpdateEmployeeAttendance,
      ),
      _AttendanceItem(
        title: 'Employee-wise Report',
        subtitle: 'Present/Absent summary for a range',
        icon: Icons.assessment_rounded,
        color: const Color(0xFF4A90E2),
        route: AppRoutes.adminEmployeeAttendanceReport,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final _AttendanceItem item = items[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, item.route),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        Text(item.subtitle, style: const TextStyle(color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _AttendanceItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _AttendanceItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}



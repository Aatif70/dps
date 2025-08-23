import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';

class AdminAttendanceHubScreen extends StatelessWidget {
  const AdminAttendanceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentItems = [
      _AttendanceItem(
        title: 'Student Attendance',
        subtitle: 'View class-wise attendance reports',
        icon: Icons.school_rounded,
        color: const Color(0xFF4A90E2),
        route: AppRoutes.adminStudentAttendance,
      ),
      _AttendanceItem(
        title: 'Attendance by Date',
        subtitle: 'Get attendance by date/month/year',
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFF00CEC9),
        route: AppRoutes.adminStudentAttendanceByDate,
      ),
    ];

    final employeeItems = [
      _AttendanceItem(
        title: 'Employee Attendance',
        subtitle: 'Browse attendance by date range',
        icon: Icons.event_available_rounded,
        color: const Color(0xFF6C5CE7),
        route: AppRoutes.adminEmployeeAttendanceList,
      ),
      _AttendanceItem(
        title: 'Add Employee Attendance',
        subtitle: 'Mark present/absent with time',
        icon: Icons.playlist_add_check_rounded,
        color: const Color(0xFF2ECC71),
        route: AppRoutes.adminAddEmployeeAttendance,
      ),
      _AttendanceItem(
        title: 'Update Employee Attendance',
        subtitle: 'Edit existing records',
        icon: Icons.edit_calendar_rounded,
        color: const Color(0xFFE17055),
        route: AppRoutes.adminUpdateEmployeeAttendance,
      ),
      _AttendanceItem(
        title: 'Employee-wise Report',
        subtitle: 'Present/Absent summary for a range',
        icon: Icons.assessment_rounded,
        color: const Color(0xFFFD79A8),
        route: AppRoutes.adminEmployeeAttendanceReport,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withOpacity(0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.document_scanner_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attendance Management',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage student and employee attendance',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Student Section
                _buildSectionTitle('Student Attendance', Icons.school_rounded, const Color(0xFF4A90E2)),
                const SizedBox(height: 16),
                _buildItemsGrid(studentItems),
                const SizedBox(height: 30),
                
                // Employee Section
                _buildSectionTitle('Employee Attendance', Icons.people_rounded, const Color(0xFF6C5CE7)),
                const SizedBox(height: 16),
                _buildItemsGrid(employeeItems),
                const SizedBox(height: 30), // Add bottom padding for better scrolling
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsGrid(List<_AttendanceItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75, // Increased from 0.9 to give more height
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, item.route),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.color.withOpacity(0.1),
                          item.color.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.icon, color: item.color, size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

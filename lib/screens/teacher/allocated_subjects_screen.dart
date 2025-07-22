import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TeacherAllocatedSubjectsScreen extends StatefulWidget {
  const TeacherAllocatedSubjectsScreen({super.key});

  @override
  State<TeacherAllocatedSubjectsScreen> createState() => _TeacherAllocatedSubjectsScreenState();
}

class _TeacherAllocatedSubjectsScreenState extends State<TeacherAllocatedSubjectsScreen> {
  // Mock data for allocated subjects
  final List<AllocatedSubject> _allocatedSubjects = [
    AllocatedSubject(
      id: 'SUB-2023-001',
      name: 'Mathematics',
      className: 'Class 10-A',
      schedule: [
        ClassSchedule(day: 'Monday', startTime: '9:00 AM', endTime: '10:30 AM'),
        ClassSchedule(day: 'Wednesday', startTime: '11:00 AM', endTime: '12:30 PM'),
        ClassSchedule(day: 'Friday', startTime: '9:00 AM', endTime: '10:30 AM'),
      ],
      totalStudents: 32,
      averageAttendance: 0.92,
      averagePerformance: 0.85,
      syllabusCoverage: 0.65,
      upcomingTopic: 'Quadratic Equations',
    ),
    AllocatedSubject(
      id: 'SUB-2023-002',
      name: 'Mathematics',
      className: 'Class 10-B',
      schedule: [
        ClassSchedule(day: 'Monday', startTime: '11:00 AM', endTime: '12:30 PM'),
        ClassSchedule(day: 'Thursday', startTime: '9:00 AM', endTime: '10:30 AM'),
      ],
      totalStudents: 30,
      averageAttendance: 0.88,
      averagePerformance: 0.82,
      syllabusCoverage: 0.62,
      upcomingTopic: 'Quadratic Equations',
    ),
    AllocatedSubject(
      id: 'SUB-2023-003',
      name: 'Physics',
      className: 'Class 11-A',
      schedule: [
        ClassSchedule(day: 'Tuesday', startTime: '9:00 AM', endTime: '10:30 AM'),
        ClassSchedule(day: 'Thursday', startTime: '11:00 AM', endTime: '12:30 PM'),
      ],
      totalStudents: 28,
      averageAttendance: 0.90,
      averagePerformance: 0.78,
      syllabusCoverage: 0.58,
      upcomingTopic: 'Newton\'s Laws of Motion',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.allocatedSubjects),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: _buildSubjectsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    // Calculate summary statistics
    final totalClasses = _allocatedSubjects.length;
    final totalStudents = _allocatedSubjects.fold<int>(
      0,
      (sum, subject) => sum + subject.totalStudents,
    );
    final averagePerformance = _allocatedSubjects.fold<double>(
      0,
      (sum, subject) => sum + subject.averagePerformance,
    ) / totalClasses;
    final averageSyllabusCoverage = _allocatedSubjects.fold<double>(
      0,
      (sum, subject) => sum + subject.syllabusCoverage,
    ) / totalClasses;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subject Allocation Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Academic Year 2023-24',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
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
                  '$totalClasses Classes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Total Students',
                totalStudents.toString(),
                Icons.people_rounded,
              ),
              _buildSummaryItem(
                'Avg. Performance',
                '${(averagePerformance * 100).toInt()}%',
                Icons.trending_up_rounded,
              ),
              _buildSummaryItem(
                'Syllabus Coverage',
                '${(averageSyllabusCoverage * 100).toInt()}%',
                Icons.menu_book_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allocatedSubjects.length,
      itemBuilder: (context, index) {
        return _buildSubjectCard(_allocatedSubjects[index]);
      },
    );
  }

  Widget _buildSubjectCard(AllocatedSubject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getSubjectColor(subject.name).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getSubjectIcon(subject.name),
            color: _getSubjectColor(subject.name),
            size: 24,
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subject.className,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${subject.totalStudents} Students',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          
          // Schedule
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              ...subject.schedule.map((schedule) => _buildScheduleItem(schedule)).toList(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Performance Metrics
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Metrics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 12),
              _buildPerformanceMetric(
                'Attendance',
                subject.averageAttendance,
                const Color(0xFF4A90E2),
              ),
              const SizedBox(height: 8),
              _buildPerformanceMetric(
                'Performance',
                subject.averagePerformance,
                const Color(0xFF58CC02),
              ),
              const SizedBox(height: 8),
              _buildPerformanceMetric(
                'Syllabus Coverage',
                subject.syllabusCoverage,
                const Color(0xFFFF9500),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Upcoming Topic
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFF9500),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Upcoming Topic: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subject.upcomingTopic,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // View class details
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('View Students'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2ECC71),
                    side: const BorderSide(color: Color(0xFF2ECC71)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Create lesson plan
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text('Lesson Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(ClassSchedule schedule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              schedule.day.substring(0, 3),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${schedule.startTime} - ${schedule.endTime}',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: value,
          backgroundColor: Colors.grey.shade200,
          progressColor: color,
          barRadius: const Radius.circular(4),
          padding: EdgeInsets.zero,
          animation: true,
          animationDuration: 1000,
        ),
      ],
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return const Color(0xFF4A90E2);
      case 'science':
        return const Color(0xFF58CC02);
      case 'english':
        return const Color(0xFF8E44AD);
      case 'physics':
        return const Color(0xFFFF9500);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'english':
        return Icons.menu_book_rounded;
      case 'physics':
        return Icons.flash_on_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}

class AllocatedSubject {
  final String id;
  final String name;
  final String className;
  final List<ClassSchedule> schedule;
  final int totalStudents;
  final double averageAttendance;
  final double averagePerformance;
  final double syllabusCoverage;
  final String upcomingTopic;

  AllocatedSubject({
    required this.id,
    required this.name,
    required this.className,
    required this.schedule,
    required this.totalStudents,
    required this.averageAttendance,
    required this.averagePerformance,
    required this.syllabusCoverage,
    required this.upcomingTopic,
  });
}

class ClassSchedule {
  final String day;
  final String startTime;
  final String endTime;

  ClassSchedule({
    required this.day,
    required this.startTime,
    required this.endTime,
  });
} 
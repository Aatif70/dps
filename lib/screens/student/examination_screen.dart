import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class ExaminationScreen extends StatefulWidget {
  const ExaminationScreen({super.key});

  @override
  State<ExaminationScreen> createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends State<ExaminationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for exams
  final List<Exam> _exams = [
    Exam(
      id: 'EX-2023-001',
      name: 'Mid-Term Examination',
      examType: ExamType.midTerm,
      status: ExamStatus.upcoming,
      subjects: [
        ExamSubject(
          name: 'Mathematics',
          date: DateTime.now().add(const Duration(days: 5)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Hall A',
          totalMarks: 50,
        ),
        ExamSubject(
          name: 'Science',
          date: DateTime.now().add(const Duration(days: 7)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Hall B',
          totalMarks: 50,
        ),
        ExamSubject(
          name: 'English',
          date: DateTime.now().add(const Duration(days: 9)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Hall A',
          totalMarks: 50,
        ),
        ExamSubject(
          name: 'History',
          date: DateTime.now().add(const Duration(days: 11)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Hall B',
          totalMarks: 50,
        ),
      ],
    ),
    Exam(
      id: 'EX-2023-002',
      name: 'Final Examination',
      examType: ExamType.final_,
      status: ExamStatus.upcoming,
      subjects: [
        ExamSubject(
          name: 'Mathematics',
          date: DateTime.now().add(const Duration(days: 45)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 12, minute: 30),
          roomNo: 'Auditorium',
          totalMarks: 100,
        ),
        ExamSubject(
          name: 'Science',
          date: DateTime.now().add(const Duration(days: 47)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 12, minute: 30),
          roomNo: 'Auditorium',
          totalMarks: 100,
        ),
        ExamSubject(
          name: 'English',
          date: DateTime.now().add(const Duration(days: 49)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 12, minute: 30),
          roomNo: 'Auditorium',
          totalMarks: 100,
        ),
        ExamSubject(
          name: 'History',
          date: DateTime.now().add(const Duration(days: 51)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 12, minute: 30),
          roomNo: 'Auditorium',
          totalMarks: 100,
        ),
        ExamSubject(
          name: 'Computer Science',
          date: DateTime.now().add(const Duration(days: 53)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 12, minute: 30),
          roomNo: 'Computer Lab',
          totalMarks: 100,
        ),
      ],
    ),
    Exam(
      id: 'EX-2023-003',
      name: 'Quarterly Assessment',
      examType: ExamType.unit,
      status: ExamStatus.completed,
      subjects: [
        ExamSubject(
          name: 'Mathematics',
          date: DateTime.now().subtract(const Duration(days: 15)),
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Classroom 10A',
          totalMarks: 30,
          marksObtained: 26,
        ),
        ExamSubject(
          name: 'Science',
          date: DateTime.now().subtract(const Duration(days: 13)),
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Classroom 10A',
          totalMarks: 30,
          marksObtained: 28,
        ),
        ExamSubject(
          name: 'English',
          date: DateTime.now().subtract(const Duration(days: 10)),
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Classroom 10A',
          totalMarks: 30,
          marksObtained: 24,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upcomingExams = _exams.where((exam) => exam.status == ExamStatus.upcoming).toList();
    final completedExams = _exams.where((exam) => exam.status == ExamStatus.completed).toList();
    
    // Find nearest upcoming exam
    DateTime? nearestExamDate;
    for (var exam in upcomingExams) {
      for (var subject in exam.subjects) {
        if (nearestExamDate == null || subject.date.isBefore(nearestExamDate)) {
          nearestExamDate = subject.date;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.examination),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2ECC71),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2ECC71),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Results'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (nearestExamDate != null) 
            _buildExamCountdown(nearestExamDate),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingExams(upcomingExams),
                _buildCompletedExams(completedExams),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCountdown(DateTime nextExamDate) {
    final daysLeft = nextExamDate.difference(DateTime.now()).inDays;
    final hoursLeft = nextExamDate.difference(DateTime.now()).inHours % 24;
    final nextExamDateStr = DateFormat('dd MMM yyyy').format(nextExamDate);
    
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
          const Row(
            children: [
              Icon(
                Icons.timer,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Next Exam Countdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$daysLeft Days, $hoursLeft Hours Left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next exam on $nextExamDateStr',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.2, // Example progress
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingExams(List<Exam> exams) {
    if (exams.isEmpty) {
      return _buildEmptyState('No upcoming exams', 'You have no scheduled exams at this time.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        return _buildExamCard(exams[index]);
      },
    );
  }

  Widget _buildCompletedExams(List<Exam> exams) {
    if (exams.isEmpty) {
      return _buildEmptyState('No exam results', 'Your completed exam results will appear here.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        return _buildExamResultCard(exams[index]);
      },
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    // Sort subjects by date
    final subjects = List<ExamSubject>.from(exam.subjects)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getExamTypeColor(exam.examType).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getExamTypeColor(exam.examType).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getExamTypeIcon(exam.examType),
                    color: _getExamTypeColor(exam.examType),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getExamTypeName(exam.examType),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getExamTypeColor(exam.examType),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2ECC71).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${subjects.length} Subjects',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _buildSubjectItem(subject);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Download hall ticket
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Hall Ticket'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2ECC71),
                    side: const BorderSide(color: Color(0xFF2ECC71)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // View timetable
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Timetable'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    side: const BorderSide(color: Color(0xFF4A90E2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(ExamSubject subject) {
    final formattedDate = DateFormat('E, d MMM yyyy').format(subject.date);
    final formattedStartTime = subject.startTime.format(context);
    final formattedEndTime = subject.endTime.format(context);
    
    final isUpcoming = subject.date.isAfter(DateTime.now());
    final daysLeft = subject.date.difference(DateTime.now()).inDays;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getSubjectColor(subject.name).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                subject.name[0],
                style: TextStyle(
                  color: _getSubjectColor(subject.name),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$formattedStartTime - $formattedEndTime',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.room,
                      size: 12,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subject.roomNo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 12,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Total Marks: ${subject.totalMarks}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUpcoming)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2ECC71).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                daysLeft == 0
                    ? 'Today'
                    : daysLeft == 1
                        ? 'Tomorrow'
                        : '$daysLeft Days',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2ECC71),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExamResultCard(Exam exam) {
    // Calculate total marks and percentage
    int totalMarksObtained = 0;
    int totalPossibleMarks = 0;
    
    for (var subject in exam.subjects) {
      if (subject.marksObtained != null) {
        totalMarksObtained += subject.marksObtained!;
        totalPossibleMarks += subject.totalMarks;
      }
    }
    
    final percentage = (totalMarksObtained / totalPossibleMarks) * 100;
    final grade = _calculateGrade(percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getExamTypeColor(exam.examType).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getExamTypeColor(exam.examType).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getExamTypeIcon(exam.examType),
                    color: _getExamTypeColor(exam.examType),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getExamTypeName(exam.examType),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getExamTypeColor(exam.examType),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultStat(
                  'Total Marks',
                  '$totalMarksObtained/$totalPossibleMarks',
                  const Color(0xFF4A90E2),
                ),
                _buildDivider(),
                _buildResultStat(
                  'Percentage',
                  '${percentage.toStringAsFixed(1)}%',
                  const Color(0xFF2ECC71),
                ),
                _buildDivider(),
                _buildResultStat(
                  'Grade',
                  grade,
                  _getGradeColor(grade),
                ),
              ],
            ),
          ),
          const Divider(),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exam.subjects.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final subject = exam.subjects[index];
              return _buildSubjectResult(subject);
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                // Download report card
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Report Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSubjectResult(ExamSubject subject) {
    if (subject.marksObtained == null) {
      return const SizedBox();
    }
    
    final percentage = (subject.marksObtained! / subject.totalMarks) * 100;
    final grade = _calculateGrade(percentage);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getSubjectColor(subject.name).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                subject.name[0],
                style: TextStyle(
                  color: _getSubjectColor(subject.name),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Exam Date: ${DateFormat('d MMM yyyy').format(subject.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${subject.marksObtained}/${subject.totalMarks}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getGradeColor(grade).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(grade),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Color _getExamTypeColor(ExamType type) {
    switch (type) {
      case ExamType.final_:
        return const Color(0xFF4A90E2);
      case ExamType.midTerm:
        return const Color(0xFFFF9500);
      case ExamType.unit:
        return const Color(0xFF8E44AD);
    }
  }

  IconData _getExamTypeIcon(ExamType type) {
    switch (type) {
      case ExamType.final_:
        return Icons.school;
      case ExamType.midTerm:
        return Icons.assignment;
      case ExamType.unit:
        return Icons.quiz;
    }
  }

  String _getExamTypeName(ExamType type) {
    switch (type) {
      case ExamType.final_:
        return 'Final Examination';
      case ExamType.midTerm:
        return 'Mid-Term Examination';
      case ExamType.unit:
        return 'Unit Test';
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return const Color(0xFF4A90E2);
      case 'science':
        return const Color(0xFF58CC02);
      case 'english':
        return const Color(0xFFE74C3C);
      case 'history':
        return const Color(0xFF8E44AD);
      case 'geography':
        return const Color(0xFFFF9500);
      case 'computer science':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF718096);
    }
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) {
      return 'A+';
    } else if (percentage >= 80) {
      return 'A';
    } else if (percentage >= 70) {
      return 'B+';
    } else if (percentage >= 60) {
      return 'B';
    } else if (percentage >= 50) {
      return 'C';
    } else if (percentage >= 40) {
      return 'D';
    } else {
      return 'F';
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return const Color(0xFF2ECC71);
      case 'A':
        return const Color(0xFF2ECC71);
      case 'B+':
        return const Color(0xFF58CC02);
      case 'B':
        return const Color(0xFF58CC02);
      case 'C':
        return const Color(0xFFFF9500);
      case 'D':
        return const Color(0xFFFF9500);
      case 'F':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF718096);
    }
  }
}

enum ExamType { midTerm, final_, unit }

enum ExamStatus { upcoming, ongoing, completed }

class Exam {
  final String id;
  final String name;
  final ExamType examType;
  final ExamStatus status;
  final List<ExamSubject> subjects;

  Exam({
    required this.id,
    required this.name,
    required this.examType,
    required this.status,
    required this.subjects,
  });
}

class ExamSubject {
  final String name;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String roomNo;
  final int totalMarks;
  final int? marksObtained;

  ExamSubject({
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.roomNo,
    required this.totalMarks,
    this.marksObtained,
  });
} 
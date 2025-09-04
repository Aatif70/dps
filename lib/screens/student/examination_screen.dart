import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:AES/constants/app_strings.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ExaminationScreen extends StatefulWidget {
  const ExaminationScreen({super.key});

  @override
  State<ExaminationScreen> createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends State<ExaminationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Calendar variables
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Enhanced mock data for examinations
  final List<Exam> _exams = [
    Exam(
      id: 'EX-2024-001',
      name: 'Mid-Term Examination',
      examType: ExamType.midTerm,
      status: ExamStatus.upcoming,
      subjects: [
        ExamSubject(
          name: 'Mathematics',
          date: DateTime.now().add(const Duration(days: 3)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Hall A',
          totalMarks: 50,
          syllabus: 'Chapters 1-5: Linear Equations, Geometry, Algebra',
          examType: 'Written',
        ),
        ExamSubject(
          name: 'Science',
          date: DateTime.now().add(const Duration(days: 5)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Hall B',
          totalMarks: 50,
          syllabus: 'Physics: Motion, Force; Chemistry: Acids & Bases',
          examType: 'Written',
        ),
        ExamSubject(
          name: 'English',
          date: DateTime.now().add(const Duration(days: 7)),
          startTime: const TimeOfDay(hour: 9, minute: 30),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Hall A',
          totalMarks: 50,
          syllabus: 'Grammar, Comprehension, Essay Writing',
          examType: 'Written',
        ),
      ],
    ),
    Exam(
      id: 'EX-2024-002',
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
          syllabus: 'Complete Syllabus - All Chapters',
          examType: 'Written',
        ),
        ExamSubject(
          name: 'Computer Science',
          date: DateTime.now().add(const Duration(days: 47)),
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 12, minute: 0),
          roomNo: 'Computer Lab',
          totalMarks: 100,
          syllabus: 'Programming, Data Structures, Algorithms',
          examType: 'Practical',
        ),
      ],
    ),
    Exam(
      id: 'EX-2024-003',
      name: 'Unit Test - October',
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
          grade: 'A',
          remarks: 'Excellent performance in algebra section',
        ),
        ExamSubject(
          name: 'Science',
          date: DateTime.now().subtract(const Duration(days: 13)),
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Classroom 10A',
          totalMarks: 30,
          marksObtained: 28,
          grade: 'A+',
          remarks: 'Outstanding work, keep it up!',
        ),
        ExamSubject(
          name: 'English',
          date: DateTime.now().subtract(const Duration(days: 10)),
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 11, minute: 30),
          roomNo: 'Classroom 10A',
          totalMarks: 30,
          marksObtained: 24,
          grade: 'B+',
          remarks: 'Good effort. Focus on essay structure.',
        ),
      ],
    ),
  ];

  int _examStreak = 8;
  double _averagePerformance = 0.87;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start fade animation
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final upcomingExams = _exams.where((exam) => exam.status == ExamStatus.upcoming).toList();
    final completedExams = _exams.where((exam) => exam.status == ExamStatus.completed).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Enhanced Tab Section - Keep this fixed
            _buildEnhancedTabSection(context),

            const SizedBox(height: 10),

            // Scrollable content including header and tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Upcoming tab with scrollable content including header
                  _buildScrollableTabContent(
                    _buildEnhancedExamHeader(context),
                    _buildUpcomingExamsTab(upcomingExams),
                  ),
                  
                  // Results tab with scrollable content including header
                  _buildScrollableTabContent(
                    _buildEnhancedExamHeader(context),
                    _buildResultsTab(completedExams),
                  ),
                  
                  // Calendar tab with scrollable content including header
                  _buildScrollableTabContent(
                    _buildEnhancedExamHeader(context),
                    _buildCalendarTab(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create scrollable content with header
  Widget _buildScrollableTabContent(Widget header, Widget content) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Add padding to the header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: header,
          ),
          
          // Content
          content,
        ],
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Examinations',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF2D3748),
          size: 20,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.download_rounded,
              color: Color(0xFF2ECC71),
              size: 20,
            ),
          ),
          onPressed: () {
            _showDownloadOptions(context);
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedExamHeader(BuildContext context) {
    final nextExam = _getNextExam();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Exam Performance 📊',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (nextExam != null) ...[
                      Text(
                        _getTimeUntilNextExam(nextExam),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Until ${nextExam.name} (${nextExam.subject})',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.8),
                          fontSize: 14,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'No Upcoming Exams',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'All caught up! 🎉',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Achievement Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: Color(0xFFFF9500),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_examStreak Exam Streak! 🏆',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Performance Ring
              Stack(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: _averagePerformance,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha:0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(_averagePerformance * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Average',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTabSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2ECC71),
        unselectedLabelColor: const Color(0xFF718096),
        indicatorColor: const Color(0xFF2ECC71),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Upcoming'),
          Tab(text: 'Results'),
          Tab(text: 'Calendar'),
        ],
      ),
    );
  }

  Widget _buildUpcomingExamsTab(List<Exam> upcomingExams) {
    if (upcomingExams.isEmpty) {
      return _buildEmptyState(
        'No upcoming exams! 🎉',
        'You\'re all caught up. Focus on your studies and stay prepared for future assessments.',
        Icons.celebration_rounded,
        const Color(0xFF2ECC71),
      );
    }

    return Column(
      children: [
        for (var exam in upcomingExams) _buildEnhancedExamCard(exam)
      ],
    );
  }

  Widget _buildResultsTab(List<Exam> completedExams) {
    if (completedExams.isEmpty) {
      return _buildEmptyState(
        'No exam results yet 📋',
        'Your completed exam results will appear here once they are published by your teachers.',
        Icons.assignment_rounded,
        const Color(0xFF4A90E2),
      );
    }

    return Column(
      children: [
        for (var exam in completedExams) _buildEnhancedResultCard(exam)
      ],
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TableCalendar<ExamSubject>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: Color(0xFF718096)),
              holidayTextStyle: const TextStyle(color: Color(0xFFE74C3C)),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF2ECC71),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withValues(alpha:0.3),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Color(0xFF2ECC71),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Selected Day Exams
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSelectedDayExams(),
        ),
      ],
    );
  }

  Widget _buildSelectedDayExams() {
    final exams = _getEventsForDay(_selectedDay);

    if (exams.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No exams on ${DateFormat('MMMM d, yyyy').format(_selectedDay)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a date with exam markers to view scheduled examinations.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_rounded,
                    color: Color(0xFF2ECC71),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(_selectedDay),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        '${exams.length} exam${exams.length > 1 ? 's' : ''} scheduled',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exams.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              return _buildCalendarExamItem(exams[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarExamItem(ExamSubject exam) {
    final subjectColor = _getSubjectColor(exam.name);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  subjectColor.withValues(alpha:0.1),
                  subjectColor.withValues(alpha:0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSubjectIcon(exam.name),
              color: subjectColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exam.startTime.format(context)} - ${exam.endTime.format(context)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.room_rounded,
                      size: 14,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exam.roomNo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${exam.totalMarks} marks',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: subjectColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedExamCard(Exam exam) {
    final subjects = List<ExamSubject>.from(exam.subjects)
      ..sort((a, b) => a.date.compareTo(b.date));

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getExamTypeColor(exam.examType).withValues(alpha:0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getExamTypeColor(exam.examType).withValues(alpha:0.1),
                  _getExamTypeColor(exam.examType).withValues(alpha:0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getExamTypeColor(exam.examType).withValues(alpha:0.2),
                        _getExamTypeColor(exam.examType).withValues(alpha:0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getExamTypeIcon(exam.examType),
                    color: _getExamTypeColor(exam.examType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getExamTypeColor(exam.examType).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getExamTypeName(exam.examType),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getExamTypeColor(exam.examType),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
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

          // Subjects List as Column instead of ListView
          Column(
            children: [
              for (int i = 0; i < subjects.length; i++) ...[
                _buildEnhancedSubjectItem(subjects[i]),
                if (i < subjects.length - 1)
                  const Divider(height: 1, indent: 20, endIndent: 20),
              ],
            ],
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _downloadHallTicket(exam),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _getExamTypeColor(exam.examType)),
                      foregroundColor: _getExamTypeColor(exam.examType),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text(
                      'Hall Ticket',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewTimetable(exam),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getExamTypeColor(exam.examType),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: const Text(
                      'Timetable',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSubjectItem(ExamSubject subject) {
    final subjectColor = _getSubjectColor(subject.name);
    final daysLeft = subject.date.difference(DateTime.now()).inDays;
    final isToday = DateUtils.isSameDay(subject.date, DateTime.now());
    final isTomorrow = daysLeft == 1;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  subjectColor.withValues(alpha:0.1),
                  subjectColor.withValues(alpha:0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSubjectIcon(subject.name),
              color: subjectColor,
              size: 20,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEE, d MMM').format(subject.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${subject.startTime.format(context)} - \n${subject.endTime.format(context)}',
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
                      Icons.room_rounded,
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
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${subject.totalMarks} marks',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFFE74C3C).withValues(alpha:0.1)
                  : isTomorrow
                  ? const Color(0xFFFF9500).withValues(alpha:0.1)
                  : const Color(0xFF2ECC71).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isToday
                    ? const Color(0xFFE74C3C).withValues(alpha:0.3)
                    : isTomorrow
                    ? const Color(0xFFFF9500).withValues(alpha:0.3)
                    : const Color(0xFF2ECC71).withValues(alpha:0.3),
                width: 1,
              ),
            ),
            child: Text(
              isToday
                  ? 'TODAY'
                  : isTomorrow
                  ? 'TOMORROW'
                  : daysLeft < 0
                  ? 'PAST'
                  : '$daysLeft DAYS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isToday
                    ? const Color(0xFFE74C3C)
                    : isTomorrow
                    ? const Color(0xFFFF9500)
                    : daysLeft < 0
                    ? const Color(0xFF718096)
                    : const Color(0xFF2ECC71),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedResultCard(Exam exam) {
    final totalMarksObtained = exam.subjects
        .where((s) => s.marksObtained != null)
        .fold<int>(0, (sum, s) => sum + s.marksObtained!);
    final totalPossibleMarks = exam.subjects
        .where((s) => s.marksObtained != null)
        .fold<int>(0, (sum, s) => sum + s.totalMarks);
    final percentage = totalPossibleMarks > 0
        ? (totalMarksObtained / totalPossibleMarks) * 100
        : 0.0;
    final grade = _calculateGrade(percentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getGradeColor(grade).withValues(alpha:0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Header with Results
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getGradeColor(grade).withValues(alpha:0.1),
                  _getGradeColor(grade).withValues(alpha:0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getGradeColor(grade).withValues(alpha:0.2),
                            _getGradeColor(grade).withValues(alpha:0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.grade_rounded,
                        color: _getGradeColor(grade),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getExamTypeColor(exam.examType).withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getExamTypeName(exam.examType),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getExamTypeColor(exam.examType),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _getGradeColor(grade),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          grade,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Results Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildResultStat(
                        'Total Marks',
                        '$totalMarksObtained/$totalPossibleMarks',
                        const Color(0xFF4A90E2),
                      ),
                      _buildStatDivider(),
                      _buildResultStat(
                        'Percentage',
                        '${percentage.toStringAsFixed(1)}%',
                        _getGradeColor(grade),
                      ),
                      _buildStatDivider(),
                      _buildResultStat(
                        'Subjects',
                        '${exam.subjects.length}',
                        const Color(0xFF718096),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subject Results as Column instead of ListView
          Column(
            children: [
              for (int i = 0; i < exam.subjects.length; i++) ...[
                _buildEnhancedSubjectResult(exam.subjects[i]),
                if (i < exam.subjects.length - 1 && exam.subjects[i].marksObtained != null)
                  const Divider(height: 1, indent: 20, endIndent: 20),
              ],
            ],
          ),

          // Download Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadReportCard(exam),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getGradeColor(grade),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text(
                  'Download Report Card',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSubjectResult(ExamSubject subject) {
    if (subject.marksObtained == null) return const SizedBox();

    final subjectColor = _getSubjectColor(subject.name);
    final percentage = (subject.marksObtained! / subject.totalMarks) * 100;
    final grade = subject.grade ?? _calculateGrade(percentage);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  subjectColor.withValues(alpha:0.1),
                  subjectColor.withValues(alpha:0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSubjectIcon(subject.name),
              color: subjectColor,
              size: 20,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
                if (subject.remarks != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subject.remarks!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF58CC02),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${subject.marksObtained}/${subject.totalMarks}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getGradeColor(grade).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    fontSize: 12,
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
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
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

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  List<ExamSubject> _getEventsForDay(DateTime day) {
    List<ExamSubject> events = [];
    for (var exam in _exams) {
      for (var subject in exam.subjects) {
        if (DateUtils.isSameDay(subject.date, day)) {
          events.add(subject);
        }
      }
    }
    return events;
  }

  ExamSubject? _getNextExam() {
    final allSubjects = _exams
        .where((exam) => exam.status == ExamStatus.upcoming)
        .expand((exam) => exam.subjects)
        .where((subject) => subject.date.isAfter(DateTime.now()))
        .toList();

    if (allSubjects.isEmpty) return null;

    allSubjects.sort((a, b) => a.date.compareTo(b.date));
    return allSubjects.first;
  }

  String _getTimeUntilNextExam(ExamSubject nextExam) {
    final difference = nextExam.date.difference(DateTime.now());
    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) {
      return '$days Days Left';
    } else if (hours > 0) {
      return '$hours Hours Left';
    } else {
      return 'Starting Soon!';
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
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF718096);
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
      case 'history':
        return Icons.history_edu_rounded;
      case 'geography':
        return Icons.public_rounded;
      case 'computer science':
        return Icons.computer_rounded;
      default:
        return Icons.school_rounded;
    }
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
        return Icons.school_rounded;
      case ExamType.midTerm:
        return Icons.assignment_rounded;
      case ExamType.unit:
        return Icons.quiz_rounded;
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

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFF2ECC71);
      case 'B+':
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

  // Action Methods
  void _downloadHallTicket(Exam exam) {
    HapticFeedback.lightImpact();
    // Implement hall ticket download
  }

  void _viewTimetable(Exam exam) {
    HapticFeedback.lightImpact();
    // Implement timetable view
  }

  void _downloadReportCard(Exam exam) {
    HapticFeedback.lightImpact();
    // Implement report card download
  }

  void _showDownloadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Download Options',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.schedule_rounded, color: Color(0xFF4A90E2)),
              title: const Text('Exam Schedule'),
              subtitle: const Text('Download complete exam timetable'),
              trailing: const Icon(Icons.download_rounded),
              onTap: () {
                Navigator.pop(context);
                // Download schedule
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_rounded, color: Color(0xFF58CC02)),
              title: const Text('Hall Tickets'),
              subtitle: const Text('Download all available hall tickets'),
              trailing: const Icon(Icons.download_rounded),
              onTap: () {
                Navigator.pop(context);
                // Download hall tickets
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Data Models
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
  final String? grade;
  final String? remarks;
  final String? syllabus;
  final String? examType;

  // Add subject property for calendar integration
  String get subject => name;

  ExamSubject({
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.roomNo,
    required this.totalMarks,
    this.marksObtained,
    this.grade,
    this.remarks,
    this.syllabus,
    this.examType,
  });
}

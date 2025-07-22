import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _streakAnimationController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _statsScaleAnimation;
  late Animation<double> _streakPulseAnimation;

  // Enhanced mock data for attendance
  final Map<String, double> monthlyAttendance = {
    'Jan': 0.89,
    'Feb': 0.92,
    'Mar': 0.88,
    'Apr': 0.92,
    'May': 0.88,
    'Jun': 0.75,
    'Jul': 0.95,
    'Aug': 0.85,
    'Sep': 0.78,
    'Oct': 0.91,
    'Nov': 0.87,
    'Dec': 0.93,
  };

  // Enhanced attendance records with more details
  final List<AttendanceRecord> attendanceRecords = [
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
      checkInTime: '08:45',
      teacher: 'Mrs. Sharma',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
      checkInTime: '08:50',
      teacher: 'Mr. Kumar',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: AttendanceStatus.absent,
      subject: 'All Classes',
      reason: 'Medical Leave',
      teacher: 'Mrs. Patel',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 4)),
      status: AttendanceStatus.late,
      subject: 'All Classes',
      checkInTime: '09:15',
      reason: 'Traffic Delay',
      teacher: 'Dr. Singh',
    ),
    AttendanceRecord(
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: AttendanceStatus.present,
      subject: 'All Classes',
      checkInTime: '08:42',
      teacher: 'Mrs. Gupta',
    ),
  ];

  String _selectedMonth = DateFormat('MMM').format(DateTime.now());
  int _currentStreak = 7;
  int _totalDays = 22;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _streakAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Setup animations
    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _statsScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.elasticOut,
    ));

    _streakPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _streakAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _headerAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _statsAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _cardsAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    _cardsAnimationController.dispose();
    _streakAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendancePercentage = monthlyAttendance[_selectedMonth] ?? 0.0;
    final presentDays = (attendancePercentage * _totalDays).round();
    final absentDays = _totalDays - presentDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header (no animation)
            _buildEnhancedHeader(context, attendancePercentage),

            const SizedBox(height: 25),

            // Enhanced Statistics Cards (no animation)
            _buildEnhancedStatistics(
                context,
                presentDays,
                absentDays,
                attendancePercentage
            ),

            const SizedBox(height: 25),

            // Enhanced Month Selector
            _buildEnhancedMonthSelector(context),

            const SizedBox(height: 25),

            // Enhanced Attendance Calendar (no animation)
            _buildEnhancedAttendanceCalendar(context),

            const SizedBox(height: 25),

            // Enhanced Recent Activity (no animation)
            _buildEnhancedRecentActivity(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'My Attendance',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2D3748),
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
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          onPressed: () {
            // Show calendar picker
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, double attendancePercentage) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
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
                    Text(
                      '${DateFormat('MMMM yyyy').format(DateTime.now())}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${(attendancePercentage * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          attendancePercentage >= 0.85
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: attendancePercentage >= 0.85
                              ? const Color(0xFF58CC02)
                              : const Color(0xFFFF9500),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overall Attendance',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Enhanced Streak Badge
                    AnimatedBuilder(
                      animation: _streakPulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: _streakPulseAnimation.value,
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFFF9500),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_currentStreak Day Streak! 🔥',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Enhanced Progress Ring
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: attendancePercentage),
                duration: const Duration(milliseconds: 2000),
                builder: (context, value, child) {
                  return CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 12.0,
                    percent: value,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(value * 100).toInt()}%",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "$_totalDays days",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    progressColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 2000,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatistics(
      BuildContext context,
      int presentDays,
      int absentDays,
      double attendancePercentage,
      ) {
    final stats = [
      StatData(
        title: 'Present',
        value: presentDays.toString(),
        color: const Color(0xFF58CC02),
        icon: Icons.check_circle_rounded,
        subtitle: 'Days attended',
      ),
      StatData(
        title: 'Absent',
        value: absentDays.toString(),
        color: const Color(0xFFE74C3C),
        icon: Icons.cancel_rounded,
        subtitle: 'Days missed',
      ),
      StatData(
        title: 'Late',
        value: '3',
        color: const Color(0xFFFF9500),
        icon: Icons.schedule_rounded,
        subtitle: 'Late arrivals',
      ),
      StatData(
        title: 'Holidays',
        value: '4',
        color: const Color(0xFF8E44AD),
        icon: Icons.celebration_rounded,
        subtitle: 'School holidays',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return _buildEnhancedStatCard(stats[index]);
        },
      ),
    );
  }

  Widget _buildEnhancedStatCard(StatData stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stat.color.withOpacity(0.1),
                      stat.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  stat.icon,
                  color: stat.color,
                  size: 24,
                ),
              ),
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: stat.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            stat.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMonthSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Monthly Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: monthlyAttendance.keys.length,
            itemBuilder: (context, index) {
              final month = monthlyAttendance.keys.elementAt(index);
              final isSelected = month == _selectedMonth;
              final percentage = monthlyAttendance[month] ?? 0.0;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedMonth = month;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 75),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: isSelected ? 12 : 8,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        month,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF2D3748),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedAttendanceCalendar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Pattern',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedMonth,
                  style: const TextStyle(
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Calendar Grid
          _buildCalendarGrid(context),

          const SizedBox(height: 20),

          // Legend
          _buildAttendanceLegend(context),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 28, // Simplified to 4 weeks
      itemBuilder: (context, index) {
        final day = index + 1;
        final attendanceStatus = _getRandomAttendanceStatus(day);

        return Container(
          decoration: BoxDecoration(
            color: _getStatusColor(attendanceStatus).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getStatusColor(attendanceStatus).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                color: _getStatusColor(attendanceStatus),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Present', const Color(0xFF58CC02)),
        _buildLegendItem('Absent', const Color(0xFFE74C3C)),
        _buildLegendItem('Late', const Color(0xFFFF9500)),
        _buildLegendItem('Holiday', const Color(0xFF718096)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedRecentActivity(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                    fontSize: 18,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // View all activity
                  },
                  icon: const Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: Color(0xFF4A90E2),
                  ),
                  label: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendanceRecords.take(5).length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
            itemBuilder: (context, index) {
              final record = attendanceRecords[index];
              return _buildEnhancedAttendanceRecord(record);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAttendanceRecord(AttendanceRecord record) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(record.status).withOpacity(0.1),
                  _getStatusColor(record.status).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getStatusIcon(record.status),
              color: _getStatusColor(record.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM').format(record.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _getStatusText(record.status),
                      style: TextStyle(
                        color: _getStatusColor(record.status),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (record.checkInTime.isNotEmpty) ...[
                      Text(
                        ' • ${record.checkInTime}',
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
                if (record.reason.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    record.reason,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (record.teacher.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.teacher,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.person_rounded,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Helper methods
  AttendanceStatus _getRandomAttendanceStatus(int day) {
    if (day % 7 == 0 || day % 6 == 0) return AttendanceStatus.holiday;
    if (day % 8 == 0) return AttendanceStatus.absent;
    if (day % 5 == 0) return AttendanceStatus.late;
    return AttendanceStatus.present;
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF58CC02);
      case AttendanceStatus.absent:
        return const Color(0xFFE74C3C);
      case AttendanceStatus.late:
        return const Color(0xFFFF9500);
      case AttendanceStatus.holiday:
        return const Color(0xFF718096);
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
      case AttendanceStatus.late:
        return Icons.schedule_rounded;
      case AttendanceStatus.holiday:
        return Icons.celebration_rounded;
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.holiday:
        return 'Holiday';
    }
  }
}

// Enhanced data models
enum AttendanceStatus { present, absent, late, holiday }

class AttendanceRecord {
  final DateTime date;
  final AttendanceStatus status;
  final String subject;
  final String reason;
  final String checkInTime;
  final String teacher;

  AttendanceRecord({
    required this.date,
    required this.status,
    required this.subject,
    this.reason = '',
    this.checkInTime = '',
    this.teacher = '',
  });
}

class StatData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final String subtitle;

  const StatData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.subtitle,
  });
}

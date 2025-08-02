import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
  });

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

  // State variables for API data
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  DateTime _selectedDate = DateTime.now();
  List<AttendanceRecord> _todayAttendance = [];
  Map<String, double> _monthlyStats = {
    'totalDays': 0.0,
    'presentDays': 0.0,
    'attendancePercentage': 0.0,
  };

  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAttendanceData();
  }

  void _initializeAnimations() {
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

  Future<void> _loadAttendanceData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('=== LOADING ATTENDANCE DATA ===');
      print('Selected Date: $_selectedDate');

      // Format date for API call (dd-mm-yyyy)
      final dateString = DateFormat('dd-MM-yyyy').format(_selectedDate);
      print('Formatted Date String: $dateString');

      // Get today's attendance
      final attendanceResponse = await AttendanceService.getStudentAttendance(
        attDate: dateString,
      );

      if (attendanceResponse != null) {
        _todayAttendance = attendanceResponse.attendanceList;
        print('=== TODAY\'S ATTENDANCE LOADED ===');
        print('Records count: ${_todayAttendance.length}');
      } else {
        _todayAttendance = [];
        print('=== NO ATTENDANCE DATA FOR TODAY ===');
      }

      // Get monthly stats
      final monthlyStats = await AttendanceService.getMonthlyAttendanceStats(
        year: _selectedDate.year,
        month: _selectedDate.month,
      );

      _monthlyStats = monthlyStats;
      print('=== MONTHLY STATS LOADED ===');
      print('Monthly Stats: $_monthlyStats');

      // Calculate streak (simplified)
      _currentStreak = _calculateCurrentStreak();
      print('Current Streak: $_currentStreak days');

      setState(() {
        _isLoading = false;
        _hasError = false;
      });

    } catch (e) {
      print('=== ERROR LOADING ATTENDANCE DATA ===');
      print('Error: $e');

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load attendance data: $e';
      });
    }
  }

  int _calculateCurrentStreak() {
    // Simple streak calculation - count consecutive days with present status
    // You can enhance this logic based on your requirements
    return (_monthlyStats['presentDays'] ?? 0).toInt();
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
    final attendancePercentage = _monthlyStats['attendancePercentage'] ?? 0.0;
    final presentDays = (_monthlyStats['presentDays'] ?? 0).toInt();
    final totalDays = (_monthlyStats['totalDays'] ?? 0).toInt();
    final absentDays = totalDays - presentDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: _isLoading
          ? _buildLoadingWidget()
          : _hasError
          ? _buildErrorWidget()
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildEnhancedHeader(context, attendancePercentage),
            const SizedBox(height: 25),
            _buildEnhancedStatistics(
              context,
              presentDays,
              absentDays,
              attendancePercentage,
            ),
            // const SizedBox(height: 25),
            _buildDateSelector(context),
            const SizedBox(height: 25),
            _buildTodayAttendanceCard(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAttendanceData,
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading attendance data...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAttendanceData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'My Attendance',
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
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
              });
              _loadAttendanceData();
            }
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
                      DateFormat('MMMM yyyy').format(_selectedDate),
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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: attendancePercentage),
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
                          "${_monthlyStats['totalDays']?.toInt() ?? 0} days",
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
    final lateDays = _todayAttendance.where((record) =>
    record.attendanceStatus == AttendanceStatus.late).length;

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
        value: lateDays.toString(),
        color: const Color(0xFFFF9500),
        icon: Icons.schedule_rounded,
        subtitle: 'Late arrivals',
      ),
      StatData(
        title: 'Classes',
        value: _todayAttendance.length.toString(),
        color: const Color(0xFF8E44AD),
        icon: Icons.school_rounded,
        subtitle: 'Today\'s classes',
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

  Widget _buildDateSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Date',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                    _loadAttendanceData();
                  }
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text('Change Date'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: const Color(0xFF4A90E2),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                style: const TextStyle(
                  color: Color(0xFF4A90E2),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayAttendanceCard(BuildContext context) {
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
                  'Today\'s Classes',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _todayAttendance.isNotEmpty
                        ? const Color(0xFF58CC02).withOpacity(0.1)
                        : const Color(0xFF718096).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_todayAttendance.length} Classes',
                    style: TextStyle(
                      color: _todayAttendance.isNotEmpty
                          ? const Color(0xFF58CC02)
                          : const Color(0xFF718096),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _todayAttendance.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No classes found for this date',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try selecting a different date',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayAttendance.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFE2E8F0),
            ),
            itemBuilder: (context, index) {
              final record = _todayAttendance[index];
              return _buildAttendanceRecordCard(record);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRecordCard(AttendanceRecord record) {
    final statusColor = _getStatusColor(record.attendanceStatus);
    final statusIcon = _getStatusIcon(record.attendanceStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.1),
                  statusColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      record.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' • ${record.fromTime} - ${record.toTime}',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.fromTime,
                style: const TextStyle(
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'to ${record.toTime}',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods
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
}

// Data model for statistics
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

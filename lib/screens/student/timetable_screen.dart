import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:AES/constants/app_strings.dart';
import 'package:AES/services/timetable_service.dart';
import 'package:AES/widgets/custom_snackbar.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {

  List<TimetableRecord> _timetableRecords = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, List<TimetableRecord>> _groupedTimetable = {};
  String _selectedDay = DateFormat('EEEE').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('=== LOADING TIMETABLE ===');
      final records = await TimetableService.getStudentTimetable();
      debugPrint('=== TIMETABLE LOADED ===');
      debugPrint('Total records: ${records.length}');

      if (mounted) {
        setState(() {
          _timetableRecords = records;
          _groupedTimetable = _groupTimetableByDay(records);
          _isLoading = false;
        });

        debugPrint('=== GROUPED TIMETABLE ===');
        _groupedTimetable.forEach((day, records) {
          debugPrint('$day: ${records.length} records');
        });
      }
    } catch (e) {
      debugPrint('=== TIMETABLE LOAD ERROR ===');
      debugPrint('Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load timetable: $e';
          _isLoading = false;
        });
      }
    }
  }

  Map<String, List<TimetableRecord>> _groupTimetableByDay(List<TimetableRecord> records) {
    final Map<String, List<TimetableRecord>> grouped = {};
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    for (final day in days) {
      grouped[day] = [];
    }

    final sortedRecords = List<TimetableRecord>.from(records)
      ..sort((a, b) {
        if (a.dayIndex != b.dayIndex) {
          return a.dayIndex.compareTo(b.dayIndex);
        }
        return a.timeInMinutes.compareTo(b.timeInMinutes);
      });

    for (final record in sortedRecords) {
      if (grouped.containsKey(record.weekDay)) {
        grouped[record.weekDay]!.add(record);
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: _isLoading
          ? _buildLoadingWidget()
          : _errorMessage != null
          ? _buildErrorWidget()
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildEnhancedHeader(context),
            // const SizedBox(height: 25),
            // _buildWeeklyStats(context),
            const SizedBox(height: 25),
            _buildDaySelector(context),
            const SizedBox(height: 25),
            _buildTodaySchedule(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadTimetable,
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
            'Loading timetable...',
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
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadTimetable,
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
        'My Timetable',
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
              color: const Color(0xFF4A90E2).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          onPressed: _loadTimetable,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    final totalSubjects = _timetableRecords.length;
    final totalClasses = _groupedTimetable.values.fold(0, (sum, dayRecords) => sum + dayRecords.length);
    final activeDays = _groupedTimetable.values.where((dayRecords) => dayRecords.isNotEmpty).length;

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
            color: const Color(0xFF4A90E2).withValues(alpha:0.3),
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
                      _timetableRecords.isNotEmpty
                          ? '${_timetableRecords.first.className} - ${_timetableRecords.first.division}'
                          : 'Weekly Schedule',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '$totalClasses',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.school_rounded,
                          color: const Color(0xFF58CC02),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Classes This Week',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                            Icons.today_rounded,
                            color: Color(0xFFFF9500),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$activeDays Active Days 📚',
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalSubjects',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Subjects',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats(BuildContext context) {
    final totalClasses = _groupedTimetable.values.fold(0, (sum, dayRecords) => sum + dayRecords.length);
    final activeDays = _groupedTimetable.values.where((dayRecords) => dayRecords.isNotEmpty).length;
    final todayClasses = _groupedTimetable[_selectedDay]?.length ?? 0;
    final uniqueSubjects = _timetableRecords.map((r) => r.subject).toSet().length;

    final stats = [
      StatData(
        title: 'Total Classes',
        value: totalClasses.toString(),
        color: const Color(0xFF4A90E2),
        icon: Icons.school_rounded,
        subtitle: 'This week',
      ),
      StatData(
        title: 'Active Days',
        value: activeDays.toString(),
        color: const Color(0xFF58CC02),
        icon: Icons.today_rounded,
        subtitle: 'With classes',
      ),
      StatData(
        title: 'Today\'s Classes',
        value: todayClasses.toString(),
        color: const Color(0xFFFF9500),
        icon: Icons.schedule_rounded,
        subtitle: 'Scheduled',
      ),
      StatData(
        title: 'Subjects',
        value: uniqueSubjects.toString(),
        color: const Color(0xFF8E44AD),
        icon: Icons.book_rounded,
        subtitle: 'Total subjects',
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
            color: stat.color.withValues(alpha:0.08),
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
                      stat.color.withValues(alpha:0.1),
                      stat.color.withValues(alpha:0.05),
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

  Widget _buildDaySelector(BuildContext context) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Select Day',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = day == _selectedDay;
              final hasClasses = (_groupedTimetable[day]?.length ?? 0) > 0;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : hasClasses
                            ? const Color(0xFF4A90E2).withValues(alpha:0.3)
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF4A90E2).withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.substring(0, 3),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : hasClasses
                                ? const Color(0xFF4A90E2)
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (hasClasses) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF58CC02),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySchedule(BuildContext context) {
    final dayRecords = _groupedTimetable[_selectedDay] ?? [];

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
                  '$_selectedDay Schedule',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: dayRecords.isNotEmpty
                        ? const Color(0xFF4A90E2).withValues(alpha:0.1)
                        : const Color(0xFF718096).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${dayRecords.length} Classes',
                    style: TextStyle(
                      color: dayRecords.isNotEmpty
                          ? const Color(0xFF4A90E2)
                          : const Color(0xFF718096),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          dayRecords.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy_rounded,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No classes scheduled',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enjoy your free day!',
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
            itemCount: dayRecords.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: Color(0xFFE2E8F0),
            ),
            itemBuilder: (context, index) {
              return _buildEnhancedTimetableCard(dayRecords[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTimetableCard(TimetableRecord record) {
    final subjectColor = _getSubjectColor(record.subject);
    final subjectIcon = _getSubjectIcon(record.subject);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              subjectIcon,
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
                  record.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.teacherName,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: subjectColor.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.subType,
                        style: TextStyle(
                          fontSize: 10,
                          color: subjectColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.batch,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF4A5568),
                          fontWeight: FontWeight.w500,
                        ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: subjectColor.withValues(alpha:0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      record.fromTime,
                      style: TextStyle(
                        color: subjectColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      record.toTime,
                      style: TextStyle(
                        color: subjectColor.withValues(alpha:0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods (same as before)
  Color _getSubjectColor(String subject) {
    final colors = [
      const Color(0xFFE74C3C), // Red
      const Color(0xFF2ECC71), // Green
      const Color(0xFFF39C12), // Orange
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF4A90E2), // Blue
      const Color(0xFF1ABC9C), // Teal
      const Color(0xFFE67E22), // Dark Orange
      const Color(0xFF34495E), // Dark Blue
    ];
    final index = subject.hashCode % colors.length;
    return colors[index];
  }

  IconData _getSubjectIcon(String subject) {
    final subjectLower = subject.toLowerCase();
    if (subjectLower.contains('math')) return Icons.functions;
    if (subjectLower.contains('science')) return Icons.science;
    if (subjectLower.contains('english')) return Icons.language;
    if (subjectLower.contains('history')) return Icons.history_edu;
    if (subjectLower.contains('geography')) return Icons.public;
    if (subjectLower.contains('physics')) return Icons.science;
    if (subjectLower.contains('chemistry')) return Icons.science;
    if (subjectLower.contains('biology')) return Icons.biotech;
    if (subjectLower.contains('computer')) return Icons.computer;
    if (subjectLower.contains('art')) return Icons.palette;
    if (subjectLower.contains('music')) return Icons.music_note;
    if (subjectLower.contains('physical') || subjectLower.contains('pe')) return Icons.sports_soccer;
    if (subjectLower.contains('study')) return Icons.menu_book;
    return Icons.school;
  }
}

// Data model for statistics (same as attendance screen)
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

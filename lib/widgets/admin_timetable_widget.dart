import 'package:flutter/material.dart';
import 'package:dps/services/admin_timetable_service.dart';

class AdminTimetableWidget extends StatefulWidget {
  const AdminTimetableWidget({super.key});

  @override
  State createState() => _AdminTimetableWidgetState();
}

class _AdminTimetableWidgetState extends State<AdminTimetableWidget> {
  List _teacherTimetables = [];
  bool _isLoading = true;
  TeacherTimetableData? _selectedTeacher;
  String _selectedDay = 'Monday';
  DateTime _baseDate = DateTime.now();

  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _loadTeacherTimetables();
  }

  Future<void> _loadTeacherTimetables() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final timetables = await AdminTimetableService.getTeacherTimetables();
      setState(() {
        _teacherTimetables = timetables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getDateForDay(String day) {
    int dayIndex = _weekDays.indexOf(day);
    return _baseDate.day + dayIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with back button and Add Task button
          _buildHeader(),
          // Day selector
          _buildDaySelector(),
          // Teacher info
          if (_selectedTeacher != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTeacher!.teacherName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedTeacher!.timetables.length} classes scheduled',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
              ),
            )
                : _teacherTimetables.isEmpty
                ? _buildEmptyState()
                : _buildTimelineView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
                               // Teacher selector
          if (_teacherTimetables.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxWidth: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TeacherTimetableData>(
                  value: _selectedTeacher,
                  hint: const Text(
                    'Select Teacher',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  dropdownColor: const Color(0xFF6366F1),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                  items: _teacherTimetables.cast<TeacherTimetableData>().map((teacher) {
                    return DropdownMenuItem<TeacherTimetableData>(
                      value: teacher,
                      child: Text(
                        teacher.teacherName,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (TeacherTimetableData? value) {
                    setState(() {
                      _selectedTeacher = value;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _weekDays.map((day) {
          final isSelected = day == _selectedDay;
          final dayDate = _getDateForDay(day);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
            },
            child: Column(
              children: [
                Text(
                  day.substring(0, 3),
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.black87 : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$dayDate',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: Color(0xFFCBD5E0),
          ),
          SizedBox(height: 16),
          Text(
            'No tasks scheduled',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first task to get started',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    if (_selectedTeacher == null && _teacherTimetables.isNotEmpty) {
      setState(() {
        _selectedTeacher = _teacherTimetables.first;
      });
    }

    if (_selectedTeacher == null) {
      return _buildEmptyState();
    }

    final teacher = _selectedTeacher!;
    final dayTimetables = teacher.timetables
        .where((entry) => entry.weekDay == _selectedDay)
        .toList()
      ..sort((a, b) => a.fromTime.compareTo(b.fromTime));

    if (dayTimetables.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: dayTimetables.length,
      itemBuilder: (context, index) {
        final entry = dayTimetables[index];
        final isLast = index == dayTimetables.length - 1;
        return _buildTimelineItem(entry, isLast);
      },
    );
  }

  Widget _buildTimelineItem(TimetableEntry entry, bool isLast) {
    final color = _getSubjectColor(entry.subject);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: color.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Task card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.subject,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(entry.fromTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${entry.className} ${entry.division} • ${entry.subType}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getSubjectColor(String subject) {
    final colors = [
      const Color(0xFFEF4444), // Red
      const Color(0xFF6366F1), // Blue
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFF10B981), // Green
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF97316), // Orange
    ];
    final index = subject.hashCode.abs() % colors.length;
    return colors[index];
  }

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];

      if (hour == 0) {
        return '12:$minute AM';
      } else if (hour < 12) {
        return '$hour:$minute AM';
      } else if (hour == 12) {
        return '12:$minute PM';
      } else {
        return '${hour - 12}:$minute PM';
      }
    } catch (e) {
      return time24;
    }
  }
}

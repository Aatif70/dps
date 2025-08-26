import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

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
        // Automatically select the first teacher if available
        if (timetables.isNotEmpty) {
          _selectedTeacher = timetables.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  List<DateTime> _getEventDays() {
    if (_selectedTeacher == null) return [];
    final teacher = _selectedTeacher!;
    final eventDays = <DateTime>[];
    
    // Get the current week's dates
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dayName = _getDayName(date);
      final hasClasses = teacher.timetables.any((entry) => entry.weekDay == dayName);
      if (hasClasses) {
        eventDays.add(date);
      }
    }
    
    return eventDays;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  List<TimetableEntry> _getClassesForDay(DateTime date) {
    if (_selectedTeacher == null) return [];
    final dayName = _getDayName(date);
    return _selectedTeacher!.timetables
        .where((entry) => entry.weekDay == dayName)
        .toList()
      ..sort((a, b) => a.fromTime.compareTo(b.fromTime));
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
          // Calendar
          _buildCalendar(),
          // Selected date info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDayName(_selectedDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      if (_selectedTeacher != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_getClassesForDay(_selectedDate).length} classes scheduled',
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
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
          // IconButton(
          //   onPressed: () => Navigator.of(context).pop(),
          //   icon: const Icon(Icons.arrow_back_ios, color: Colors.black54, size: 20),
          //   padding: EdgeInsets.zero,
          //   constraints: const BoxConstraints(),
          // ),
          // const Spacer(),
                               // Teacher selector
          if (_teacherTimetables.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxWidth: 330),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TeacherTimetableData>(
                  value: _selectedTeacher,
                  hint: const Text(
                    'Select Teacher',
                    style: TextStyle(color: Colors.deepPurple, fontSize: 14),
                  ),
                  dropdownColor: Colors.grey.shade50,
                  // dropdownColor: const Color(0xFF6366F1),

                  style: const TextStyle(color: Colors.black38, fontSize: 14,),

                  // icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                  items: _teacherTimetables.cast<TeacherTimetableData>().map((teacher) {
                    return DropdownMenuItem<TeacherTimetableData>(
                      value: teacher,
                      child: Text(
                        teacher.teacherName,
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (TeacherTimetableData? value) {
                    setState(() {
                      _selectedTeacher = value;
                      // Refresh calendar to show new teacher's schedule
                      _focusedDate = _focusedDate;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white38),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDate,
        calendarFormat: _calendarFormat,
        availableGestures: AvailableGestures.horizontalSwipe,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        rowHeight: 45,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDate = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDate = focusedDay;
          });
        },
        eventLoader: (day) {
          final dayName = _getDayName(day);
          if (_selectedTeacher != null) {
            final hasClasses = _selectedTeacher!.timetables.any((entry) => entry.weekDay == dayName);
            if (hasClasses) {
              print('Calendar: Found classes for $dayName (${day.day}/${day.month})');
            }
            return hasClasses ? [day] : [];
          }
          return [];
        },
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Color(0xFF718096)),
          selectedDecoration: BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFF58CC02),
            shape: BoxShape.circle,
          ),
          defaultDecoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          cellMargin: EdgeInsets.all(2),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF6366F1)),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF6366F1)),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
          defaultBuilder: (context, day, focusedDay) {
            final dayName = _getDayName(day);
            final hasClasses = _selectedTeacher != null && 
                _selectedTeacher!.timetables.any((entry) => entry.weekDay == dayName);
            
            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasClasses ? const Color(0xFF6366F1).withOpacity(0.1) : Colors.transparent,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: hasClasses ? const Color(0xFF6366F1) : null,
                    fontWeight: hasClasses ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
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
            'No class scheduled',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your classes to get started',
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
    if (_selectedTeacher == null) {
      return _buildEmptyState();
    }

    final teacher = _selectedTeacher!;
    final dayTimetables = _getClassesForDay(_selectedDate);

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
                color: color.withValues(alpha: 0.3),
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
                  color: color.withValues(alpha: 0.3),
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
                    color: Colors.white.withValues(alpha: 0.9),
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

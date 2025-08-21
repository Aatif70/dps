import 'package:flutter/material.dart';
import 'package:dps/services/admin_timetable_service.dart';

class AdminTimetableWidget extends StatefulWidget {
  const AdminTimetableWidget({super.key});

  @override
  State<AdminTimetableWidget> createState() => _AdminTimetableWidgetState();
}

class _AdminTimetableWidgetState extends State<AdminTimetableWidget> {
  List<TeacherTimetableData> _teacherTimetables = [];
  bool _isLoading = true;
  TeacherTimetableData? _selectedTeacher;

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
      print('Error loading teacher timetables: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 700, // Fixed height to provide constraints
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF6C5CE7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Teacher Timetables',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_teacherTimetables.isNotEmpty)
                  Text(
                    '${_teacherTimetables.length} Teachers',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Flexible(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                    ),
                  )
                : _teacherTimetables.isEmpty
                    ? _buildEmptyState()
                    : _buildTimetableContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: Color(0xFFCBD5E0),
          ),
          SizedBox(height: 16),
          Text(
            'No teacher timetables available',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Timetables will appear here once added',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Teacher selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Teacher',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TeacherTimetableData>(
                    value: _selectedTeacher,
                    hint: const Text(
                      'Choose a teacher...',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    items: _teacherTimetables.map((teacher) {
                      return DropdownMenuItem<TeacherTimetableData>(
                        value: teacher,
                        child: Text(
                          teacher.teacherName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E293B),
                          ),
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
        ),
        
        // Timetable display
        Flexible(
          child: _selectedTeacher == null
              ? _buildNoTeacherSelected()
              : _buildTeacherTimetable(),
        ),
      ],
    );
  }

  Widget _buildNoTeacherSelected() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 48,
            color: Color(0xFFCBD5E0),
          ),
          SizedBox(height: 16),
          Text(
            'Select a teacher to view timetable',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherTimetable() {
    final teacher = _selectedTeacher!;
    final weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    // Group timetables by weekday
    final timetablesByDay = <String, List<TimetableEntry>>{};
    for (final day in weekDays) {
      timetablesByDay[day] = teacher.timetables
          .where((entry) => entry.weekDay == day)
          .toList()
        ..sort((a, b) => a.fromTime.compareTo(b.fromTime));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Teacher info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF6C5CE7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.teacherName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${teacher.timetables.length} classes scheduled',
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
        
        const SizedBox(height: 16),
        
        // Timetable
        Flexible(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              final day = weekDays[index];
              final dayTimetables = timetablesByDay[day] ?? [];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getDayIcon(day),
                            color: const Color(0xFF6C5CE7),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF6C5CE7),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${dayTimetables.length} classes',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Classes
                    if (dayTimetables.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No classes scheduled',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dayTimetables.length,
                        itemBuilder: (context, classIndex) {
                          final entry = dayTimetables[classIndex];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: classIndex < dayTimetables.length - 1
                                      ? const Color(0xFFE2E8F0)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Time
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${entry.fromTime} - ${entry.toTime}',
                                    style: const TextStyle(
                                      color: Color(0xFF2ECC71),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Subject and class info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.subject,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${entry.className} ${entry.division} • ${entry.subType}',
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Course info
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFD79A8).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    entry.courseName,
                                    style: const TextStyle(
                                      color: Color(0xFFFD79A8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getDayIcon(String day) {
    switch (day) {
      case 'Monday':
        return Icons.calendar_view_week;
      case 'Tuesday':
        return Icons.calendar_view_week;
      case 'Wednesday':
        return Icons.calendar_view_week;
      case 'Thursday':
        return Icons.calendar_view_week;
      case 'Friday':
        return Icons.calendar_view_week;
      case 'Saturday':
        return Icons.calendar_view_week;
      default:
        return Icons.calendar_today;
    }
  }
}

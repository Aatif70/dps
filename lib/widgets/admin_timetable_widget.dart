import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:AES/services/admin_timetable_service.dart';
import 'package:AES/widgets/custom_snackbar.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      try {
        debugPrint('👥 Header dropdown teachers: ${_teacherTimetables.length}');
        for (int i = 0; i < _teacherTimetables.length; i++) {
          final t = _teacherTimetables[i] as TeacherTimetableData;
          debugPrint('   - [$i] EmpId=${t.empId}, Name=${t.teacherName}, classes=${t.timetables.length}');
        }
      } catch (_) {}
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                color: const Color(0xFF6366F1).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6366F1).withValues(alpha:0.2)),
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
            // Content (no Expanded so the whole page can scroll)
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
                    ),
                  )
                : _teacherTimetables.isEmpty
                    ? _buildEmptyState()
                    : _buildTimelineView(),
          ],
        ),
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
            Expanded(
              child: Container(
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
                    isExpanded: true,
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
            ),
          const SizedBox(width: 12),
          Flexible(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: _openAddTimetableSheet,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.add),
                label: const FittedBox(child: Text('Add Timetable')),
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
            color: Colors.purple.withValues(alpha:0.05),
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
              debugPrint('Calendar: Found classes for $dayName (${day.day}/${day.month})');
            }
            return hasClasses ? [day] : [];
          }
          return [];
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: Color(0xFF718096)),
          // Minimal ring for selected and today (no solid fill)
          selectedDecoration: BoxDecoration(
            shape: BoxShape.circle,
            // color: Colors.transparent,
                        color: Color(0xFF6366F1),

            border: Border.all(color: const Color(0xFF6366F1), width: 1.5),
          ),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
                        color: Color(0xFF58CC02),

            border: Border.all(color: const Color(0xFF58CC02), width: 1.5),
          ),
          defaultDecoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          cellMargin: const EdgeInsets.all(2),
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
                bottom: 6,
                child: Container(
                  width: 4,
                  height: 4,
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: hasClasses ? const Color(0xFF2D3748) : null,
                    fontWeight: FontWeight.w500,
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: color.withValues(alpha: 0.25),
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

  void _openAddTimetableSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: _AddTimetableForm(
            onSubmitted: (result) async {
              Navigator.of(ctx).pop();
              // reload and set selected teacher
              await _loadTeacherTimetables();
              if (result.empId != null) {
                TeacherTimetableData? match;
                try {
                  match = _teacherTimetables
                      .cast<TeacherTimetableData>()
                      .firstWhere((t) => t.empId == result.empId);
                } catch (_) {
                  match = null;
                }
                if (match != null) {
                  setState(() {
                    _selectedTeacher = match;
                  });
                }
              }
            },
          ),
        );
      },
    );
  }
}

class _AddTimetableResult {
  final int? empId;
  _AddTimetableResult({required this.empId});
}

class _AddTimetableForm extends StatefulWidget {
  final void Function(_AddTimetableResult) onSubmitted;
  const _AddTimetableForm({required this.onSubmitted});

  @override
  State<_AddTimetableForm> createState() => _AddTimetableFormState();
}

class _AddTimetableFormState extends State<_AddTimetableForm> {
  // Spacing constants to keep the layout rhythm consistent
  static const double _fieldGap = 16;
  static const double _sectionGap = 20;
  EmployeeItem? _selectedEmployee;
  ClassMasterItem? _selectedClass;
  BatchItem? _selectedBatch;
  DivisionItem? _selectedDivision;
  String? _selectedWeekday;
  SubjectItem? _selectedSubject;
  SubjectTypeItem? _selectedSubjectType;
  String? _fromTime;
  String? _toTime;

  bool _loadingEmployees = false;
  bool _loadingClasses = false;
  bool _loadingBatches = false;
  bool _loadingDivisions = false;
  bool _loadingSubjects = false;
  bool _loadingSubjectTypes = false;
  bool _submitting = false;

  List<EmployeeItem> _employees = [];
  List<ClassMasterItem> _classes = [];
  List<BatchItem> _batches = [];
  List<DivisionItem> _divisions = [];
  List<SubjectItem> _subjects = [];
  List<SubjectTypeItem> _subjectTypes = [];

  final List<String> _weekdays = const ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  // Time selection is now via native picker

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loadingEmployees = true);
    final data = await AdminTimetableService.getEmployees();
    setState(() {
      _employees = data;
      _loadingEmployees = false;
    });
  }

  Future<void> _onEmployeeChanged(EmployeeItem? emp) async {
    setState(() {
      _selectedEmployee = emp;
      _selectedClass = null;
      _selectedBatch = null;
      _selectedDivision = null;
      _selectedSubject = null;
      _selectedSubjectType = null;
      _classes = [];
      _batches = [];
      _divisions = [];
      _subjects = [];
      _subjectTypes = [];
    });
    if (emp == null) return;
    setState(() => _loadingClasses = true);
    final cls = await AdminTimetableService.getClassesByEmployee(emp.empId);
    setState(() {
      _classes = cls;
      _loadingClasses = false;
    });
  }

  Future<void> _onClassChanged(ClassMasterItem? cls) async {
    setState(() {
      _selectedClass = cls;
      _selectedBatch = null;
      _selectedDivision = null;
      _selectedSubject = null;
      _selectedSubjectType = null;
      _batches = [];
      _divisions = [];
      _subjects = [];
      _subjectTypes = [];
    });
    if (cls == null || _selectedEmployee == null) return;
    setState(() { _loadingBatches = true; _loadingSubjects = true; });
    final batchesF = AdminTimetableService.getBatchesByEmployeeAndClass(_selectedEmployee!.empId, cls.classMasterId);
    final subsF = AdminTimetableService.getSubjectsByClassMasterAndEmployee(cls.classMasterId, _selectedEmployee!.empId);
    final results = await Future.wait([batchesF, subsF]);
    setState(() {
      _batches = (results[0] as List<BatchItem>);
      _subjects = (results[1] as List<SubjectItem>);
      _loadingBatches = false;
      _loadingSubjects = false;
    });
  }

  Future<void> _onBatchChanged(BatchItem? batch) async {
    setState(() {
      _selectedBatch = batch;
      _selectedDivision = null;
      _divisions = [];
    });
    if (batch == null) return;
    setState(() { _loadingDivisions = true; });
    final divs = await AdminTimetableService.getDivisionsByClassId(batch.classId);
    setState(() {
      _divisions = divs;
      _loadingDivisions = false;
      debugPrint('Divisions loaded: ${_divisions.map((d) => d.divName).toList()}');
    });
  }

  Future<void> _onSubjectChanged(SubjectItem? sub) async {
    setState(() {
      _selectedSubject = sub;
      _selectedSubjectType = null;
      _subjectTypes = [];
    });
    if (sub == null) return;
    setState(() => _loadingSubjectTypes = true);
    final types = await AdminTimetableService.getSubjectTypesBySubject(sub.subjectId);
    setState(() {
      _subjectTypes = types;
      _loadingSubjectTypes = false;
    });
  }

  Future<void> _submit() async {
    if (_selectedEmployee == null ||
        _selectedClass == null ||
        _selectedBatch == null ||
        _selectedDivision == null ||
        _selectedWeekday == null ||
        _selectedSubject == null ||
        _selectedSubjectType == null ||
        _fromTime == null ||
        _toTime == null) {
      CustomSnackbar.showWarning(context, message: 'Please fill all fields.');
      return;
    }
    // Ensure From < To
    if (_fromTime == _toTime || (_fromTime ?? '')!.compareTo(_toTime ?? '') >= 0) {
      CustomSnackbar.showError(context, message: 'Please select a valid time range.');
      return;
    }
    setState(() => _submitting = true);
    final res = await AdminTimetableService.addTimetable(
      classId: _selectedClass!.classMasterId,
      batchId: _selectedBatch!.classId,
      divisionId: _selectedDivision!.divisionId,
      empId: _selectedEmployee!.empId,
      weekDay: _selectedWeekday!,
      subId: _selectedSubject!.subjectId,
      fromTime: _fromTime!,
      toTime: _toTime!,
      subTypeId: _selectedSubjectType!.subTypeId,
    );
    setState(() => _submitting = false);
    if (res['success'] == true) {
      CustomSnackbar.showSuccess(context, message: 'Timetable added successfully.');
      widget.onSubmitted(_AddTimetableResult(empId: _selectedEmployee!.empId));
    } else {
      CustomSnackbar.showError(context, message: res['message']?.toString() ?? 'Failed to add timetable.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.schedule, color: Color(0xFF2D3748)),
              SizedBox(width: 8),
              Text('Add Timetable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
            ],
          ),
          const SizedBox(height: _sectionGap),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 6)),
              ],
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEmployeeDropdown(),
                const SizedBox(height: _fieldGap),
                _buildClassDropdown(),
                const SizedBox(height: _fieldGap),
                _buildBatchDivisionRow(),
                const SizedBox(height: _fieldGap),
                _buildWeekdayDropdown(),
                const SizedBox(height: _fieldGap),
                _buildSubjectDropdown(),
                const SizedBox(height: _fieldGap),
                _buildSubjectTypeDropdown(),
                const SizedBox(height: _fieldGap),
                _buildTimePickers(),
              ],
            ),
          ),
          const SizedBox(height: _sectionGap),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: const Text('Save Timetable'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildEmployeeDropdown() {
    return InputDecorator(
      decoration: _fieldDecoration('Teacher'),
      child: _loadingEmployees
          ? const SizedBox(height: 24, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButton<EmployeeItem>(
                value: _selectedEmployee,
                hint: const Text('Select Teacher'),
                isExpanded: true,
                items: _employees
                    .where((e) => (e.designationName.toLowerCase().contains('teacher')))
                    .map((e) => DropdownMenuItem<EmployeeItem>(
                          value: e,
                          child: Text(e.name),
                        ))
                    .toList(),
                onChanged: _onEmployeeChanged,
              ),
            ),
    );
  }

  Widget _buildClassDropdown() {
    return InputDecorator(
      decoration: _fieldDecoration('Class', icon: Icons.school),
      child: _loadingClasses
          ? SizedBox(
              height: 40,
              child: Row(
                children: const [
                  SizedBox(width: 4),
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Loading classes...')),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<ClassMasterItem>(
                value: _selectedClass,
                hint: const Text('Select Class'),
                isExpanded: true,
                items: _classes
                    .map((c) => DropdownMenuItem<ClassMasterItem>(
                          value: c,
                          child: Text(c.className),
                        ))
                    .toList(),
                onChanged: _onClassChanged,
              ),
            ),
    );
  }

  Widget _buildBatchDropdown() {
    return InputDecorator(
      decoration: _fieldDecoration('Batch', icon: Icons.calendar_month),
      child: _loadingBatches
          ? SizedBox(
              height: 40,
              child: Row(
                children: const [
                  SizedBox(width: 4),
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Loading batches...')),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<BatchItem>(
                value: _selectedBatch,
                hint: const Text('Select Batch'),
                isExpanded: true,
                items: _batches
                    .map((b) => DropdownMenuItem<BatchItem>(
                          value: b,
                          child: Text(b.batchName.isNotEmpty ? b.batchName : 'Batch ${b.courseYear}'),
                        ))
                    .toList(),
                onChanged: _onBatchChanged,
              ),
            ),
    );
  }

  Widget _buildDivisionDropdown() {
    return InputDecorator(
      decoration: _fieldDecoration('Division', icon: Icons.group),
      child: _loadingDivisions
          ? SizedBox(
              height: 40,
              child: Row(
                children: const [
                  SizedBox(width: 4),
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Loading divisions...')),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<DivisionItem>(
                value: _selectedDivision,
                hint: const Text('Select Division'),
                isExpanded: true,
                items: _divisions
                    .map((d) => DropdownMenuItem<DivisionItem>(
                          value: d,
                          child: Text(d.divName),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedDivision = val),
              ),
            ),
    );
  }

  Widget _buildWeekdayDropdown() {
    return InputDecorator(
      decoration: _fieldDecoration('Weekday', icon: Icons.event),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWeekday,
          hint: const Text('Select Weekday'),
          isExpanded: true,
          items: _weekdays.map((d) => DropdownMenuItem<String>(value: d, child: Text(d))).toList(),
          onChanged: (val) => setState(() => _selectedWeekday = val),
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return InputDecorator(
      decoration: _fieldDecoration('Subject', icon: Icons.menu_book),
      child: _loadingSubjects
          ? SizedBox(
              height: 40,
              child: Row(
                children: const [
                  SizedBox(width: 4),
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Loading subjects...')),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<SubjectItem>(
                value: _selectedSubject,
                hint: const Text('Select Subject'),
                isExpanded: true,
                items: _subjects
                    .map((s) => DropdownMenuItem<SubjectItem>(
                          value: s,
                          child: Text(s.subjectName),
                        ))
                    .toList(),
                onChanged: _onSubjectChanged,
              ),
            ),
    );
  }

  Widget _buildSubjectTypeDropdown() {
    return InputDecorator(
      decoration: _fieldDecoration('Subject Type', icon: Icons.category),
      child: _loadingSubjectTypes
          ? SizedBox(
              height: 40,
              child: Row(
                children: const [
                  SizedBox(width: 4),
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Loading subject types...')),
                ],
              ),
            )
          : DropdownButtonHideUnderline(
              child: DropdownButton<SubjectTypeItem>(
                value: _selectedSubjectType,
                hint: const Text('Select Subject Type'),
                isExpanded: true,
                items: _subjectTypes
                    .map((st) => DropdownMenuItem<SubjectTypeItem>(
                          value: st,
                          child: Text(st.subTypeName),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedSubjectType = val),
              ),
            ),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await _pickTime(context, initial: _fromTime);
              if (picked != null) setState(() => _fromTime = picked);
            },
            child: InputDecorator(
              decoration: _fieldDecoration('From Time', icon: Icons.access_time),
              child: Text(_fromTime ?? 'Select From', style: TextStyle(color: _fromTime == null ? Colors.grey.shade600 : Colors.black)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await _pickTime(context, initial: _toTime);
              if (picked != null) setState(() => _toTime = picked);
            },
            child: InputDecorator(
              decoration: _fieldDecoration('To Time', icon: Icons.access_time_filled),
              child: Text(_toTime ?? 'Select To', style: TextStyle(color: _toTime == null ? Colors.grey.shade600 : Colors.black)),
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _pickTime(BuildContext context, {String? initial}) async {
    TimeOfDay initialTime;
    try {
      if (initial != null && initial.contains(':')) {
        final parts = initial.split(':');
        initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } else {
        initialTime = const TimeOfDay(hour: 9, minute: 0);
      }
    } catch (_) {
      initialTime = const TimeOfDay(hour: 9, minute: 0);
    }
    final picked = await showTimePicker(context: context, initialTime: initialTime, builder: (ctx, child) {
      return MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      );
    });
    if (picked == null) return null;
    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF718096), size: 20) : null,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      fillColor: const Color(0xFFF8F9FA),
      filled: true,
    );
  }

  Widget _buildBatchDivisionRow() {
    return Row(
      children: [
        Expanded(child: _buildBatchDropdown()),
        const SizedBox(width: 12),
        Expanded(child: _buildDivisionDropdown()),
      ],
    );
  }
}

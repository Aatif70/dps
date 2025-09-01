import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/calendar_service.dart';

class AdminEventCalendarWidget extends StatefulWidget {
  const AdminEventCalendarWidget({Key? key}) : super(key: key);

  @override
  State<AdminEventCalendarWidget> createState() => _AdminEventCalendarWidgetState();
}

class _AdminEventCalendarWidgetState extends State<AdminEventCalendarWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  // Events Calendar
  bool _isLoading = true;
  List<EventData> _allEvents = [];
  List<EventData> _filteredEvents = [];
  Set<String> _selectedFilters = {'event', 'holiday', 'exam'};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Annual Calendar
  AnnualCalendarData? _annualCalendar;
  int _selectedYear = DateTime.now().year;
  DateTime _annualFocusedDay = DateTime.now();
  DateTime? _annualSelectedDay;
  CalendarFormat _annualCalendarFormat = CalendarFormat.month;
  Set<String> _annualSelectedFilters = {'event', 'holiday', 'exam'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = DateTime.now();
    _annualSelectedDay = DateTime.now();
    _initializeAnimation();
    _loadData();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        CalendarService.getEvents(),
        CalendarService.getAnnualCalendar(_selectedYear),
      ]);
      _allEvents = results[0] as List<EventData>;
      _applyFilters();
      _annualCalendar = results[1] as AnnualCalendarData;
    } catch (e) {
      // handle error
    }
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    _filteredEvents = _allEvents
        .where((event) => _selectedFilters.contains(_eventType(event)))
        .toList();
    setState(() {});
  }

  void _toggleFilter(String type) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedFilters.contains(type)) {
        _selectedFilters.remove(type);
      } else {
        _selectedFilters.add(type);
      }
      _applyFilters();
    });
  }

  void _toggleAnnualFilter(String type) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_annualSelectedFilters.contains(type)) {
        _annualSelectedFilters.remove(type);
      } else {
        _annualSelectedFilters.add(type);
      }
    });
  }

  String _eventType(EventData event) {
    // Guess type by name or class (customize as needed)
    if (event.eventName.toLowerCase().contains('holiday')) return 'holiday';
    if (event.eventName.toLowerCase().contains('exam')) return 'exam';
    return 'event';
  }

  String _calendarItemType(CalendarItem item) {
    // Guess type by title (customize as needed)
    if (item.title.toLowerCase().contains('holiday')) return 'holiday';
    if (item.title.toLowerCase().contains('exam')) return 'exam';
    return 'event';
  }

  List<EventData> _getEventsForDay(DateTime day) {
    return _filteredEvents.where((event) =>
      event.startDate.year == day.year &&
      event.startDate.month == day.month &&
      event.startDate.day == day.day
    ).toList();
  }

  List<CalendarItem> _getAnnualEventsForDay(DateTime day) {
    if (_annualCalendar == null) return [];
    final allEvents = [
      ..._annualCalendar!.holidays,
      ..._annualCalendar!.events,
      ..._annualCalendar!.exams,
    ];
    return allEvents.where((event) =>
      _annualSelectedFilters.contains(_calendarItemType(event)) &&
      event.start.year == day.year &&
      event.start.month == day.month &&
      event.start.day == day.day
    ).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarHeader(),
                _buildTabBar(),
                const SizedBox(height: 10),
                SizedBox(
                  height: 480,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          children: [
                            _buildEventsTab(),
                            _buildAnnualTab(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'School Calendar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_filteredEvents.length} events this year',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: -18, vertical: 12),
        dividerColor: Colors.transparent,
        // labelColor: const Color(0xFF4A90E2),
        labelColor: Colors.blue,
        unselectedLabelColor: const Color(0xFF64748B),

        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        overlayColor: MaterialStatePropertyAll(Colors.transparent),
        labelPadding: const EdgeInsets.symmetric(vertical: 5),
        tabs: const [
          Tab(text: 'Events'),
          Tab(text: 'Annual'),
        ],
        onTap: (index) {
          if (index == 1) _loadData();
        },
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFilterChips(),
          TableCalendar<EventData>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            availableGestures: AvailableGestures.horizontalSwipe,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            rowHeight: 36,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (_) {
              // Force month view
              setState(() => _calendarFormat = CalendarFormat.month);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Color(0xFF718096)),
              holidayTextStyle: TextStyle(color: Color(0xFFE74C3C)),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF58CC02),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF4A90E2)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF4A90E2)),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(3).map((event) {
                        final type = _eventType(event as EventData);
                        final color = type == 'holiday'
                            ? const Color(0xFFE74C3C)
                            : type == 'exam'
                                ? const Color(0xFFFF9500)
                                : const Color(0xFF4A90E2);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 12,
                          height: 4,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildEventList(_getEventsForDay(_selectedDay ?? DateTime.now())),
          if (_filteredEvents.isNotEmpty) _buildUpcomingEvents(),
        ],
      ),
    );
  }

  Widget _buildAnnualTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAnnualFilterChips(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedYear--;
                    _annualFocusedDay = DateTime(_selectedYear, 1, 1);
                    _annualSelectedDay = DateTime(_selectedYear, 1, 1);
                  });
                  _loadData();
                },
              ),
              Text(
                _selectedYear.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedYear++;
                    _annualFocusedDay = DateTime(_selectedYear, 1, 1);
                    _annualSelectedDay = DateTime(_selectedYear, 1, 1);
                  });
                  _loadData();
                },
              ),
            ],
          ),
          TableCalendar<CalendarItem>(
            firstDay: DateTime.utc(_selectedYear, 1, 1),
            lastDay: DateTime.utc(_selectedYear, 12, 31),
            focusedDay: _annualFocusedDay,
            calendarFormat: _annualCalendarFormat,
            availableGestures: AvailableGestures.horizontalSwipe,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            rowHeight: 36,
            selectedDayPredicate: (day) => isSameDay(_annualSelectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _annualSelectedDay = selectedDay;
                _annualFocusedDay = focusedDay;
              });
            },
            onFormatChanged: (_) {
              setState(() => _annualCalendarFormat = CalendarFormat.month);
            },
            onPageChanged: (focusedDay) {
              _annualFocusedDay = focusedDay;
            },
            eventLoader: _getAnnualEventsForDay,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Color(0xFF718096)),
              holidayTextStyle: TextStyle(color: Color(0xFFE74C3C)),
              selectedDecoration: BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF58CC02),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Color(0xFF4A90E2),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF4A90E2)),
              rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF4A90E2)),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(3).map((event) {
                        final type = _calendarItemType(event as CalendarItem);
                        final color = type == 'holiday'
                            ? const Color(0xFFE74C3C)
                            : type == 'exam'
                                ? const Color(0xFFFF9500)
                                : const Color(0xFF4A90E2);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildAnnualEventList(_getAnnualEventsForDay(_annualSelectedDay ?? DateTime.now())),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      _FilterData(type: 'holiday', label: 'Holidays', color: const Color(0xFFE74C3C)),
      _FilterData(type: 'event', label: 'Events', color: const Color(0xFF4A90E2)),
      _FilterData(type: 'exam', label: 'Exams', color: const Color(0xFFFF9500)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilters.contains(filter.type);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _toggleFilter(filter.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? filter.color : filter.color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: filter.color,
                    width: isSelected ? 0 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : filter.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : filter.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnnualFilterChips() {
    final filters = [
      _FilterData(type: 'holiday', label: 'Holidays', color: const Color(0xFFE74C3C)),
      _FilterData(type: 'event', label: 'Events', color: const Color(0xFF4A90E2)),
      _FilterData(type: 'exam', label: 'Exams', color: const Color(0xFFFF9500)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _annualSelectedFilters.contains(filter.type);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _toggleAnnualFilter(filter.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? filter.color : filter.color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: filter.color,
                    width: isSelected ? 0 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : filter.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : filter.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventList(List<EventData> events) {
    if (events.isEmpty) {
      return const Center(child: Text('No events for selected date'));
    }
    return Column(
      children: events.map((event) {
        final type = _eventType(event);
        final color = type == 'holiday'
            ? const Color(0xFFE74C3C)
            : type == 'exam'
                ? const Color(0xFFFF9500)
                : const Color(0xFF4A90E2);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha:0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.eventName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(event.startDate),
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _capitalize(type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnnualEventList(List<CalendarItem> events) {
    if (events.isEmpty) {
      return const Center(child: Text('No events for selected date'));
    }
    return Column(
      children: events.map((event) {
        final type = _calendarItemType(event);
        final color = type == 'holiday'
            ? const Color(0xFFE74C3C)
            : type == 'exam'
                ? const Color(0xFFFF9500)
                : const Color(0xFF4A90E2);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha:0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.end != null
                          ? '${DateFormat('MMM dd, yyyy').format(event.start)} - ${DateFormat('MMM dd, yyyy').format(event.end!)}'
                          : DateFormat('MMM dd, yyyy').format(event.start),
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _capitalize(type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingEvents() {
    final upcomingEvents = _filteredEvents
        .where((event) => event.startDate.isAfter(DateTime.now()))
        .take(3)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (upcomingEvents.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Upcoming Events',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildEventList(upcomingEvents),
        const SizedBox(height: 20),
      ],
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}

class _FilterData {
  final String type;
  final String label;
  final Color color;
  const _FilterData({required this.type, required this.label, required this.color});
}

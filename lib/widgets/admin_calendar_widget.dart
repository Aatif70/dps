import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dps/services/calendar_service.dart';

class AdminCalendarWidget extends StatefulWidget {
  const AdminCalendarWidget({super.key});

  @override
  State<AdminCalendarWidget> createState() => _AdminCalendarWidgetState();
}

class _AdminCalendarWidgetState extends State<AdminCalendarWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // Data variables
  List<EventData> _events = [];
  AnnualCalendarData? _annualCalendar;
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCalendarData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        CalendarService.getEvents(),
        CalendarService.getAnnualCalendar(_selectedYear),
      ]);

      setState(() {
        _events = results[0] as List<EventData>;
        _annualCalendar = results[1] as AnnualCalendarData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading calendar data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<EventData> _getEventsForDay(DateTime day) {
    return _events.where((event) =>
        event.startDate.year == day.year &&
        event.startDate.month == day.month &&
        event.startDate.day == day.day).toList();
  }

  List<CalendarItem> _getAnnualEventsForDay(DateTime day) {
    if (_annualCalendar == null) return [];
    
    final allEvents = [
      ..._annualCalendar!.holidays,
      ..._annualCalendar!.events,
      ..._annualCalendar!.exams,
    ];

    return allEvents.where((event) =>
        event.start.year == day.year &&
        event.start.month == day.month &&
        event.start.day == day.day).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 480, // Fixed height to provide constraints
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
          // Header with tabs
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF6C5CE7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'School Calendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_tabController.index == 1) // Annual Calendar tab
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedYear--;
                                });
                                _loadCalendarData();
                              },
                              icon: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              _selectedYear.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedYear++;
                                });
                                _loadCalendarData();
                              },
                              icon: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelColor: const Color(0xFF6C5CE7),
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: -18),
                    dividerColor: Colors.transparent,
                    onTap: (index) {
                      if (index == 1) {
                        _loadCalendarData(); // Reload annual calendar data
                      }
                    },
                    tabs: const [
                      Tab(text: 'Events'),
                      Tab(text: 'Annual'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Calendar content
          Flexible(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEventsCalendar(),
                      _buildAnnualCalendar(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsCalendar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TableCalendar<EventData>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
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
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: _getEventsForDay,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Color(0xFFE74C3C)),
            holidayTextStyle: TextStyle(color: Color(0xFFE74C3C)),
            selectedDecoration: BoxDecoration(
              color: Color(0xFF6C5CE7),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFF74B9FF),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Color(0xFFFD79A8),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: Color(0xFF6C5CE7),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            formatButtonTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: _buildEventsList(),
        ),
      ],
    );
  }

  Widget _buildAnnualCalendar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TableCalendar<CalendarItem>(
          firstDay: DateTime.utc(_selectedYear, 1, 1),
          lastDay: DateTime.utc(_selectedYear, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
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
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: _getAnnualEventsForDay,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: TextStyle(color: Color(0xFFE74C3C)),
            holidayTextStyle: TextStyle(color: Color(0xFFE74C3C)),
            selectedDecoration: BoxDecoration(
              color: Color(0xFF6C5CE7),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFF74B9FF),
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Color(0xFFFD79A8),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: Color(0xFF6C5CE7),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            formatButtonTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: _buildAnnualEventsList(),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    final selectedEvents = _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    if (selectedEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Color(0xFFCBD5E0),
            ),
            SizedBox(height: 16),
            Text(
              'No events for selected date',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: Color(0xFF6C5CE7),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.eventName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (event.description.isNotEmpty) ...[
                Text(
                  event.description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${event.startTime} - ${event.endTime}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.venue,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (event.className.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.class_,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Class: ${event.className}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnnualEventsList() {
    final selectedEvents = _selectedDay != null ? _getAnnualEventsForDay(_selectedDay!) : [];

    if (selectedEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Color(0xFFCBD5E0),
            ),
            SizedBox(height: 16),
            Text(
              'No events for selected date',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        final isHoliday = _annualCalendar!.holidays.contains(event);
        final isExam = _annualCalendar!.exams.contains(event);
        
        Color eventColor;
        IconData eventIcon;
        
        if (isHoliday) {
          eventColor = const Color(0xFFE74C3C);
          eventIcon = Icons.beach_access;
        } else if (isExam) {
          eventColor = const Color(0xFFF39C12);
          eventIcon = Icons.quiz;
        } else {
          eventColor = const Color(0xFF2ECC71);
          eventIcon = Icons.event;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: eventColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  eventIcon,
                  color: eventColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHoliday ? 'Holiday' : isExam ? 'Examination' : 'Event',
                      style: TextStyle(
                        color: eventColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

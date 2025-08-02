import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/events_service.dart';

class EventCalendarWidget extends StatefulWidget {
  const EventCalendarWidget({Key? key}) : super(key: key);

  @override
  State<EventCalendarWidget> createState() => _EventCalendarWidgetState();
}

class _EventCalendarWidgetState extends State<EventCalendarWidget>
    with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  List<CalendarEvent> _allEvents = [];
  List<CalendarEvent> _filteredEvents = [];
  Set<EventType> _selectedFilters = {EventType.holiday, EventType.event, EventType.exam};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _initializeAnimation();
    _loadEvents();
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

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final response = await EventsService.getEventCalendar();
      if (response != null) {
        _allEvents = response.data.allEvents;
        _applyFilters();
      }
    } catch (e) {
      print('Error loading events: $e');
    }

    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    _filteredEvents = _allEvents
        .where((event) => _selectedFilters.contains(event.type))
        .toList();
    setState(() {});
  }

  void _toggleFilter(EventType type) {
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

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _filteredEvents.where((event) {
      return isSameDay(event.start, day) ||
          (event.end != null &&
              (isSameDay(event.end!, day) ||
                  (day.isAfter(event.start) && day.isBefore(event.end!))));
    }).toList();
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
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarHeader(),
                _buildFilterChips(),
                _buildCalendar(),
                if (_getEventsForDay(_selectedDay ?? DateTime.now()).isNotEmpty)
                  _buildSelectedDayEvents(),
                if (_filteredEvents.isNotEmpty) _buildUpcomingEvents(),
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
              Text(
                'Events Calendar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
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

  Widget _buildFilterChips() {
    final filters = [
      FilterData(type: EventType.holiday, label: 'Holidays', color: const Color(0xFFE74C3C)),
      FilterData(type: EventType.event, label: 'Events', color: const Color(0xFF4A90E2)),
      FilterData(type: EventType.exam, label: 'Exams', color: const Color(0xFFFF9500)),
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
                  color: isSelected ? filter.color : filter.color.withOpacity(0.1),
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

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: _isLoading
          ? const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
          ),
        ),
      )
          : TableCalendar<CalendarEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: Color(0xFF718096),
          ),
          holidayTextStyle: TextStyle(
            color: Color(0xFFE74C3C),
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFF4A90E2),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Color(0xFF58CC02),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
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
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: Color(0xFF4A90E2),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: Color(0xFF4A90E2),
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: events.take(3).map((event) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: (event as CalendarEvent).color,
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
    );
  }

  Widget _buildSelectedDayEvents() {
    final selectedEvents = _getEventsForDay(_selectedDay ?? DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Events on ${DateFormat('MMM dd, yyyy').format(_selectedDay ?? DateTime.now())}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...selectedEvents.map((event) => _buildEventTile(event)),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    final upcomingEvents = _filteredEvents
        .where((event) => event.start.isAfter(DateTime.now()))
        .take(3)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

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
        ...upcomingEvents.map((event) => _buildEventTile(event)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEventTile(CalendarEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: event.color,
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
                  DateFormat('MMM dd, yyyy').format(event.start),
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
              color: event.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getEventTypeLabel(event.type),
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
  }

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.holiday:
        return 'Holiday';
      case EventType.event:
        return 'Event';
      case EventType.exam:
        return 'Exam';
    }
  }
}

// Filter data model
class FilterData {
  final EventType type;
  final String label;
  final Color color;

  const FilterData({
    required this.type,
    required this.label,
    required this.color,
  });
}

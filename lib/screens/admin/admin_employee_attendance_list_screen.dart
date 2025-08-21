import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dps/services/admin_employee_attendance_service.dart';

class AdminEmployeeAttendanceListScreen extends StatefulWidget {
  const AdminEmployeeAttendanceListScreen({super.key});

  @override
  State<AdminEmployeeAttendanceListScreen> createState() => _AdminEmployeeAttendanceListScreenState();
}

class _AdminEmployeeAttendanceListScreenState extends State<AdminEmployeeAttendanceListScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  bool _isLoading = true;
  List<AttendanceDay> _days = [];

  final DateFormat _df = DateFormat('dd MMM, yyyy');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final res = await AdminEmployeeAttendanceService.getAttendanceList(fromDate: _fromDate, toDate: _toDate);
    if (!mounted) return;
    setState(() {
      _days = res;
      _isLoading = false;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        actions: [
          IconButton(onPressed: _pickDateRange, icon: const Icon(Icons.date_range_rounded, color: Color(0xFF6C5CE7))),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                strokeWidth: 3,
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFF6C5CE7),
              child: _days.isEmpty
                  ? ListView(children: const [SizedBox(height: 120), _EmptyState(message: 'No attendance found')])
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final day = _days[index];
                        return _AttendanceDayCard(day: day);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _days.length,
                    ),
            ),
    );
  }
}

class _AttendanceDayCard extends StatelessWidget {
  final AttendanceDay day;
  const _AttendanceDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          maintainState: true,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF6C5CE7)),
          ),
          title: Text(
            day.formattedDate,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)),
          ),
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final emp = day.employees[index];
                final present = emp.isPresent;
                final color = present ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
                return Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: color),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp.employeeName, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text(
                            present
                                ? 'Present • In ${emp.inTime ?? '-'}  · Out ${emp.outTime ?? '-'}'
                                : 'Absent',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: day.employees.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
          child: Icon(Icons.fact_check_outlined, size: 40, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 16),
        Text(message, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }
}



import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dps/services/admin_employee_attendance_service.dart';

class AdminUpdateEmployeeAttendanceScreen extends StatefulWidget {
  const AdminUpdateEmployeeAttendanceScreen({super.key});

  @override
  State<AdminUpdateEmployeeAttendanceScreen> createState() => _AdminUpdateEmployeeAttendanceScreenState();
}

class _AdminUpdateEmployeeAttendanceScreenState extends State<AdminUpdateEmployeeAttendanceScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  bool _loading = true;
  List<AttendanceDay> _days = [];

  final _inCtrl = TextEditingController();
  final _outCtrl = TextEditingController();
  bool _isPresent = true;
  AttendanceEmployee? _selected;
  TimeOfDay? _inTime;
  TimeOfDay? _outTime;

  @override
  void initState() {
    super.initState();
    _load();
  }

  TimeOfDay? _parseTimeString(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await AdminEmployeeAttendanceService.getAttendanceList(fromDate: _fromDate, toDate: _toDate);
    if (!mounted) return;
    setState(() {
      _days = res;
      _loading = false;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _load();
    }
  }

  void _edit(AttendanceEmployee emp, DateTime date) {
    _selected = emp;
    _inCtrl.text = emp.inTime ?? '';
    _outCtrl.text = emp.outTime ?? '';
    _isPresent = emp.isPresent;
    
    // Parse time strings to TimeOfDay objects
    _inTime = _parseTimeString(emp.inTime);
    _outTime = _parseTimeString(emp.outTime);
    
    setState(() {});
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _EditSheet(
            name: emp.employeeName,
            date: date,
            inTime: _inTime,
            outTime: _outTime,
            isPresent: _isPresent,
            onPresentChanged: (v) => setState(() => _isPresent = v),
            onInTimeChanged: (time) => setState(() => _inTime = time),
            onOutTimeChanged: (time) => setState(() => _outTime = time),
            onSave: () async {
              final ok = await AdminEmployeeAttendanceService.updateAttendance(
                attId: emp.attId,
                empId: emp.empId ?? 0,
                attDate: date,
                isPresent: _isPresent,
                inTime: _formatTimeOfDay(_inTime),
                outTime: _formatTimeOfDay(_outTime),
              );
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Attendance updated' : 'Update failed'), backgroundColor: ok ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C)));
              if (ok) _load();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Attendance', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
        actions: [IconButton(onPressed: _pickDateRange, icon: const Icon(Icons.date_range_rounded, color: Color(0xFF6C5CE7))), const SizedBox(width: 8)],
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF6C5CE7)), strokeWidth: 3))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final day = _days[index];
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
                        decoration: BoxDecoration(color: const Color(0xFFE17055).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.event_note_rounded, color: Color(0xFFE17055)),
                      ),
                      title: Text(
                        DateFormat('dd MMM, yyyy').format(day.date),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)),
                      ),
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, empIndex) {
                            final emp = day.employees[empIndex];
                            final present = emp.isPresent;
                            final color = present ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
                            return InkWell(
                              onTap: () => _edit(emp, day.date),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                                child: Row(children: [
                                  Icon(present ? Icons.check_circle : Icons.cancel, color: color),
                                  const SizedBox(width: 10),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(emp.employeeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(present ? 'In ${emp.inTime ?? '-'} · Out ${emp.outTime ?? '-'}' : 'Absent', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                  ])),
                                  const Icon(Icons.edit_rounded, color: Color(0xFF94A3B8)),
                                ]),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemCount: day.employees.length,
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _days.length,
            ),
    );
  }
}

class _EditSheet extends StatelessWidget {
  final String name;
  final DateTime date;
  final TimeOfDay? inTime;
  final TimeOfDay? outTime;
  final bool isPresent;
  final ValueChanged<bool> onPresentChanged;
  final ValueChanged<TimeOfDay?> onInTimeChanged;
  final ValueChanged<TimeOfDay?> onOutTimeChanged;
  final VoidCallback onSave;

  const _EditSheet({
    required this.name,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.isPresent,
    required this.onPresentChanged,
    required this.onInTimeChanged,
    required this.onOutTimeChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.person, color: Color(0xFF6C5CE7)),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
            Text(DateFormat('dd MMM, yyyy').format(date), style: const TextStyle(color: Color(0xFF64748B))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Present', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Switch(value: isPresent, activeColor: const Color(0xFF2ECC71), onChanged: onPresentChanged),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: inTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    onInTimeChanged(time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF6C5CE7)),
                      const SizedBox(width: 8),
                      Text(
                        inTime != null 
                          ? '${inTime!.hour.toString().padLeft(2, '0')}:${inTime!.minute.toString().padLeft(2, '0')}'
                          : 'Select In Time',
                        style: TextStyle(
                          color: inTime != null ? Colors.black : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: outTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    onOutTimeChanged(time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF6C5CE7)),
                      const SizedBox(width: 8),
                      Text(
                        outTime != null 
                          ? '${outTime!.hour.toString().padLeft(2, '0')}:${outTime!.minute.toString().padLeft(2, '0')}'
                          : 'Select Out Time',
                        style: TextStyle(
                          color: outTime != null ? Colors.black : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}



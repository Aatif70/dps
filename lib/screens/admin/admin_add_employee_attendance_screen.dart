import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dps/services/admin_employee_attendance_service.dart';
import 'package:dps/services/admin_employee_list_service.dart';
import 'package:dps/widgets/custom_snackbar.dart';

class AdminAddEmployeeAttendanceScreen extends StatefulWidget {
  const AdminAddEmployeeAttendanceScreen({super.key});

  @override
  State<AdminAddEmployeeAttendanceScreen> createState() => _AdminAddEmployeeAttendanceScreenState();
}

class _AdminAddEmployeeAttendanceScreenState extends State<AdminAddEmployeeAttendanceScreen> {
  DateTime _date = DateTime.now();
  final TextEditingController _inTimeCtrl = TextEditingController(text: '09:05');
  final TextEditingController _outTimeCtrl = TextEditingController(text: '17:10');
  bool _loading = true;
  bool _submitting = false;
  List<EmployeeItem> _employees = [];
  final Map<int, bool> _presence = {};

  final DateFormat _df = DateFormat('dd MMM, yyyy');

  TimeOfDay _parseTime(String text) {
    final parts = text.split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) {
        return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
      }
    }
    return TimeOfDay.now();
  }

  String _formatTimeOfDay24(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loading = true);
    final items = await AdminEmployeeListService.fetchEmployees();
    if (!mounted) return;
    setState(() {
      _employees = items;
      for (final e in _employees) {
        _presence[e.empId] = true;
      }
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(_inTimeCtrl.text),
    );
    if (picked != null) {
      setState(() => _inTimeCtrl.text = _formatTimeOfDay24(picked));
    }
  }

  Future<void> _pickOutTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(_outTimeCtrl.text),
    );
    if (picked != null) {
      setState(() => _outTimeCtrl.text = _formatTimeOfDay24(picked));
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final employees = _presence.entries
        .map((e) => AttendancePostEmployee(empId: e.key, isPresent: e.value))
        .toList();
    final ok = await AdminEmployeeAttendanceService.addAttendance(
      date: _date,
      inTime: _inTimeCtrl.text.trim(),
      outTime: _outTimeCtrl.text.trim(),
      employees: employees,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    final msg = ok ? 'Attendance added' : 'Failed to add attendance';
    final color = ok ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    if (ok) {
      CustomSnackbar.showSuccess(context, message: msg);
      Navigator.pop(context);
    } else {
      CustomSnackbar.showError(context, message: msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Attendance', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _loading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF6C5CE7)), strokeWidth: 3))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickInTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFDDE3EA)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, color: Color(0xFF6C5CE7)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _inTimeCtrl.text,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('In', style: TextStyle(color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _pickOutTime,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFDDE3EA)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timelapse_rounded, color: Color(0xFF6C5CE7)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _outTimeCtrl.text,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Out', style: TextStyle(color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFDDE3EA)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.date_range_rounded, color: Color(0xFF6C5CE7)),
                                const SizedBox(width: 10),
                                Text(_df.format(_date), style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final e = _employees[index];
                      final present = _presence[e.empId] ?? false;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: const Color(0xFF6C5CE7).withOpacity(0.1), child: const Icon(Icons.person, color: Color(0xFF6C5CE7))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(e.designationName, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                              ]),
                            ),
                            Switch(
                              value: present,
                              activeColor: const Color(0xFF2ECC71),
                              onChanged: (v) => setState(() => _presence[e.empId] = v),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: _employees.length,
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitting ? null : _submit,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(_submitting ? 'Submitting...' : 'Save Attendance'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}



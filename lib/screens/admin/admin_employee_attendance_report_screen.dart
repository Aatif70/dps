import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dps/services/admin_employee_attendance_service.dart';
import 'package:dps/services/admin_employee_list_service.dart';

class AdminEmployeeAttendanceReportScreen extends StatefulWidget {
  const AdminEmployeeAttendanceReportScreen({super.key});

  @override
  State<AdminEmployeeAttendanceReportScreen> createState() => _AdminEmployeeAttendanceReportScreenState();
}

class _AdminEmployeeAttendanceReportScreenState extends State<AdminEmployeeAttendanceReportScreen> {
  int? _empId;
  DateTime _from = DateTime.now().subtract(const Duration(days: 7));
  DateTime _to = DateTime.now();
  bool _loading = false;
  List<EmployeeItem> _employees = [];
  EmployeeAttendanceReport? _report;

  final _df = DateFormat('dd MMM, yyyy');

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final list = await AdminEmployeeListService.fetchEmployees();
    if (!mounted) return;
    setState(() {
      _employees = list;
      if (_employees.isNotEmpty) _empId = _employees.first.empId;
    });
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (picked != null) setState(() {
      _from = picked.start;
      _to = picked.end;
    });
  }

  Future<void> _fetch() async {
    if (_empId == null) return;
    setState(() { _loading = true; _report = null; });
    final res = await AdminEmployeeAttendanceService.getEmployeeAttendanceReport(empId: _empId!, startDate: _from, endDate: _to);
    if (!mounted) return;
    setState(() { _report = res; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Dropdown row (full width)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDDE3EA)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _empId,
                      hint: const Text('Select employee'),
                      items: _employees
                          .map((e) => DropdownMenuItem(
                                value: e.empId,
                                child: Text(e.name, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _empId = v),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Date range row on its own line
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: _pickRange,
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
                          const SizedBox(width: 8),
                          Text(
                            '${_df.format(_from)} - ${_df.format(_to)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _fetch,
                icon: const Icon(Icons.trending_up_rounded),
                label: Text(_loading ? 'Loading...' : 'Generate Report'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _report == null
                ? Center(child: Text(_loading ? '' : 'Select filters and generate report', style: const TextStyle(color: Color(0xFF64748B))))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF4A90E2).withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person, color: Color(0xFF4A90E2))),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_report!.employeeName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)))),
                        ]),
                        const SizedBox(height: 12),
                        Text('Range: ${_df.format(_report!.startDate)} - ${_df.format(_report!.endDate)}', style: const TextStyle(color: Color(0xFF64748B))),
                        const SizedBox(height: 12),
                        Row(children: [
                          _StatChip(label: 'Working', value: _report!.totalWorkingDays.toString(), color: const Color(0xFF6C5CE7)),
                          const SizedBox(width: 8),
                          _StatChip(label: 'Present', value: _report!.totalPresentDays.toString(), color: const Color(0xFF2ECC71)),
                          const SizedBox(width: 8),
                          _StatChip(label: 'Absent', value: _report!.totalAbsentDays.toString(), color: const Color(0xFFE74C3C)),
                        ]),
                      ]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha:0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha:0.3))),
      child: Row(children: [Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)), const SizedBox(width: 6), Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700))]),
    );
  }
}



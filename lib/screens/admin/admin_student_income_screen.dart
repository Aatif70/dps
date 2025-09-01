import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';

class AdminStudentIncomeScreen extends StatefulWidget {
  const AdminStudentIncomeScreen({super.key});

  @override
  State<AdminStudentIncomeScreen> createState() => _AdminStudentIncomeScreenState();
}

class _AdminStudentIncomeScreenState extends State<AdminStudentIncomeScreen> {
  IncomeDetail? _data;
  bool _loading = true;
  int? _studentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (_studentId == null && args != null && args['studentId'] != null) {
      _studentId = args['studentId'] is int ? args['studentId'] as int : int.tryParse(args['studentId'].toString());
      if (_studentId != null) {
        _fetch();
      }
    }
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final IncomeDetail? d = await AdminStudentService.fetchIncomeDetail(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Income', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No income details'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 6)),
                          ],
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            _kv('Have Certificate', _data!.haveCertificate),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Amount', _data!.amount.toStringAsFixed(2)),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Certificate No', _data!.certNo),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Issued Date', _data!.issueDate),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Valid Up To', _data!.validUpTo),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('PAN No', _data!.panNo),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Aadhaar No', _data!.adharNo),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _kv(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 160, child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))),
      ],
    );
  }
}



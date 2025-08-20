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
      appBar: AppBar(title: const Text('Income')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No income details'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _kv('Have Certificate', _data!.haveCertificate),
                      _kv('Amount', _data!.amount.toStringAsFixed(2)),
                      _kv('Certificate No', _data!.certNo),
                      _kv('Issued Date', _data!.issueDate),
                      _kv('Valid Up To', _data!.validUpTo),
                      _kv('PAN No', _data!.panNo),
                      _kv('Aadhaar No', _data!.adharNo),
                    ],
                  ),
                ),
    );
  }

  Widget _kv(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: const TextStyle(color: Color(0xFF64748B)))),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}



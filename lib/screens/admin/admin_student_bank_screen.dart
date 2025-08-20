import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';

class AdminStudentBankScreen extends StatefulWidget {
  const AdminStudentBankScreen({super.key});

  @override
  State<AdminStudentBankScreen> createState() => _AdminStudentBankScreenState();
}

class _AdminStudentBankScreenState extends State<AdminStudentBankScreen> {
  List<BankDetail> _list = [];
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
    final List<BankDetail> list = await AdminStudentService.fetchBankDetails(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _list = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bank')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _list.isEmpty
                  ? const ListTile(title: Text('No bank details'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final BankDetail b = _list[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${b.holderName} • ${b.accountType}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text('${b.bankName} (${b.branch})', style: const TextStyle(color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text('A/C: ${b.bankAccountNo} • IFSC: ${b.ifscCode}'),
                              const SizedBox(height: 4),
                              Text('MICR: ${b.micrCode} • Branch Code: ${b.branchCode}'),
                              const SizedBox(height: 4),
                              Text('Aadhaar Linked: ${b.adharLinked} • Mobile Linked: ${b.mobileLinked}'),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: _list.length,
                    ),
            ),
    );
  }
}



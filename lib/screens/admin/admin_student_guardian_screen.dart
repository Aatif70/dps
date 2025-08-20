import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';

class AdminStudentGuardianScreen extends StatefulWidget {
  const AdminStudentGuardianScreen({super.key});

  @override
  State<AdminStudentGuardianScreen> createState() => _AdminStudentGuardianScreenState();
}

class _AdminStudentGuardianScreenState extends State<AdminStudentGuardianScreen> {
  List<GuardianDetail> _list = [];
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
    final List<GuardianDetail> list = await AdminStudentService.fetchGuardianDetails(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _list = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Guardian', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _list.isEmpty
                  ? const Center(child: Text('No guardians'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final GuardianDetail g = _list[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6)),
                            ],
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _chip('Relation: ${g.relationWithStudent}'),
                                  const SizedBox(width: 8),
                                  _chip('Mobile: ${g.mobileNo}'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(g.address, style: const TextStyle(color: Color(0xFF475569))),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _list.length,
                    ),
            ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}



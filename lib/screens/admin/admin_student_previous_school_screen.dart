import 'package:flutter/material.dart';
import 'package:AES/services/admin_student_service.dart';

class AdminStudentPreviousSchoolScreen extends StatefulWidget {
  const AdminStudentPreviousSchoolScreen({super.key});

  @override
  State<AdminStudentPreviousSchoolScreen> createState() => _AdminStudentPreviousSchoolScreenState();
}

class _AdminStudentPreviousSchoolScreenState extends State<AdminStudentPreviousSchoolScreen> {
  List<PreviousSchoolItem> _list = [];
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
    final List<PreviousSchoolItem> list = await AdminStudentService.fetchPreviousSchools(studentId: _studentId!);
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
        title: const Text('Previous School', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _list.isEmpty
                  ? const Center(child: Text('No previous school details'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final PreviousSchoolItem p = _list[index];
                        return Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _chip(p.location),
                                  const SizedBox(width: 8),
                                  _chip(p.studentClass),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('Years: ${p.years}\nLanguage: ${p.language}\nCurriculum: ${p.curriculum}', style: const TextStyle(color: Color(0xFF475569))),
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
        color: const Color(0xFF4A90E2).withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}



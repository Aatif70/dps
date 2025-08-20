import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';

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
      appBar: AppBar(title: const Text('Previous School')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _list.isEmpty
                  ? const ListTile(title: Text('No previous school details'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final PreviousSchoolItem p = _list[index];
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
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text('${p.location} • ${p.studentClass}', style: const TextStyle(color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text('Years: ${p.years} • Language: ${p.language} • Curriculum: ${p.curriculum}'),
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



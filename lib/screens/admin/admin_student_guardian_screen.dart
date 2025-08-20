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
      appBar: AppBar(title: const Text('Guardian')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _list.isEmpty
                  ? const ListTile(title: Text('No guardians'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final GuardianDetail g = _list[index];
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
                              Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text('Relation: ${g.relationWithStudent}', style: const TextStyle(color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text('Mobile: ${g.mobileNo}', style: const TextStyle(color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text(g.address),
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



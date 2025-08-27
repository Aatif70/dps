import 'package:dps/constants/app_routes.dart';
import 'package:dps/services/admin_admissions_service.dart';
import 'package:flutter/material.dart';

class AdminRegisteredStudentsListScreen extends StatefulWidget {
  const AdminRegisteredStudentsListScreen({super.key});

  @override
  State<AdminRegisteredStudentsListScreen> createState() => _AdminRegisteredStudentsListScreenState();
}

class _AdminRegisteredStudentsListScreenState extends State<AdminRegisteredStudentsListScreen> {
  late Future<List<RegisteredStudentSummary>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = AdminAdmissionsService.fetchRegisteredStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Registered Students',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: FutureBuilder<List<RegisteredStudentSummary>>(
        future: _future,
        builder: (context, snapshot) {
          final bool loading = snapshot.connectionState == ConnectionState.waiting;
          final List<RegisteredStudentSummary> items = snapshot.data ?? <RegisteredStudentSummary>[];
          final List<RegisteredStudentSummary> filtered = _query.isEmpty
              ? items
              : items
                  .where((s) => ('${s.name} ${s.studentMobile ?? ''} ${s.parentMobile ?? ''}').toLowerCase().contains(_query))
                  .toList();

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = AdminAdmissionsService.fetchRegisteredStudents();
              });
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.how_to_reg_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Admissions - Registered', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 6),
                          Text(
                            'Awaiting admission approvals',
                            style: TextStyle(color: Colors.white.withOpacity(0.95)),
                          ),
                          const SizedBox(height: 12),
                          if (loading)
                            const LinearProgressIndicator(minHeight: 3, color: Colors.white)
                          else
                            Wrap(spacing: 10, runSpacing: 10, children: [
                              _pill('Total Registered', items.length.toString()),
                            ]),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6)),
                    ],
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search by name or mobile',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.hasError)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
                    child: Text('Error: ${snapshot.error}'),
                  )
                else if (loading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
                    child: const Center(child: Text('No registered students')),
                  )
                else
                  ...filtered.map((s) => _studentCard(context, s)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white24)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.app_registration_rounded, color: Colors.white, size: 14),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _studentCard(BuildContext context, RegisteredStudentSummary s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.adminRegisteredStudentDetails,
          arguments: s,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6)),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(
                    '${s.className ?? '-'} • ${s.acadYear ?? '-'}',
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ]),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}



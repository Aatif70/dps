import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/services/admin_student_metrics_service.dart';

class AdminStudentsHubScreen extends StatefulWidget {
  const AdminStudentsHubScreen({super.key});

  @override
  State<AdminStudentsHubScreen> createState() => _AdminStudentsHubScreenState();
}

class _AdminStudentsHubScreenState extends State<AdminStudentsHubScreen> {
  bool _loading = true;
  StudentMetrics? _metrics;
  String _academicYear = '2025';
  final TextEditingController _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _yearController.text = _academicYear;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final m = await AdminStudentMetricsService.fetchStudentMetrics(academicYear: _academicYear);
    if (!mounted) return;
    setState(() {
      _metrics = m;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _HubItem(
        title: 'Search Students',
        subtitle: 'Find a student by name or ID',
        icon: Icons.person_search_rounded,
        color: const Color(0xFF4A90E2),
        route: AppRoutes.adminStudents,
      ),
      _HubItem(
        title: 'Fees Details',
        subtitle: 'View fees history for a student',
        icon: Icons.payments_rounded,
        color: const Color(0xFFFF7043),
        route: AppRoutes.adminFeesStudentSearch,
      ),

      _HubItem(
        title: 'New Admission',
        subtitle: 'Add a new student into the school',
        icon: Icons.add_outlined,
        color: const Color(0xFFE4004B),
        route: AppRoutes.adminRegisteredStudents,
      ),

      _HubItem(
        title: 'Admitted Students',
        subtitle: 'View admitted students by class',
        icon: Icons.verified_rounded,
        color: const Color(0xFF16A34A),
        route: AppRoutes.adminAdmittedStudents,
      ),


    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Students', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Warm header metric card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A65), Color(0xFFFF6E6E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF8A65).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.groups_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Students Overview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('Academic Year:', style: TextStyle(color: Colors.white.withOpacity(0.95))),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                hintText: 'YYYY',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                              ),
                              onSubmitted: (v) {
                                final nv = v.trim();
                                if (nv.isNotEmpty) {
                                  setState(() => _academicYear = nv);
                                  _load();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 44),
                            child: ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                final nv = _yearController.text.trim();
                                if (nv.isNotEmpty) {
                                  setState(() => _academicYear = nv);
                                  _load();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF6E6E),
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Go'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_loading)
                        const LinearProgressIndicator(minHeight: 3, color: Colors.white)
                      else
                        Wrap(spacing: 10, runSpacing: 10, children: [
                          _pill('Total Students', (_metrics?.totalStudent ?? 0).toString(), const Color(0xFF1B5E20)),
                          _pill('Today Present', (_metrics?.todayAttendance.length ?? 0).toString(), const Color(0xFF2E7D32)),
                        ]),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, item.route),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: item.color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [item.color.withOpacity(0.12), item.color.withOpacity(0.06)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(item.icon, color: item.color, size: 28),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              item.subtitle,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _pill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white24)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(label == 'Total Students' ? Icons.people_rounded : Icons.check_circle_rounded, color: Colors.white, size: 14),
        const SizedBox(width: 6),
        Text(label + ': ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _HubItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _HubItem({required this.title, required this.subtitle, required this.icon, required this.color, required this.route});
}



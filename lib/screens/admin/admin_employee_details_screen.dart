import 'package:flutter/material.dart';
import 'package:dps/services/admin_employee_details_service.dart';

class AdminEmployeeDetailsScreen extends StatefulWidget {
  const AdminEmployeeDetailsScreen({super.key});

  @override
  State<AdminEmployeeDetailsScreen> createState() => _AdminEmployeeDetailsScreenState();
}

class _AdminEmployeeDetailsScreenState extends State<AdminEmployeeDetailsScreen> with SingleTickerProviderStateMixin {
  EmployeeDetailsResponse? _details;
  bool _isLoading = true;
  int _empId = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('[AdminEmployeeDetails] initState');
    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    debugPrint('[AdminEmployeeDetails] didChangeDependencies - route args: ' + (args?.toString() ?? 'null'));
    if (_empId == 0) {
      if (args is int) {
        _empId = args;
        debugPrint('[AdminEmployeeDetails] Parsed EmpId: ' + _empId.toString());
        _load();
      } else {
        debugPrint('[AdminEmployeeDetails] Invalid or missing EmpId argument');
      }
    }
  }

  Future<void> _load() async {
    debugPrint('[AdminEmployeeDetails] _load() start for EmpId=' + _empId.toString());
    setState(() => _isLoading = true);
    final res = await AdminEmployeeDetailsService.fetchEmployeeDetails(empId: _empId);
    if (!mounted) return;
    setState(() {
      _details = res;
      _isLoading = false;
    });
    print('[AdminEmployeeDetails] _load() complete. hasData=' + (_details != null).toString());
    if (_details != null) {
      print('[AdminEmployeeDetails] personalDetails=' + _details!.personalDetails.length.toString());
      print('[AdminEmployeeDetails] classAndSubject=' + _details!.classAndSubject.length.toString());
      final int tt = _details!.empTimeTable.isNotEmpty ? _details!.empTimeTable.first.timeTables.length : 0;
      print('[AdminEmployeeDetails] timeTables=' + tt.toString());
      Future.delayed(const Duration(milliseconds: 150), () => _fadeController.forward());
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                strokeWidth: 3,
              ),
            )
          : _details == null
              ? _buildEmptyState('Unable to load details')
              : RefreshIndicator(
                  onRefresh: _load,
                  color: const Color(0xFF6C5CE7),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeroHeader(context, _details!),
                          const SizedBox(height: 20),
                          _buildPersonalSection(context, _details!),
                          const SizedBox(height: 20),
                          _buildClassesSection(context, _details!),
                          const SizedBox(height: 20),
                          _buildTimetableSection(context, _details!),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(String message) {
    return ListView(children: [
      const SizedBox(height: 120),
      Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: Icon(Icons.info_outline, size: 40, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      )
    ]);
  }
}
/// Header similar to study screen: gradient banner with title and brief stats
Widget _buildHeroHeader(BuildContext context, EmployeeDetailsResponse details) {
  final PersonalDetail? pd = details.personalDetails.isNotEmpty ? details.personalDetails.first : null;
  final String name = pd?.name ?? 'Employee';
  final String role = pd?.designation ?? 'Role';
  return Container(
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF6C5CE7), Color(0xFF4A90E2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6C5CE7).withValues(alpha:0.25),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.groups_rounded, color: Colors.white, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha:0.85), borderRadius: BorderRadius.circular(10)),
              child: Text(role, style:  TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            ),

          ]),
        ),
      ],
    ),
  );
}

Widget _buildPersonalSection(BuildContext context, EmployeeDetailsResponse details) {
  final PersonalDetail? p = details.personalDetails.isNotEmpty ? details.personalDetails.first : null;
  print('[AdminEmployeeDetails] Render personal section - hasPersonal=' + (p != null).toString());
  if (p == null) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SectionCard(child: const Text('No personal details', style: TextStyle(color: Color(0xFF64748B)))),
    );
  }
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: _SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Row(children: [
        //   Container(
        //     width: 56,
        //     height: 56,
        //     decoration: BoxDecoration(color: const Color(0xFF6C5CE7).withValues(alpha:0.1), borderRadius: BorderRadius.circular(14)),
        //     child: const Icon(Icons.person, color: Color(0xFF6C5CE7), size: 28),
        //   ),
        //   const SizedBox(width: 14),
        //   // Expanded(
        //   //   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //   //     Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B))),
        //   //     const SizedBox(height: 6),
        //   //     Row(children: [
        //   //       Container(
        //   //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        //   //         decoration: BoxDecoration(color: const Color(0xFF00CEC9).withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)),
        //   //         child: Text(p.designation, style: const TextStyle(color: Color(0xFF00CEC9), fontWeight: FontWeight.w600, fontSize: 12)),
        //   //       ),
        //   //     ]),
        //   //   ]),
        //   // )
        // ]),
        // const SizedBox(height: 16),
        _InfoTile(icon: Icons.male_outlined, label: 'Gender', value: p.gender),
        _InfoTile(icon: Icons.event_available_outlined, label: 'Joining Date', value: _formatDate(p.joiningDate)),
        _InfoTile(icon: Icons.cake_outlined, label: 'Date of Birth', value: _formatDate(p.dob)),
        _InfoTile(icon: Icons.email_outlined, label: 'Email', value: p.email),
      ]),
    ),
  );
}

Widget _buildClassesSection(BuildContext context, EmployeeDetailsResponse details) {
  print('[AdminEmployeeDetails] Render classes section - count=' + details.classAndSubject.length.toString());
  if (details.classAndSubject.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SectionCard(title: 'Classes & Subjects', child: const Text('No classes assigned', style: TextStyle(color: Color(0xFF64748B)))),
    );
  }
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: _SectionCard(
      title: 'Classes & Subjects',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: details.classAndSubject.map((cls) {
          final int count = cls.subjects.length;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(cls.className, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF6C5CE7).withValues(alpha:0.08), borderRadius: BorderRadius.circular(999)),
                    child: Text('$count subjects', style: const TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Categorize by SubTypeName for cleaner grouping
              ..._groupSubjectsByType(cls.subjects).entries.map((entry) {
                final String category = entry.key;
                final List<SubjectItem> subs = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(category, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subs.map((s) => Chip(
                        label: Text(s.subjectName),
                        //backgroundColor: const Color(0xFFEEF2FF),
                        backgroundColor: Colors.white70,
                        labelStyle: const TextStyle(color: Color(0xFF4338CA)),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )).toList(),
                    ),
                  ]),
                );
              }),
            ]),
          );
        }).toList(),
      ),
    ),
  );
}

Widget _buildTimetableSection(BuildContext context, EmployeeDetailsResponse details) {
  final List<TimeTableItem> raw = details.empTimeTable.isNotEmpty ? details.empTimeTable.first.timeTables : <TimeTableItem>[];
  print('[AdminEmployeeDetails] Render timetable section - count=' + raw.length.toString());
  if (raw.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SectionCard(title: 'Timetable', child: const Text('No timetable available', style: TextStyle(color: Color(0xFF64748B)))),
    );
  }

  // Group by weekday, sort by time
  final Map<String, List<TimeTableItem>> byDay = {};
  for (final t in raw) {
    byDay.putIfAbsent(t.weekDay, () => <TimeTableItem>[]).add(t);
  }
  for (final e in byDay.entries) {
    e.value.sort((a, b) => _parseTime(a.fromTime).compareTo(_parseTime(b.fromTime)));
  }
  final List<String> weekdayOrder = const ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
  final List<String> days = byDay.keys.toList()
    ..sort((a, b) => weekdayOrder.indexOf(a).compareTo(weekdayOrder.indexOf(b)));

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: _SectionCard(
      title: 'Timetable',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: days.map((day) {
          final items = byDay[day] ?? <TimeTableItem>[];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF6C5CE7)),
                const SizedBox(width: 8),
                Text(day, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B))),
              ]),
              const SizedBox(height: 8),
              ...items.map((t) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C5CE7).withValues(alpha:0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    // Time pill
                    Container(
                      width: 82,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withValues(alpha:0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          t.fromTime,
                          style: const TextStyle(
                            color: Color(0xFF5B5CEB),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.toTime,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    // Lesson details
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(
                            child: Text(
                              t.subject,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              t.subType,
                              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.menu_book_rounded, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${t.className} • ${t.division} • ${t.batch}',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ]),
                );
              }).toList(),
            ]),
          );
        }).toList(),
      ),
    ),
  );
}

Map<String, List<SubjectItem>> _groupSubjectsByType(List<SubjectItem> subjects) {
  final Map<String, List<SubjectItem>> map = {};
  for (final s in subjects) {
    final key = (s.subTypeName.isEmpty ? 'General' : s.subTypeName);
    map.putIfAbsent(key, () => <SubjectItem>[]).add(s);
  }
  return map;
}

DateTime _parseTime(String hhmm) {
  try {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return DateTime(2000, 1, 1, h, m);
  } catch (_) {
    return DateTime(2000, 1, 1);
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  const _SectionCard({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (title != null) ...[
          Text(title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3748))),
          const SizedBox(height: 12),
        ],
        child,
      ]),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF6C5CE7).withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            const SizedBox(height: 2),
            Text(value.isEmpty ? '-' : value, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
          ]),
        )
      ]),
    );
  }
}

String _formatDate(String iso) {
  if (iso.isEmpty) return '-';
  try {
    final DateTime dt = DateTime.parse(iso);
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
  } catch (_) {
    return iso;
  }
}

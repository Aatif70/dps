import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';
import 'package:dps/constants/app_routes.dart';

class AdminStudentDetailsScreen extends StatefulWidget {
  const AdminStudentDetailsScreen({super.key});

  @override
  State<AdminStudentDetailsScreen> createState() => _AdminStudentDetailsScreenState();
}

class _AdminStudentDetailsScreenState extends State<AdminStudentDetailsScreen> {
  StudentBriefDetails? _details;
  bool _loading = true;
  int? _studentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_studentId == null && args is Map && args['studentId'] != null) {
      final int? sid = args['studentId'] is int
          ? args['studentId'] as int
          : int.tryParse(args['studentId'].toString());
      if (sid != null) {
        _studentId = sid;
        _fetch();
      }
    }
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
    });
    final StudentBriefDetails? d = await AdminStudentService.fetchStudentBriefDetails(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _details = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
              ? const Center(child: Text('No details found'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(_details!),
                      const SizedBox(height: 16),
                      _buildInfoGrid(_details!),
                      const SizedBox(height: 24),
                      const Text('More', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _buildNavTile(
                        icon: Icons.badge_rounded,
                        color: const Color(0xFF4A90E2),
                        title: 'Personal Details',
                        route: AppRoutes.adminStudentPersonal,
                      ),
                      _buildNavTile(
                        icon: Icons.groups_rounded,
                        color: const Color(0xFF58CC02),
                        title: 'Guardian',
                        route: AppRoutes.adminStudentGuardian,
                      ),
                      _buildNavTile(
                        icon: Icons.school_rounded,
                        color: const Color(0xFFE17055),
                        title: 'Previous School',
                        route: AppRoutes.adminStudentPreviousSchool,
                      ),
                      _buildNavTile(
                        icon: Icons.account_balance_rounded,
                        color: const Color(0xFF6C5CE7),
                        title: 'Bank',
                        route: AppRoutes.adminStudentBank,
                      ),
                      _buildNavTile(
                        icon: Icons.receipt_rounded,
                        color: const Color(0xFFFD79A8),
                        title: 'Income',
                        route: AppRoutes.adminStudentIncome,
                      ),
                      _buildNavTile(
                        icon: Icons.category_rounded,
                        color: Colors.teal,
                        title: 'Caste',
                        route: AppRoutes.adminStudentCaste,
                      ),
                      _buildNavTile(
                        icon: Icons.description_rounded,
                        color: Colors.indigo,
                        title: 'Documents',
                        route: AppRoutes.adminStudentDocuments,
                      ),
                      _buildNavTile(
                        icon: Icons.sms_rounded,
                        color: Colors.orange,
                        title: 'SMS Details',
                        route: AppRoutes.adminStudentSmsDetails,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(StudentBriefDetails d) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: d.photoUrl.isNotEmpty ? NetworkImage(d.photoUrl) : null,
          child: d.photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.blueGrey) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.studentName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(d.email, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 6),
              Text('PRN: ${d.prn}', style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(StudentBriefDetails d) {
    final List<_InfoItem> items = [
      _InfoItem('Class', d.studentClass),
      _InfoItem('Admission Year', d.admissionYear.toString()),
      _InfoItem('Caste', d.caste),
      _InfoItem('Category', d.category),
      _InfoItem('Student Mobile', d.studentMobile),
      _InfoItem('Parent Mobile', d.parentMobile),
      _InfoItem('Address', d.address),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          for (final _InfoItem it in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(it.label, style: const TextStyle(color: Color(0xFF64748B))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(it.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            if (it != items.last) const Divider(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildNavTile({required IconData icon, required Color color, required String title, required String route}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route, arguments: {'studentId': _studentId}),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}



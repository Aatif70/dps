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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Student Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
              ? const Center(child: Text('No details found'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeaderCard(_details!),
                      const SizedBox(height: 16),
                      const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                      const SizedBox(height: 12),
                      _buildInfoGrid(_details!),
                      const SizedBox(height: 24),
                      const Text('More', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
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
                        icon: Icons.payments_rounded,
                        color: Colors.teal,
                        title: 'Fees Details',
                        route: AppRoutes.adminStudentFeesDetails,
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

  Widget _buildHeaderCard(StudentBriefDetails d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: _buildStudentAvatar(d.photoUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.studentName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(d.email, style: TextStyle(color: Colors.white.withValues(alpha:0.9))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.badge_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text('PRN ${d.prn}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          for (final _InfoItem it in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    it.label,
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(it.value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                ),
              ],
            ),
            if (it != items.last) Divider(height: 16, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }

  Widget _buildNavTile({required IconData icon, required Color color, required String title, required String route}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          final args = {'studentId': _studentId};
          // Also forward ID if available in brief details (same as search result ID)
          if (_details != null) {
            args['id'] = _details!.studentId; // often same as StudentId, included for safety
          }
          Navigator.pushNamed(context, route, arguments: args);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

  Widget _buildStudentAvatar(String photoUrl) {
    if (photoUrl.isEmpty || photoUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: 34,
        backgroundColor: Colors.white,
        child: const Icon(Icons.person, color: Colors.blueGrey, size: 34),
      );
    }

    // Validate URL format
    try {
      Uri.parse(photoUrl);
    } catch (e) {
      print('Invalid photo URL format: $photoUrl');
      return CircleAvatar(
        radius: 34,
        backgroundColor: Colors.white,
        child: const Icon(Icons.person, color: Colors.blueGrey, size: 34),
      );
    }

    return CircleAvatar(
      radius: 34,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: Image.network(
          photoUrl,
          width: 68,
          height: 68,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Image loading failed for: $photoUrl - Error: $error');
            return Container(
              width: 68,
              height: 68,
              color: Colors.white,
              child: const Icon(Icons.person, color: Colors.blueGrey, size: 34),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 68,
              height: 68,
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}



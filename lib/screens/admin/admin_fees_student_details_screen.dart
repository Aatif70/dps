import 'package:flutter/material.dart';
import 'package:AES/services/admin_student_service.dart';
import 'package:AES/constants/app_routes.dart';

class AdminFeesStudentDetailsScreen extends StatefulWidget {
  const AdminFeesStudentDetailsScreen({super.key});

  @override
  State<AdminFeesStudentDetailsScreen> createState() => _AdminFeesStudentDetailsScreenState();
}

class _AdminFeesStudentDetailsScreenState extends State<AdminFeesStudentDetailsScreen> {
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
          'Student',
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
                      _buildNavTile(
                        icon: Icons.payments_rounded,
                        color: const Color(0xFFFF7043),
                        title: 'Fees Details',
                        onTap: () {
                          final args = {'studentId': _studentId, 'id': _details?.studentId};
                          Navigator.pushNamed(context, AppRoutes.adminStudentFeesDetails, arguments: args);
                        },
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
          colors: [Color(0xFFFF8A65), Color(0xFFFF6E6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withValues(alpha:0.25),
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

  Widget _buildNavTile({required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha:0.08),
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
                color: color.withValues(alpha:0.1),
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
    );
  }

  Widget _buildStudentAvatar(String photoUrl) {
    if (photoUrl.isEmpty || photoUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: 34,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Colors.blueGrey, size: 34),
      );
    }

    try {
      Uri.parse(photoUrl);
    } catch (_) {
      return const CircleAvatar(
        radius: 34,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Colors.blueGrey, size: 34),
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
            return const Icon(Icons.person, color: Colors.blueGrey, size: 34);
          },
        ),
      ),
    );
  }
}



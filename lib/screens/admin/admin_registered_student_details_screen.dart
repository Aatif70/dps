import 'package:dps/constants/app_routes.dart';
import 'package:dps/services/admin_admissions_service.dart';
import 'package:flutter/material.dart';

class AdminRegisteredStudentDetailsScreen extends StatelessWidget {
  const AdminRegisteredStudentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisteredStudentSummary s = ModalRoute.of(context)!.settings.arguments as RegisteredStudentSummary;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Student Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header gradient card
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
                BoxShadow(color: const Color(0xFF4A90E2).withValues(alpha:0.25), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.badge_rounded, color: Colors.white.withValues(alpha:0.9), size: 16),
                      const SizedBox(width: 6),
                      Text('ID ${s.studentId}', style: TextStyle(color: Colors.white.withValues(alpha:0.95))),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Info card
          Container(
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
              children: [
                _kv('Gender', s.gender ?? '-'),
                _divider(),
                _kv('Category', s.category ?? '-'),
                _divider(),
                _kv('Religion', s.religion ?? '-'),
                _divider(),
                _kv('Aadhaar', s.adhaar ?? '-'),
                _divider(),
                _kv('Email', s.email ?? '-'),
                _divider(),
                _kv('Student Mobile', s.studentMobile ?? '-'),
                _divider(),
                _kv('Parent Mobile', s.parentMobile ?? '-'),
                _divider(),
                _kv('Academic Year', s.acadYear ?? '-'),
                _divider(),
                _kv('Requested Class', s.className ?? '-'),
                _divider(),
                _kv('Eligible/Approved', s.approveForAdmission ? 'Yes' : 'No'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.adminAdmissionAllotment,
                  arguments: s,
                );
              },
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Approve / Allot Class & Subjects'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(k, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 16, color: Colors.grey.shade200);
}



import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';

import '../../constants/api_constants.dart';

class AdminStudentPersonalScreen extends StatefulWidget {
  const AdminStudentPersonalScreen({super.key});

  @override
  State<AdminStudentPersonalScreen> createState() => _AdminStudentPersonalScreenState();
}

class _AdminStudentPersonalScreenState extends State<AdminStudentPersonalScreen> {
  StudentPersonalDetail? _data;
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
    setState(() {
      _loading = true;
    });
    final StudentPersonalDetail? d = await AdminStudentService.fetchStudentPersonalDetail(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No data'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeaderCard(_data!),
                      const SizedBox(height: 16),
                      _sectionTitle('Profile'),
                      _card([
                        _kv('Gender', _data!.gender),
                        _kv('Blood Group', _data!.bloodGroup),
                        _kv('Nationality', _data!.nationality),
                        _kv('Date of Birth', _data!.dateOfBirth),
                        _kv('Place of Birth', _data!.placeOfBirth),
                        _kv('Religion', _data!.religion),
                      ]),
                      const SizedBox(height: 16),
                      _sectionTitle('Contact'),
                      _card([
                        _kv('Contact No', _data!.contactNo),
                        _kv('Address', _data!.address),
                        _kv('City', _data!.city),
                        _kv('Pincode', _data!.pincode),
                        _kv('State', _data!.state),
                        if (_data!.district != null) _kv('District', _data!.district!),
                      ]),
                      const SizedBox(height: 16),
                      _sectionTitle('Identifiers'),
                      _card([
                        _kv('Aadhaar', _data!.aadhaarCardNo),
                        if (_data!.panCardNo != null) _kv('PAN', _data!.panCardNo!),
                        _kv('School PRN', _data!.schoolPRN),
                      ]),
                      const SizedBox(height: 16),
                      _sectionTitle('Parents'),
                      _card([
                        _kv('Father Name', _data!.fatherName),
                        _kv('Father Contact', _data!.fatherContact),
                        _kv('Mother Name', _data!.motherName),
                        _kv('Mother Contact', _data!.motherContact),
                      ]),
                      const SizedBox(height: 16),
                      _sectionTitle('Admission'),
                      _card([
                        _kv('Admission Cancel', _data!.admissionCancel),
                        _kv('Class', _data!.studentClass),
                        _kv('Category', _data!.category),
                        _kv('Academic Year', _data!.academicYear),
                      ]),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderCard(StudentPersonalDetail d) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF357ABD)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white,
              backgroundImage: d.photo.isNotEmpty ? NetworkImage('${ApiConstants.baseUrl}${d.photo}') : null,
              child: d.photo.isEmpty ? const Icon(Icons.person, color: Colors.blueGrey) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.studentName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  d.email,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('Class ${d.studentClass}'),
                    _chip(d.academicYear),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)));

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) Divider(height: 16, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 160, child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}



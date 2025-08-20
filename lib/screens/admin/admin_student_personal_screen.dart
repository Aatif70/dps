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
      appBar: AppBar(title: const Text('Personal Details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No data'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(_data!),
                      const SizedBox(height: 16),
                      _buildKeyValue('Gender', _data!.gender),
                      _buildKeyValue('Blood Group', _data!.bloodGroup),
                      _buildKeyValue('Nationality', _data!.nationality),
                      _buildKeyValue('Date of Birth', _data!.dateOfBirth),
                      _buildKeyValue('Place of Birth', _data!.placeOfBirth),
                      _buildKeyValue('Aadhaar', _data!.aadhaarCardNo),
                      if (_data!.panCardNo != null) _buildKeyValue('PAN', _data!.panCardNo!),
                      _buildKeyValue('Religion', _data!.religion),
                      _buildKeyValue('Contact No', _data!.contactNo),
                      _buildKeyValue('Address', _data!.address),
                      _buildKeyValue('City', _data!.city),
                      _buildKeyValue('Pincode', _data!.pincode),
                      _buildKeyValue('State', _data!.state),
                      if (_data!.district != null) _buildKeyValue('District', _data!.district!),
                      _buildKeyValue('Father Name', _data!.fatherName),
                      _buildKeyValue('Mother Name', _data!.motherName),
                      _buildKeyValue('Father Contact', _data!.fatherContact),
                      _buildKeyValue('Mother Contact', _data!.motherContact),
                      _buildKeyValue('School PRN', _data!.schoolPRN),
                      _buildKeyValue('Admission Cancel', _data!.admissionCancel),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(StudentPersonalDetail d) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: d.photo.isNotEmpty ? NetworkImage('${ApiConstants.baseUrl}${d.photo}') : null,
          child: d.photo.isEmpty ? const Icon(Icons.person, color: Colors.blueGrey) : null,
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
              Text('Class: ${d.studentClass} • ${d.academicYear}', style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyValue(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Color(0xFF64748B)))),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}



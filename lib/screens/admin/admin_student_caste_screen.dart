import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';

class AdminStudentCasteScreen extends StatefulWidget {
  const AdminStudentCasteScreen({super.key});

  @override
  State<AdminStudentCasteScreen> createState() => _AdminStudentCasteScreenState();
}

class _AdminStudentCasteScreenState extends State<AdminStudentCasteScreen> {
  CasteReligionDetail? _data;
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
    final CasteReligionDetail? d = await AdminStudentService.fetchCasteReligionDetail(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caste & Religion')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No caste details'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _kv('Religion', _data!.religion),
                      _kv('Category', _data!.category),
                      if (_data!.caste != null) _kv('Caste', _data!.caste!),
                      if (_data!.subCaste != null) _kv('Sub Caste', _data!.subCaste!),
                      _kv('Caste Certificate', _data!.castCertificate),
                      _kv('Certificate No', _data!.certificateNo),
                      _kv('Issued Date', _data!.issuedDate),
                      _kv('Bar Code', _data!.barCode),
                      _kv('Issued Authority', _data!.issuedAuthority),
                      _kv('Caste Validity', _data!.castValidity),
                      _kv('Cast Val No', _data!.castValNo),
                      _kv('Cast Val Date', _data!.castValDate),
                      _kv('Cast Val Code', _data!.castValCode),
                      _kv('Obtained Authority', _data!.casteValObtnAuthority),
                      _kv('Non-Creamy Layer', _data!.nonCreamyLayer),
                      _kv('NOCL No', _data!.noclNo),
                      _kv('NCL Date', _data!.nonCLDate),
                      _kv('NCL Barcode', _data!.nclBarcode),
                      _kv('NCL Issued Authority', _data!.nclIssuedAuthority),
                    ],
                  ),
                ),
    );
  }

  Widget _kv(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: const TextStyle(color: Color(0xFF64748B)))),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}



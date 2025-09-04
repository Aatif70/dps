import 'package:flutter/material.dart';
import 'package:AES/services/admin_student_service.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Caste & Religion', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No caste details'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
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
                            _kv('Religion', _data!.religion),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Category', _data!.category),
                            if (_data!.caste != null) ...[
                              Divider(height: 16, color: Colors.grey.shade200),
                              _kv('Caste', _data!.caste!),
                            ],
                            if (_data!.subCaste != null) ...[
                              Divider(height: 16, color: Colors.grey.shade200),
                              _kv('Sub Caste', _data!.subCaste!),
                            ],
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Caste Certificate', _data!.castCertificate),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Certificate No', _data!.certificateNo),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Issued Date', _data!.issuedDate),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Bar Code', _data!.barCode),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Issued Authority', _data!.issuedAuthority),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Caste Validity', _data!.castValidity),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Cast Val No', _data!.castValNo),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Cast Val Date', _data!.castValDate),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Cast Val Code', _data!.castValCode),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Obtained Authority', _data!.casteValObtnAuthority),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('Non-Creamy Layer', _data!.nonCreamyLayer),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('NOCL No', _data!.noclNo),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('NCL Date', _data!.nonCLDate),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('NCL Barcode', _data!.nclBarcode),
                            Divider(height: 16, color: Colors.grey.shade200),
                            _kv('NCL Issued Authority', _data!.nclIssuedAuthority),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _kv(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 160, child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))),
      ],
    );
  }
}



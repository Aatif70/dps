import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';

class AdminStudentDocumentsScreen extends StatefulWidget {
  const AdminStudentDocumentsScreen({super.key});

  @override
  State<AdminStudentDocumentsScreen> createState() => _AdminStudentDocumentsScreenState();
}

class _AdminStudentDocumentsScreenState extends State<AdminStudentDocumentsScreen> {
  List<DocumentCategory> _cats = [];
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
    final List<DocumentCategory> list = await AdminStudentService.fetchStudentDocuments(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _cats = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Documents', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _cats.isEmpty
                  ? const Center(child: Text('No documents'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final DocumentCategory c = _cats[index];
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.category, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                              const SizedBox(height: 8),
                              ...c.documents.map((d) => Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF4A90E2)),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(d.docType, style: const TextStyle(fontWeight: FontWeight.w600))),
                                        if (d.documentUrl != null)
                                          TextButton(
                                            onPressed: () {
                                              // open URL using suitable plugin in future
                                            },
                                            child: const Text('View'),
                                          )
                                        else
                                          const Text('Missing', style: TextStyle(color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _cats.length,
                    ),
            ),
    );
  }
}



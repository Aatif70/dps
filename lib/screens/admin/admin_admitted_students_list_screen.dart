import 'package:dps/services/admin_admitted_students_service.dart';
import 'package:dps/services/admin_classes_service.dart';
import 'package:flutter/material.dart';

class AdminAdmittedStudentsListScreen extends StatefulWidget {
  const AdminAdmittedStudentsListScreen({super.key});

  @override
  State<AdminAdmittedStudentsListScreen> createState() => _AdminAdmittedStudentsListScreenState();
}

class _AdminAdmittedStudentsListScreenState extends State<AdminAdmittedStudentsListScreen> {
  BatchItem? _selectedBatch;
  bool _loadingBatches = true;
  bool _loadingList = false;
  List<BatchItem> _batches = <BatchItem>[];
  List<AdmittedStudentItem> _items = <AdmittedStudentItem>[];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _loadingBatches = true);
    final batches = await AdminClassesService.fetchBatches();
    if (!mounted) return;
    setState(() {
      _batches = batches;
      _loadingBatches = false;
    });
  }

  Future<void> _loadAdmitted() async {
    final batch = _selectedBatch;
    if (batch == null) return;
    setState(() => _loadingList = true);
    final list = await AdminAdmittedStudentsService.fetchAdmittedStudents(classId: batch.classId);
    if (!mounted) return;
    setState(() {
      _items = list;
      _loadingList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? _items
        : _items.where((e) => ('${e.name} ${e.rollNo} ${e.batch} ${e.className}').toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Admitted Students',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedBatch != null) {
            await _loadAdmitted();
          } else {
            await _loadBatches();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(),
            const SizedBox(height: 16),
            _filters(),
            const SizedBox(height: 16),
            if (_loadingList)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_selectedBatch == null)
              _hintCard('Please select a class to view admitted students')
            else if (filtered.isEmpty)
              _hintCard('No admitted students')
            else
              ...filtered.map(_itemCard).toList(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
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
          BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Admissions - Admitted', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 6),
              Text('Students currently admitted', style: TextStyle(color: Colors.white.withOpacity(0.95))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
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
          const Text('Class', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          DropdownButtonFormField<BatchItem>(
            value: _selectedBatch,
            items: _batches.map((e) => DropdownMenuItem(value: e, child: Text(e.batchName))).toList(),
            onChanged: (v) {
              setState(() => _selectedBatch = v);
              _loadAdmitted();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: _loadingBatches ? 'Loading...' : 'Select class',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by name, roll no, batch',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            onChanged: (v) => setState(() => _query = v.trim()),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(AdmittedStudentItem s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6)),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person_rounded, color: Color(0xFF4A90E2)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Wrap(spacing: 10, runSpacing: 6, children: [
                  _chip('${s.className} • ${s.batch}'),
                  _chip('Roll ${s.rollNo}'),
                  _chip('Year ${s.admissionYear}')
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(t, style: const TextStyle(color: Color(0xFF64748B))),
    );
  }

  Widget _hintCard(String t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Center(child: Text(t)),
    );
  }
}



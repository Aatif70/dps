import 'package:dps/constants/app_routes.dart';
import 'package:dps/services/admin_exams_service.dart';
import 'package:flutter/material.dart';

class AdminExamsListScreen extends StatefulWidget {
  const AdminExamsListScreen({super.key});

  @override
  State<AdminExamsListScreen> createState() => _AdminExamsListScreenState();
}

class _AdminExamsListScreenState extends State<AdminExamsListScreen> {
  late Future<List<AdminExamItem>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = AdminExamsService.fetchExams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Internal Exams',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: FutureBuilder<List<AdminExamItem>>(
        future: _future,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final items = snapshot.data ?? <AdminExamItem>[];
          final filtered = _query.isEmpty
              ? items
              : items.where((e) => ('${e.title} ${e.className} ${e.session}').toLowerCase().contains(_query.toLowerCase())).toList();
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _future = AdminExamsService.fetchExams());
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _header(loading, items.length),
                const SizedBox(height: 16),
                _search(),
                const SizedBox(height: 16),
                if (snapshot.hasError)
                  _error('${snapshot.error}')
                else if (loading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (filtered.isEmpty)
                  _hint('No exams found')
                else
                  ...filtered.map(_examCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(bool loading, int count) {
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
          BoxShadow(color: const Color(0xFF4A90E2).withValues(alpha:0.25), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.fact_check_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Internal Exams', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            if (loading)
              const LinearProgressIndicator(minHeight: 3, color: Colors.white)
            else
              Wrap(spacing: 10, runSpacing: 10, children: [
                _pill('Total Exams', count.toString()),
              ]),
          ]),
        ),
      ]),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.15), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white24)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.analytics_outlined, color: Colors.white, size: 14),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _search() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search by title, class, session',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
          onChanged: (v) => setState(() => _query = v.trim()),
        ),
      ),
    );
  }

  Widget _examCard(AdminExamItem e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRoutes.adminExamMarks, arguments: e),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 6)),
            ],
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF4A90E2).withValues(alpha:0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.event_note_rounded, color: Color(0xFF4A90E2)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    Wrap(spacing: 10, runSpacing: 6, children: [
                      _chip(e.className),
                      _chip(e.session),
                      if (e.isActive) _chip('Active'),
                    ]),
                  ]),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Wrap(spacing: 16, runSpacing: 10, children: [
              _kv('Start', _fmtDate(e.startDate)),
              _kv('End', _fmtDate(e.endDate)),
              _kv('Result', _fmtDate(e.resultDate)),
              _kv('Type', e.type.toString()),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String t) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)), child: Text(t, style: const TextStyle(color: Color(0xFF64748B))));
  Widget _kv(String k, String v) => Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 80, child: Text(k, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600))), const SizedBox(width: 6), Text(v, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))]);
  Widget _error(String e) => _hint('Error: $e');
  Widget _hint(String t) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))), child: Center(child: Text(t)));
  String _fmtDate(DateTime? d) => d == null ? '-' : '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year.toString()}';
}



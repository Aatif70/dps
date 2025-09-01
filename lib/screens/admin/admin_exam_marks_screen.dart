import 'package:dps/services/admin_exams_service.dart';
import 'package:flutter/material.dart';

class AdminExamMarksScreen extends StatefulWidget {
  const AdminExamMarksScreen({super.key});

  @override
  State<AdminExamMarksScreen> createState() => _AdminExamMarksScreenState();
}

class _AdminExamMarksScreenState extends State<AdminExamMarksScreen> {
  late Future<List<ExamMarksItem>> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AdminExamItem e = ModalRoute.of(context)!.settings.arguments as AdminExamItem;
    _future = AdminExamsService.fetchExamMarks(examId: e.examId);
  }

  @override
  Widget build(BuildContext context) {
    final AdminExamItem e = ModalRoute.of(context)!.settings.arguments as AdminExamItem;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '${e.title} - ${e.className}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: FutureBuilder<List<ExamMarksItem>>(
        future: _future,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final items = snapshot.data ?? <ExamMarksItem>[];
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = AdminExamsService.fetchExamMarks(examId: e.examId);
              });
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _header(e, loading, items.length),
                const SizedBox(height: 16),
                if (snapshot.hasError)
                  _hint('Error: ${snapshot.error}')
                else if (loading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (items.isEmpty)
                  _hint('No marks found')
                else
                  ...items.map(_studentCard).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(AdminExamItem e, bool loading, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF357ABD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF4A90E2).withValues(alpha:0.25), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${e.title} • ${e.className}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            if (loading)
              const LinearProgressIndicator(minHeight: 3, color: Colors.white)
            else
              Wrap(spacing: 10, runSpacing: 10, children: [
                _pill('Students', count.toString()),
                _pill('Session', e.session),
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

  Widget _studentCard(ExamMarksItem s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 6))],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF4A90E2).withValues(alpha:0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person_rounded, color: Color(0xFF4A90E2))),
            const SizedBox(width: 14),
            Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))),
          ]),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          _marksTable(s.subMarks),
        ]),
      ),
    );
  }

  Widget _marksTable(List<ExamSubjectMark> marks) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: [
        _rowHeader(),
        for (final m in marks) _row(m),
      ]),
    );
  }

  Widget _rowHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
      child: Row(children: const [
        Expanded(flex: 3, child: Text('Subject', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)))),
        SizedBox(width: 8),
        Expanded(child: Text('Min', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700))),
        SizedBox(width: 8),
        Expanded(child: Text('Max', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700))),
        SizedBox(width: 8),
        Expanded(child: Text('Marks', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700))),
        SizedBox(width: 8),
        Expanded(flex: 2, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700))),
      ]),
    );
  }

  Widget _row(ExamSubjectMark m) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        Expanded(flex: 3, child: Text(m.subjectName)),
        const SizedBox(width: 8),
        Expanded(child: Text(m.minMarks.toString(), textAlign: TextAlign.center)),
        const SizedBox(width: 8),
        Expanded(child: Text(m.maxMarks.toString(), textAlign: TextAlign.center)),
        const SizedBox(width: 8),
        Expanded(child: Text(m.attemptMarks.toString(), textAlign: TextAlign.center)),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: _statusPill(m.statusName)),
      ]),
    );
  }

  Widget _statusPill(String status) {
    final normalized = status.toUpperCase();
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF64748B);
    if (normalized == 'PASS') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF166534);
    } else if (normalized == 'FAIL') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFF991B1B);
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)), child: Text(normalized, textAlign: TextAlign.center, style: TextStyle(color: fg, fontWeight: FontWeight.w700)));
  }

  Widget _hint(String t) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))), child: Center(child: Text(t)));
}



import 'package:dps/services/student_exam_service.dart';
import 'package:flutter/material.dart';

class StudentExamResultsScreen extends StatefulWidget {
  final StudentExamItem exam;

  const StudentExamResultsScreen({super.key, required this.exam});

  @override
  State<StudentExamResultsScreen> createState() => _StudentExamResultsScreenState();
}

class _StudentExamResultsScreenState extends State<StudentExamResultsScreen> {
  late Future<List<StudentExamMarksItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = StudentExamService.fetchStudentExamMarks(examId: widget.exam.examId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.exam.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: FutureBuilder<List<StudentExamMarksItem>>(
        future: _future,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final items = snapshot.data ?? <StudentExamMarksItem>[];
          
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _future = StudentExamService.fetchStudentExamMarks(examId: widget.exam.examId));
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _examHeader(),
                const SizedBox(height: 16),
                if (snapshot.hasError)
                  _error('${snapshot.error}')
                else if (loading)
                  const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                else if (items.isEmpty)
                  _hint('No results available yet')
                else
                  _studentResultCard(items),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _examHeader() {
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.assessment_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.exam.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 6),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _pill('Subjects', '${widget.exam.subjects.length}'),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Divider(color: Colors.white.withValues(alpha:0.3)),
        const SizedBox(height: 12),
        Wrap(spacing: 16, runSpacing: 10, children: [
          _headerKv('Start Date', _fmtDate(widget.exam.startDate)),
          _headerKv('End Date', _fmtDate(widget.exam.endDate)),
          _headerKv('Result Date', _fmtDate(widget.exam.resultDate)),
        ]),
      ]),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.15), borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.white24)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _headerKv(String k, String v) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 80, child: Text(k, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))),
      const SizedBox(width: 6),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
    ]);
  }

  Widget _studentResultCard(List<StudentExamMarksItem> marks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                child: const Icon(Icons.person_rounded, color: Color(0xFF4A90E2)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your Results', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B), fontSize: 16)),
                  const SizedBox(height: 4),
                  if (marks.isNotEmpty)
                    Text('Student ID: ${marks.first.studentId}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          ...marks.map(_subjectMarkCard).toList(),
        ]),
      ),
    );
  }

  Widget _subjectMarkCard(StudentExamMarksItem subject) {
    final percentage = subject.maxMarks > 0 ? (subject.theoryMarks / subject.maxMarks * 100) : 0.0;
    final isPass = subject.status == 'PASS';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPass ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPass ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(subject.subjectName, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Row(children: [
                Text('${subject.theoryMarks}/${subject.maxMarks}', style: TextStyle(fontWeight: FontWeight.w700, color: isPass ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                const SizedBox(width: 8),
                Text('(${percentage.toStringAsFixed(1)}%)', style: TextStyle(color: isPass ? const Color(0xFF059669) : const Color(0xFFDC2626))),
                if (subject.isPrac) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(4)),
                    child: const Text('Practical', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
              if (subject.isPrac && subject.practicalMarks > 0) ...[
                const SizedBox(height: 4),
                Text('Practical: ${subject.practicalMarks}/${subject.pMaxMarks}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPass ? const Color(0xFF059669) : const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              subject.status,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _error(String e) => _hint('Error: $e');
  Widget _hint(String t) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))), child: Center(child: Text(t)));
  String _fmtDate(DateTime? d) => d == null ? '-' : '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year.toString()}';
}

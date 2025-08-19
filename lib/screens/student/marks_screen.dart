import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/services/student_marks_service.dart';

class MarksScreen extends StatefulWidget {
  const MarksScreen({Key? key}) : super(key: key);

  @override
  State<MarksScreen> createState() => _MarksScreenState();
}

class _MarksScreenState extends State<MarksScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  List<StudentExam> _exams = [];
  StudentExam? _selectedExam;
  List<StudentSubjectMark> _marks = [];

  late AnimationController _fadeController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _loadExamsAndMarks();
  }

  Future<void> _loadExamsAndMarks() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      final exams = await StudentMarksService.getStudentExams();
      _exams = exams;
      if (_exams.isNotEmpty) {
        _selectedExam = _exams.first;
        _marks = await StudentMarksService.getStudentMarks(examId: _selectedExam!.examId);
      }
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load results: $e';
      });
    }
  }

  Future<void> _onExamChanged(StudentExam? exam) async {
    if (exam == null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedExam = exam;
      _isLoading = true;
      _marks = [];
    });
    final marks = await StudentMarksService.getStudentMarks(examId: exam.examId);
    setState(() {
      _marks = marks;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Results', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _loadExamsAndMarks,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF4A90E2).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.refresh, color: Color(0xFF4A90E2), size: 20),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2))))
          : _hasError
              ? _buildError()
              : FadeTransition(
                  opacity: _fade,
                  child: _exams.isEmpty
                      ? _buildEmpty()
                      : Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildExamPicker(context),
                            const SizedBox(height: 12),
                            Expanded(child: _buildMarksList(context)),
                          ],
                        ),
                ),
    );
  }

  Widget _buildExamPicker(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
      ]),
      child: Row(
        children: [
          const Icon(Icons.event_note_rounded, color: Color(0xFF4A90E2)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<StudentExam>(
              isExpanded: true,
              value: _selectedExam,
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: _exams
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
              onChanged: _onExamChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarksList(BuildContext context) {
    if (_marks.isEmpty) {
      return Center(
        child: Text('No marks available', style: TextStyle(color: Colors.grey.shade600)),
      );
    }
    final totalObtained = _marks.fold<double>(0, (sum, m) => sum + m.totalMarks);
    final totalMax = _marks.fold<int>(0, (sum, m) => sum + m.maxMarks);
    final overallPercent = totalMax > 0 ? (totalObtained / totalMax) * 100.0 : 0.0;

    return Column(
      children: [
        _buildOverallCard(overallPercent, totalObtained, totalMax),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _marks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = _marks[index];
              return _buildSubjectTile(m);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverallCard(double overallPercent, double totalObtained, int totalMax) {
    final pass = overallPercent >= 35;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (pass ? const Color(0xFF58CC02) : const Color(0xFFE74C3C)).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(pass ? Icons.emoji_events_rounded : Icons.warning_amber_rounded, color: pass ? const Color(0xFF58CC02) : const Color(0xFFE74C3C)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Overall Percentage', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${overallPercent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              Text('Total: ${totalObtained.toStringAsFixed(0)} / $totalMax', style: TextStyle(color: Colors.grey.shade600)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(StudentSubjectMark m) {
    final percent = m.percentage;
    final pass = m.status.toUpperCase() == 'PASS' || percent >= 35;
    final color = pass ? const Color(0xFF58CC02) : const Color(0xFFE74C3C);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
      ]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.book_rounded, color: color),
        ),
        title: Text(m.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        subtitle: Text(
            () {
              final pracText = m.isPrac ? ' + ${m.practicalMarks}' : '';
              return 'Marks: ${m.theoryMarks}$pracText / ${m.maxMarks}  •  Min: ${m.minMarks}';
            }(),
            style: TextStyle(color: Colors.grey.shade600)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${percent.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
            Text(m.status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No exams available', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text('Failed to load results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade600)),
            const SizedBox(height: 6),
            Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF718096))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadExamsAndMarks,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}



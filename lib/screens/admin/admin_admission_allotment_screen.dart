import 'package:dps/services/admin_admissions_service.dart';
import 'package:dps/services/admin_classes_service.dart';
import 'package:flutter/material.dart';
import 'package:dps/widgets/custom_snackbar.dart';

class AdminAdmissionAllotmentScreen extends StatefulWidget {
  const AdminAdmissionAllotmentScreen({super.key});

  @override
  State<AdminAdmissionAllotmentScreen> createState() => _AdminAdmissionAllotmentScreenState();
}

class _AdminAdmissionAllotmentScreenState extends State<AdminAdmissionAllotmentScreen> {
  BatchItem? _selectedBatch;
  DivisionLite? _selectedDivision;
  PracticalBatch? _selectedPractical;
  final Set<int> _selectedSubjectIds = <int>{};
  bool _submitting = false;
  bool _loadingBatches = true;
  bool _loadingDivisions = false;
  bool _loadingSubjects = false;
  bool _loadingPracticals = false;
  final TextEditingController _yearCtl = TextEditingController();
  DateTime _admissionDate = DateTime.now();

  List<BatchItem> _batches = <BatchItem>[];
  List<DivisionLite> _divisions = <DivisionLite>[];
  List<SubjectOption> _subjects = <SubjectOption>[];
  List<PracticalBatch> _practicals = <PracticalBatch>[];

  @override
  void initState() {
    super.initState();
    _yearCtl.text = DateTime.now().year.toString();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _loadingBatches = true);
    final items = await AdminClassesService.fetchBatches();
    if (!mounted) return;
    setState(() {
      _batches = items;
      _loadingBatches = false;
    });
  }

  Future<void> _onClassChanged(BatchItem? batch) async {
    print('[Allotment] Class changed -> ${batch?.batchName} (ClassId: ${batch?.classId})');
    setState(() {
      _selectedBatch = batch;
      _selectedDivision = null;
      _selectedPractical = null;
      _divisions = <DivisionLite>[];
      _practicals = <PracticalBatch>[];
      _subjects = <SubjectOption>[];
    });
    if (batch == null) return;
    setState(() {
      _loadingDivisions = true;
      _loadingSubjects = true;
    });
    final divisions = await AdminAdmissionsService.fetchDivisionsByClass(classId: batch.classId);
    final subjects = await AdminAdmissionsService.fetchClasswiseSubjects(classId: batch.classId);
    if (!mounted) return;
    print('[Allotment] Divisions fetched for ClassId=${batch.classId} -> count=${divisions.length}');
    print('[Allotment] Subjects fetched for ClassId=${batch.classId} -> count=${subjects.length}');
    setState(() {
      _divisions = divisions;
      _subjects = subjects;
      _selectedSubjectIds
        ..clear()
        ..addAll(subjects.where((e) => e.checked).map((e) => e.subId));
      _loadingDivisions = false;
      _loadingSubjects = false;
    });
  }

  Future<void> _onDivisionChanged(DivisionLite? div) async {
    print('[Allotment] Division changed -> ${div?.name} (DivisionId: ${div?.divisionId})');
    setState(() {
      _selectedDivision = div;
      _selectedPractical = null;
      _practicals = <PracticalBatch>[];
      _loadingPracticals = true;
    });
    if (div == null) {
      setState(() => _loadingPracticals = false);
      return;
    }
    final practicals = await AdminAdmissionsService.fetchPracticalBatches(divisionId: div.divisionId);
    if (!mounted) return;
    print('[Allotment] Practicals fetched for DivisionId=${div.divisionId} -> count=${practicals.length}');
    setState(() {
      _practicals = practicals;
      _loadingPracticals = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final RegisteredStudentSummary s = ModalRoute.of(context)!.settings.arguments as RegisteredStudentSummary;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Allot Class & Subjects',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha:0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 6),
                    Text('Requested: ${s.className ?? '-'} • ${s.acadYear ?? '-'}', style: TextStyle(color: Colors.white.withValues(alpha:0.95))),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            children: [
              const Text('Class', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              DropdownButtonFormField<BatchItem>(
                value: _selectedBatch,
                items: _batches
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.batchName)))
                    .toList(),
                onChanged: (v) => _onClassChanged(v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Select class',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Division', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              DropdownButtonFormField<DivisionLite>(
                value: _selectedDivision,
                items: _divisions.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (v) => _onDivisionChanged(v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Select division',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Practical Batch', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              DropdownButtonFormField<PracticalBatch>(
                value: _selectedPractical,
                items: _practicals.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => _selectedPractical = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: _loadingPracticals ? 'Loading...' : 'Select practical batch',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Admission Year', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              TextField(
                controller: _yearCtl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'e.g. ${DateTime.now().year}',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Admission Date', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _admissionDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _admissionDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF8FAFC),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(_fmtDate(_admissionDate), style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Subjects', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subjects.map((subj) {
                  final selected = _selectedSubjectIds.contains(subj.subId);
                  return FilterChip(
                    selected: selected,
                    label: Text(subj.name),
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedSubjectIds.add(subj.subId);
                        } else {
                          _selectedSubjectIds.remove(subj.subId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting
                  ? null
                  : () async {
                      if (_selectedBatch == null || _selectedDivision == null || _selectedSubjectIds.isEmpty) {
                        CustomSnackbar.showError(context, message: 'Please select class, division and at least one subject');
                        return;
                      }
                      if (_selectedPractical == null) {
                        CustomSnackbar.showWarning(context, message: 'Please select a practical batch');
                        return;
                      }
                      final int? year = int.tryParse(_yearCtl.text.trim());
                      if (year == null) {
                        CustomSnackbar.showError(context, message: 'Please enter a valid admission year');
                        return;
                      }
                      setState(() => _submitting = true);
                      final RegisteredStudentSummary s = ModalRoute.of(context)!.settings.arguments as RegisteredStudentSummary;
                      final success = await AdminAdmissionsService.createAdmission(
                        studentId: s.studentId,
                        classId: _selectedBatch!.classId,
                        divisionId: _selectedDivision!.divisionId,
                        admissionYear: year,
                        admissionDateIso: _isoDate(_admissionDate),
                        practicalId: _selectedPractical!.practicalId,
                        subjects: _subjects
                            .map((opt) => SubjectSelection(subId: opt.subId, isChecked: _selectedSubjectIds.contains(opt.subId)))
                            .toList(),
                      );
                      if (!mounted) return;
                      setState(() => _submitting = false);
                      if (success) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        CustomSnackbar.showSuccess(context, message: 'Admission approved successfully');
                      } else {
                        CustomSnackbar.showError(context, message: 'Failed to approve admission');
                      }
                    },
              icon: const Icon(Icons.check_circle_rounded),
              label: Text(_submitting ? 'Submitting...' : 'Approve Admission'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  String _fmtDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _isoDate(DateTime d) => _fmtDate(d);
}



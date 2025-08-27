import 'package:dps/services/admin_admissions_service.dart';
import 'package:flutter/material.dart';

class AdminAdmissionAllotmentScreen extends StatefulWidget {
  const AdminAdmissionAllotmentScreen({super.key});

  @override
  State<AdminAdmissionAllotmentScreen> createState() => _AdminAdmissionAllotmentScreenState();
}

class _AdminAdmissionAllotmentScreenState extends State<AdminAdmissionAllotmentScreen> {
  String? _selectedClass;
  String? _selectedDivision;
  final Set<String> _selectedSubjects = <String>{};
  bool _submitting = false;

  // Placeholder data; these should be replaced by actual API calls if available
  final List<String> _classes = <String>['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'];
  final List<String> _divisions = <String>['A', 'B', 'C', 'D'];
  final List<String> _subjects = <String>['English', 'Marathi', 'Hindi', 'Maths', 'Science', 'History', 'Geography'];

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
                BoxShadow(color: const Color(0xFF4A90E2).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 6),
                    Text('Requested: ${s.className ?? '-'} • ${s.acadYear ?? '-'}', style: TextStyle(color: Colors.white.withOpacity(0.95))),
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
              DropdownButtonFormField<String>(
                value: _selectedClass,
                items: _classes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedClass = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Select class',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Division', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedDivision,
                items: _divisions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedDivision = v),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Select division',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Subjects', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subjects.map((subj) {
                  final selected = _selectedSubjects.contains(subj);
                  return FilterChip(
                    selected: selected,
                    label: Text(subj),
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _selectedSubjects.add(subj);
                        } else {
                          _selectedSubjects.remove(subj);
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
                      if (_selectedClass == null || _selectedDivision == null || _selectedSubjects.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select class, division and at least one subject')));
                        return;
                      }
                      setState(() => _submitting = true);
                      await Future.delayed(const Duration(milliseconds: 600));
                      if (!mounted) return;
                      setState(() => _submitting = false);
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admission approved successfully')));
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6)),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}



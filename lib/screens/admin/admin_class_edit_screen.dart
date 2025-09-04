import 'package:flutter/material.dart';
import 'package:AES/services/admin_classes_service.dart';
import 'package:AES/widgets/custom_snackbar.dart';

class AdminClassEditScreen extends StatefulWidget {
  final int classMasterId;
  final String className;
  final String rollNoPrefix;
  final int courseYear;

  const AdminClassEditScreen({
    super.key,
    required this.classMasterId,
    required this.className,
    required this.rollNoPrefix,
    required this.courseYear,
  });

  @override
  State<AdminClassEditScreen> createState() => _AdminClassEditScreenState();
}

class _AdminClassEditScreenState extends State<AdminClassEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _className;
  late final TextEditingController _rollNoPrefix;
  late final TextEditingController _courseYear;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _className = TextEditingController(text: widget.className);
    _rollNoPrefix = TextEditingController(text: widget.rollNoPrefix);
    _courseYear = TextEditingController(text: widget.courseYear.toString());
  }

  @override
  void dispose() {
    _className.dispose();
    _rollNoPrefix.dispose();
    _courseYear.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await AdminClassesService.updateClass(
      classMasterId: widget.classMasterId,
      className: _className.text.trim(),
      rollNoPrefix: _rollNoPrefix.text.trim(),
      courseYear: int.parse(_courseYear.text.trim()),
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    if (ok) {
      CustomSnackbar.showSuccess(context, message: 'Class updated successfully');
      Navigator.pop(context, true);
    } else {
      CustomSnackbar.showError(context, message: 'Failed to update class');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Edit Class',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Class Name', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _className,
                  decoration: _inputDecoration('Enter class name', Icons.class_),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                const Text('Roll No Prefix', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rollNoPrefix,
                  decoration: _inputDecoration('Enter roll no prefix', Icons.confirmation_number_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                const Text('Course Year', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _courseYear,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Enter course year', Icons.calendar_today_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final year = int.tryParse(v.trim());
                    if (year == null || year < 1900) return 'Enter valid year';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Update Class', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF718096), size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF718096), fontSize: 14),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:AES/services/admin_classes_service.dart';
import 'package:AES/widgets/custom_snackbar.dart';

class AdminClassCreateScreen extends StatefulWidget {
  const AdminClassCreateScreen({super.key});

  @override
  State<AdminClassCreateScreen> createState() => _AdminClassCreateScreenState();
}

class _AdminClassCreateScreenState extends State<AdminClassCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _className = TextEditingController();
  final TextEditingController _rollNoPrefix = TextEditingController();
  final TextEditingController _courseYear = TextEditingController();
  bool _submitting = false;

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
    final ok = await AdminClassesService.createClass(
      className: _className.text.trim(),
      rollNoPrefix: _rollNoPrefix.text.trim(),
      courseYear: int.parse(_courseYear.text.trim()),
    );
    setState(() => _submitting = false);
    if (!mounted) return;
    if (ok) {
      CustomSnackbar.showSuccess(context, message: 'Class created successfully');
      Navigator.pop(context, true);
    } else {
      CustomSnackbar.showError(context, message: 'Failed to create class');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Add Class',
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
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Create Class', style: TextStyle(fontWeight: FontWeight.w600)),
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
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF718096), fontSize: 14),
    );
  }
}



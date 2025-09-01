import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/teacher_homework_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/widgets/custom_snackbar.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> {
  List<TeacherHomework> _homeworkList = [];
  List<TeacherHomework> _filteredHomeworkList = [];
  bool _isLoading = true;

  // Date range for fetching data
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  String _selectedSubjectFilter = 'All';
  Set<String> _availableSubjects = {'All'};

  @override
  void initState() {
    super.initState();
    _loadHomeworkData();
    _searchController.addListener(_filterHomework);
  }

  void _showHomeworkPreview(TeacherHomework homework) {
    final String url = homework.docUrl;
    if (url.isEmpty) {
      CustomSnackbar.showWarning(context, message: 'No attachment available');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Homework Attachment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: InteractiveViewer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  height: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Could not load attachment',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  height: 200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeworkData() async {
    setState(() => _isLoading = true);
    try {
      final homeworkList = await TeacherHomeworkService.getHomeworkList(
        fromDate: _fromDate,
        toDate: _toDate,
      );

      setState(() {
        _homeworkList = homeworkList;
        _filteredHomeworkList = homeworkList;
        _availableSubjects = {'All', ...homeworkList.map((hw) => hw.subject)};
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading homework data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterHomework() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHomeworkList = _homeworkList.where((hw) {
        final matchesSearch = hw.homeWork.toLowerCase().contains(query) ||
            hw.subject.toLowerCase().contains(query) ||
            hw.className.toLowerCase().contains(query);
        final matchesSubject = _selectedSubjectFilter == 'All' ||
            hw.subject == _selectedSubjectFilter;
        return matchesSearch && matchesSubject;
      }).toList();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF58CC02),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadHomeworkData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          AppStrings.homework,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF58CC02)),
            onPressed: _loadHomeworkData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF58CC02)))
          : Column(
        children: [
          _buildHeaderSection(),
          _buildSearchAndFilters(),
          Expanded(child: _buildHomeworkList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateHomeworkDialog(context),
        backgroundColor: const Color(0xFF58CC02),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Homework Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateFormat('MMM dd').format(_fromDate)} - ${DateFormat('MMM dd, yyyy').format(_toDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 140,
                  minHeight: 40,
                  maxHeight: 40,
                ),
                child: ElevatedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: const Text('Change'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 20),
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildStatCard(
          //         'Homework',
          //         _homeworkList.length.toString(),
          //         const Color(0xFF58CC02),
          //         Icons.assignment,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildStatCard(
          //         'This Week',
          //         _homeworkList.where((hw) =>
          //             hw.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))
          //         ).length.toString(),
          //         const Color(0xFF4A90E2),
          //         Icons.today,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildStatCard(
          //         'Subjects',
          //         (_availableSubjects.length - 1).toString(), // -1 to exclude 'All'
          //         const Color(0xFF8E44AD),
          //         Icons.subject,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search homework...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF58CC02)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF58CC02)),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          // Show error if selected subject is not in the available subjects
          if (!_availableSubjects.contains(_selectedSubjectFilter)) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected subject "$_selectedSubjectFilter" is not available. Please select another.',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Filter by Subject:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _availableSubjects.contains(_selectedSubjectFilter)
                      ? _selectedSubjectFilter
                      : 'All',
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _availableSubjects.map((subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(
                        subject,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSubjectFilter = value;
                      });
                      _filterHomework();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkList() {
    if (_filteredHomeworkList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredHomeworkList.length,
      itemBuilder: (context, index) {
        return _buildHomeworkCard(_filteredHomeworkList[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No homework found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or date range',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(TeacherHomework homework) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getSubjectColor(homework.subject).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getSubjectIcon(homework.subject),
                    color: _getSubjectColor(homework.subject),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homework.subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${homework.className} - Division ${homework.division}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Batch: ${homework.batch}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (homework.doc != null && homework.doc!.isNotEmpty)
                  InkWell(
                    onTap: () => _showHomeworkPreview(homework),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF58CC02).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.attachment_rounded,
                        color: Color(0xFF58CC02),
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                homework.homeWork,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF2D3748),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.grey.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(homework.date),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  'By: ${homework.employee}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            if (homework.doc != null && homework.doc!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showHomeworkPreview(homework),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Preview Attachment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods remain the same
  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'maths':
        return const Color(0xFF4A90E2);
      case 'science':
        return const Color(0xFF58CC02);
      case 'english':
        return const Color(0xFF8E44AD);
      case 'physics':
        return const Color(0xFFFF9500);
      case 'marathi':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'maths':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.menu_book;
      case 'physics':
        return Icons.flash_on;
      case 'marathi':
        return Icons.language;
      default:
        return Icons.school;
    }
  }

  void _showCreateHomeworkDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateHomeworkForm(),
    );
  }
}

// CreateHomeworkForm remains exactly the same as in your original code
class CreateHomeworkForm extends StatefulWidget {
  const CreateHomeworkForm({Key? key}) : super(key: key);

  @override
  State<CreateHomeworkForm> createState() => _CreateHomeworkFormState();
}

class _CreateHomeworkFormState extends State<CreateHomeworkForm> {
  final _formKey = GlobalKey<FormState>();
  final _homeworkController = TextEditingController();

  // Dropdown data
  List<Course> _courses = [];
  List<Batch> _batches = [];
  List<Division> _divisions = [];
  List<Subject> _subjects = [];

  // Selected values
  Course? _selectedCourse;
  Batch? _selectedBatch;
  Division? _selectedDivision;
  Subject? _selectedSubject;
  DateTime _selectedDate = DateTime.now();
  File? _selectedFile;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _homeworkController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final courses = await TeacherHomeworkService.getCourses();
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBatches() async {
    if (_selectedCourse == null) return;
    setState(() => _isLoading = true);
    try {
      final batches = await TeacherHomeworkService.getBatches(_selectedCourse!.courseMasterId);
      setState(() {
        _batches = batches;
        _selectedBatch = null;
        _divisions.clear();
        _subjects.clear();
        _selectedDivision = null;
        _selectedSubject = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDivisions() async {
    if (_selectedBatch == null) {
      debugPrint('[DEBUG] _loadDivisions: No batch selected');
      return;
    }

    debugPrint('[DEBUG] _loadDivisions: Fetching divisions for ClassId: ${_selectedBatch!.classId}');
    setState(() => _isLoading = true);
    try {
      final divisions = await TeacherHomeworkService.getDivisions(_selectedBatch!.classId);
      debugPrint('[DEBUG] _loadDivisions: Divisions fetched: ${divisions.map((d) => d.name).toList()}');
      setState(() {
        _divisions = divisions;
        _selectedDivision = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[DEBUG] _loadDivisions: Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubjects() async {
    if (_selectedBatch == null) {
      debugPrint('[DEBUG] _loadSubjects: No batch selected');
      return;
    }

    debugPrint('[DEBUG] _loadSubjects: Fetching subjects for ClassMasterId: ${_selectedBatch!.classMasterId}');
    setState(() => _isLoading = true);
    try {
      final subjects = await TeacherHomeworkService.getSubjects(_selectedBatch!.classMasterId);
      debugPrint('[DEBUG] _loadSubjects: Subjects fetched: ${subjects.map((s) => s.subjectName).toList()}');
      setState(() {
        _subjects = subjects;
        _selectedSubject = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[DEBUG] _loadSubjects: Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      CustomSnackbar.showError(context, message: 'Error picking file: $e');
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _submitHomework() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null || _selectedBatch == null || _selectedDivision == null) {
      CustomSnackbar.showError(context, message: 'Please fill all required fields');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final success = await TeacherHomeworkService.addHomework(
        subjectId: _selectedSubject!.subjectId,
        date: _selectedDate,
        classMasterId: _selectedBatch!.classMasterId,
        classId: _selectedBatch!.classId,
        divisionId: _selectedDivision!.divisionId,
        homework: _homeworkController.text,
        file: _selectedFile,
      );
      if (success) {
        Navigator.pop(context);
        CustomSnackbar.showSuccess(context, message: 'Homework created successfully!');
      } else {
        CustomSnackbar.showError(context, message: 'Failed to create homework');
      }
    } catch (e) {
      CustomSnackbar.showError(context, message: 'Error: $e');
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Create Homework',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Course Dropdown
                    DropdownButtonFormField<Course>(
                      decoration: const InputDecoration(
                        labelText: 'Course',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school_outlined),
                      ),
                      value: _selectedCourse,
                      items: _courses.map((course) {
                        return DropdownMenuItem<Course>(
                          value: course,
                          child: Text(course.courseName),
                        );
                      }).toList(),
                      onChanged: (course) {
                        setState(() {
                          _selectedCourse = course;
                          debugPrint('[DEBUG] Selected Course: ${course?.courseName}, id: ${course?.courseMasterId}');
                        });
                        _loadBatches();
                      },
                      validator: (value) => value == null ? 'Please select a course' : null,
                    ),
                    const SizedBox(height: 16),
                    // Batch Dropdown
                    DropdownButtonFormField<Batch>(
                      decoration: const InputDecoration(
                        labelText: 'Class',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.class_outlined),
                      ),
                      value: _selectedBatch,
                      items: _batches.map((batch) {
                        return DropdownMenuItem<Batch>(
                          value: batch,
                          child: Text(batch.batchName),
                        );
                      }).toList(),
                      onChanged: (batch) {
                        setState(() {
                          _selectedBatch = batch;
                          debugPrint('[DEBUG] Selected Batch: ${batch?.batchName}, ClassId: ${batch?.classId}, ClassMasterId: ${batch?.classMasterId}');
                          _selectedDivision = null;
                          _divisions = [];
                        });
                        _loadDivisions();
                        _loadSubjects();
                      },
                      validator: (value) => value == null ? 'Please select a class' : null,
                    ),
                    const SizedBox(height: 16),
                    // Division Dropdown
                    DropdownButtonFormField<Division>(
                      decoration: const InputDecoration(
                        labelText: 'Division',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      value: _selectedDivision,
                      items: _divisions.map((division) {
                        return DropdownMenuItem<Division>(
                          value: division,
                          child: Text(division.name),
                        );
                      }).toList(),
                      onChanged: (division) {
                        setState(() {
                          _selectedDivision = division;
                          debugPrint('[DEBUG] Selected Division: ${division?.name}, id: ${division?.divisionId}');
                        });
                      },
                      validator: (value) => value == null ? 'Please select a division' : null,
                    ),
                    const SizedBox(height: 16),
                    // Subject Dropdown
                    DropdownButtonFormField<Subject>(
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subject_outlined),
                      ),
                      value: _selectedSubject,
                      items: _subjects.map<DropdownMenuItem<Subject>>((Subject subject) {
                        return DropdownMenuItem<Subject>(
                          value: subject,
                          child: Text(subject.subjectName),
                        );
                      }).toList(),
                      onChanged: (Subject? subject) {
                        setState(() {
                          _selectedSubject = subject;
                        });
                      },
                      validator: (Subject? value) => value == null ? 'Please select a subject' : null,
                    ),
                    const SizedBox(height: 16),
                    // Date Picker
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      controller: TextEditingController(
                        text: DateFormat('MMM dd, yyyy').format(_selectedDate),
                      ),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    // Homework Description
                    TextFormField(
                      controller: _homeworkController,
                      decoration: const InputDecoration(
                        labelText: 'Homework Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter homework description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // File Attachment
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          if (_selectedFile != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.attach_file, color: Color(0xFF58CC02)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedFile!.path.split('/').last,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFile = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ] else ...[
                            GestureDetector(
                              onTap: _pickFile,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.attach_file, color: Color(0xFF58CC02)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Attach File (Optional)',
                                    style: TextStyle(
                                      color: Color(0xFF58CC02),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitHomework,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF58CC02),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Create Homework',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

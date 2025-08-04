import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/teacher_homework_service.dart';


class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // Real data from API
  List<TeacherHomework> _homeworkList = [];
  bool _isLoading = true;

  // Date range for fetching data
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHomeworkData();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading homework data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeHomework = _homeworkList;
    final completedHomework = <TeacherHomework>[]; // You can filter based on your logic

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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF58CC02),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF58CC02),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildActiveHomeworkTab(activeHomework),
          _buildCompletedHomeworkTab(completedHomework),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateHomeworkDialog(context);
        },
        backgroundColor: const Color(0xFF58CC02),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActiveHomeworkTab(List<TeacherHomework> homework) {
    if (homework.isEmpty) {
      return _buildEmptyState('No homework found', 'Create homework by tapping the + button');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHomeworkSummary(homework),
          const SizedBox(height: 24),
          Text(
            'Homework List',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...homework.map((hw) => _buildHomeworkCard(hw)).toList(),
        ],
      ),
    );
  }

  Widget _buildCompletedHomeworkTab(List<TeacherHomework> homework) {
    if (homework.isEmpty) {
      return _buildEmptyState('No completed homework', 'Completed homework will appear here');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: homework.length,
      itemBuilder: (context, index) {
        return _buildHomeworkCard(homework[index]);
      },
    );
  }

  Widget _buildEmptyState(String title, String message) {
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
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkSummary(List<TeacherHomework> homework) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Homework Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    homework.length.toString(),
                    const Color(0xFF58CC02),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'This Week',
                    homework.where((hw) =>
                        hw.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))
                    ).length.toString(),
                    const Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
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
                    color: _getSubjectColor(homework.subject).withOpacity(0.1),
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
                    ],
                  ),
                ),
                if (homework.doc != null && homework.doc!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.attachment_rounded,
                      color: Color(0xFF58CC02),
                      size: 16,
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
          ],
        ),
      ),
    );
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
}

// Create Homework Form Widget
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
      print('[DEBUG] _loadDivisions: No batch selected');
      return;
    }
    print('[DEBUG] _loadDivisions: Fetching divisions for ClassId: ${_selectedBatch!.classId}');
    setState(() => _isLoading = true);
    try {
      final divisions = await TeacherHomeworkService.getDivisions(_selectedBatch!.classId);
      print('[DEBUG] _loadDivisions: Divisions fetched: ${divisions.map((d) => d.name).toList()}');
      setState(() {
        _divisions = divisions;
        _selectedDivision = null;
        _isLoading = false;
      });
    } catch (e) {
      print('[DEBUG] _loadDivisions: Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubjects() async {
    if (_selectedBatch == null) {
      print('[DEBUG] _loadSubjects: No batch selected');
      return;
    }
    print('[DEBUG] _loadSubjects: Fetching subjects for ClassMasterId: ${_selectedBatch!.classMasterId}');
    setState(() => _isLoading = true);
    try {
      final subjects = await TeacherHomeworkService.getSubjects(_selectedBatch!.classMasterId);
      print('[DEBUG] _loadSubjects: Subjects fetched: ${subjects.map((s) => s.subjectName).toList()}');
      setState(() {
        _subjects = subjects;
        _selectedSubject = null;
        _isLoading = false;
      });
    } catch (e) {
      print('[DEBUG] _loadSubjects: Error: $e');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Homework created successfully!'),
            backgroundColor: Color(0xFF58CC02),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create homework'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
                        return DropdownMenuItem(
                          value: course,
                          child: Text(course.courseName),
                        );
                      }).toList(),
                      onChanged: (course) {
                        setState(() {
                          _selectedCourse = course;
                          print('[DEBUG] Selected Course: ${course?.courseName}, id: ${course?.courseMasterId}');
                        });
                        _loadBatches();
                        // _loadSubjects(); // REMOVED
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
                        return DropdownMenuItem(
                          value: batch,
                          child: Text(batch.batchName),
                        );
                      }).toList(),
                      onChanged: (batch) {
                        setState(() {
                          _selectedBatch = batch;
                          print('[DEBUG] Selected Batch: ${batch?.batchName}, ClassId: ${batch?.classId}, ClassMasterId: ${batch?.classMasterId}');
                          _selectedDivision = null; // Reset division when batch changes
                          _divisions = [];          // Reset divisions list
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
                        return DropdownMenuItem(
                          value: division,
                          child: Text(division.name),
                        );
                      }).toList(),
                      onChanged: (division) {
                        setState(() {
                          _selectedDivision = division;
                          print('[DEBUG] Selected Division: ${division?.name}, id: ${division?.divisionId}');
                        });
                      },
                      validator: (value) => value == null ? 'Please select a division' : null,
                    ),
                    const SizedBox(height: 16),

                    // Subject Dropdown
                    DropdownButtonFormField<Subject>(  // ← Add generic type
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subject_outlined),
                      ),
                      value: _selectedSubject,
                      items: _subjects.map<DropdownMenuItem<Subject>>((Subject subject) {  // ← Add explicit typing
                        return DropdownMenuItem<Subject>(  // ← Add generic type
                          value: subject,
                          child: Text(subject.subjectName),
                        );
                      }).toList(),
                      onChanged: (Subject? subject) {  // ← Add type parameter
                        setState(() {
                          _selectedSubject = subject;
                        });
                      },
                      validator: (Subject? value) => value == null ? 'Please select a subject' : null,  // ← Add type
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

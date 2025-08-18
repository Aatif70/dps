import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/services/teacher_attendance_service.dart';
import 'package:intl/intl.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  AnimationController? _animationController;
  AnimationController? _slideAnimationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  DateTime _selectedDate = DateTime.now();

  // API Data
  List<ClassData> _classes = [];
  List<BatchData> _batches = [];
  List<DivisionData> _divisions = [];
  List<SubjectData> _subjects = [];

  // Selected Values
  ClassData? _selectedClass;
  BatchData? _selectedBatch;
  DivisionData? _selectedDivision;
  SubjectData? _selectedSubject;

  // Loading States
  bool _isLoadingClasses = false;
  bool _isLoadingBatches = false;
  bool _isLoadingDivisions = false;
  bool _isLoadingSubjects = false;
  bool _isLoadingStudents = false;

  // UI State
  bool _isParametersConfirmed = false;
  bool _showParametersCard = true;

  // UPDATED: Real students data instead of mock
  List<AttendanceStudent> _students = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAnimation();
    _loadClasses();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -1),
    ).animate(CurvedAnimation(
      parent: _slideAnimationController!,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController?.dispose();
    _slideAnimationController?.dispose();
    super.dispose();
  }

  // UPDATED: Load real students data instead of generating mock data
  Future<void> _loadStudentList() async {
    if (!_canShowStudentList()) {
      print('Cannot load students - missing parameters');
      return;
    }

    setState(() => _isLoadingStudents = true);

    try {
      print('=== LOADING STUDENT LIST ===');
      final students = await TeacherAttendanceService.getAttendanceStudentList(
        subjectId: _selectedSubject!.subjectId,
        classId: _selectedBatch!.classId,
        divisionId: _selectedDivision!.divisionId,
      );

      setState(() {
        _students = students;
      });

      print('Loaded ${_students.length} students successfully');
    } catch (e) {
      print('Error loading students: $e');
      _showErrorSnackBar('Failed to load students');
    } finally {
      setState(() => _isLoadingStudents = false);
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF4A90E2),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Confirm Selection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please confirm your selection:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildConfirmationRow('Class', _selectedClass?.className ?? ''),
                      const SizedBox(height: 8),
                      _buildConfirmationRow('Batch', _selectedBatch?.batch ?? ''),
                      const SizedBox(height: 8),
                      _buildConfirmationRow('Division', _selectedDivision?.name ?? ''),
                      const SizedBox(height: 8),
                      _buildConfirmationRow('Subject', _selectedSubject?.subjectName ?? ''),
                      const SizedBox(height: 8),
                      _buildConfirmationRow('Date', DateFormat('dd MMM yyyy').format(_selectedDate)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'This will load students for attendance marking.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmParameters();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmParameters() {
    setState(() {
      _isParametersConfirmed = true;
    });

    _slideAnimationController?.forward().then((_) {
      setState(() {
        _showParametersCard = false;
      });
      // Load real students instead of generating mock data
      _loadStudentList().then((_) {
        _animationController?.forward();
      });
    });
  }

  void _resetSelection() {
    setState(() {
      _isParametersConfirmed = false;
      _showParametersCard = true;
    });
    _slideAnimationController?.reset();
    _animationController?.reset();
    _resetSelections();
  }

  // Keep all existing API loading methods unchanged
  Future<void> _loadClasses() async {
    setState(() => _isLoadingClasses = true);
    try {
      final classes = await TeacherAttendanceService.getClassesByEmpId();
      setState(() {
        _classes = classes;
        _resetSelections();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load classes');
    } finally {
      setState(() => _isLoadingClasses = false);
    }
  }

  Future<void> _loadBatches(int classMasterId) async {
    setState(() => _isLoadingBatches = true);
    try {
      final batches = await TeacherAttendanceService.getBatchesByEmpId(classMasterId);
      setState(() {
        _batches = batches;
        _selectedBatch = null;
        _selectedDivision = null;
        _divisions.clear();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load batches');
    } finally {
      setState(() => _isLoadingBatches = false);
    }
  }

  Future<void> _loadDivisions(int classId) async {
    setState(() => _isLoadingDivisions = true);
    try {
      final divisions = await TeacherAttendanceService.getDivisionsByClassId(classId);
      setState(() {
        _divisions = divisions;
        _selectedDivision = null;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load divisions');
    } finally {
      setState(() => _isLoadingDivisions = false);
    }
  }

  Future<void> _loadSubjects(int classMasterId) async {
    setState(() => _isLoadingSubjects = true);
    try {
      final subjects = await TeacherAttendanceService.getSubjectsByEmpId(classMasterId);
      setState(() {
        _subjects = subjects;
        _selectedSubject = null;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load subjects');
    } finally {
      setState(() => _isLoadingSubjects = false);
    }
  }

  void _resetSelections() {
    setState(() {
      _selectedClass = null;
      _selectedBatch = null;
      _selectedDivision = null;
      _selectedSubject = null;
      _batches.clear();
      _divisions.clear();
      _subjects.clear();
      _students.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  bool _canShowStudentList() {
    return _selectedClass != null &&
        _selectedBatch != null &&
        _selectedDivision != null &&
        _selectedSubject != null;
  }

  int _getCompletedSteps() {
    int steps = 0;
    if (_selectedClass != null) steps++;
    if (_selectedBatch != null) steps++;
    if (_selectedDivision != null) steps++;
    if (_selectedSubject != null) steps++;
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.attendance),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
        actions: _isParametersConfirmed ? [
          IconButton(
            onPressed: _resetSelection,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Selection',
          ),
        ] : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4A90E2),
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: const Color(0xFF4A90E2),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Mark Attendance'),
                Tab(text: 'Reports'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarkAttendanceTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildMarkAttendanceTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_showParametersCard)
            SlideTransition(
              position: _slideAnimation!,
              child: _buildParameterSelectionCard(),
            ),
          if (_isParametersConfirmed)
            _buildSelectedParametersSummary(),
          if (_isParametersConfirmed)
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  (kToolbarHeight + 48 + 100 + (_isParametersConfirmed ? 80 : 0)),
              child: _buildStudentList(),
            )
          else if (!_showParametersCard)
            const SizedBox.shrink()
          else
            SizedBox(
              height: 200,
              child: _buildEmptyState(),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedParametersSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF4A90E2),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_selectedClass?.className} - ${_selectedDivision?.name} | ${_selectedSubject?.subjectName}',
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_students.length} Students',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Keep all the existing parameter selection card methods...
  Widget _buildParameterSelectionCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildNewCardHeader(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewDateSelector(),
                  const SizedBox(height: 24),
                  _buildNewParametersGrid(),
                  if (_canShowStudentList()) ...[
                    const SizedBox(height: 32),
                    _buildProceedButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // No longer generate mock students, just show confirmation
          _showConfirmationDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Text(
              'Proceed to Attendance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep all existing header and date selector methods...
  Widget _buildNewCardHeader() {
    final completedSteps = _getCompletedSteps();
    final progress = completedSteps / 4.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90E2),
            const Color(0xFF357ABD).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Attendance Setup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completedSteps/4',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete all fields to proceed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4A90E2).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF4A90E2),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Date',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF4A90E2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewParametersGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNewParameterField<ClassData>(
                label: 'Select Class',
                selectedItem: _selectedClass,
                hint: 'Class',
                items: _classes.map((e) => DropdownMenuItem(value: e, child: Text(e.className))).toList(),
                isLoading: _isLoadingClasses,
                icon: Icons.school_outlined,
                onChanged: _isLoadingClasses ? null : (ClassData? value) {
                  setState(() => _selectedClass = value);
                  if (value != null) {
                    _loadBatches(value.classMasterId);
                    _loadSubjects(value.classMasterId);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNewParameterField<BatchData>(
                label: 'Select Batch',
                selectedItem: _selectedBatch,
                hint: 'Batch',
                items: _batches.map((e) => DropdownMenuItem(value: e, child: Text(e.batch))).toList(),
                isLoading: _isLoadingBatches,
                isEnabled: _selectedClass != null,
                icon: Icons.groups_outlined,
                onChanged: (_selectedClass == null || _isLoadingBatches) ? null : (BatchData? value) {
                  setState(() => _selectedBatch = value);
                  if (value != null) {
                    _loadDivisions(value.classId);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildNewParameterField<DivisionData>(
                label: 'Select Division',
                selectedItem: _selectedDivision,
                hint: 'Division',
                items: _divisions.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                isLoading: _isLoadingDivisions,
                isEnabled: _selectedBatch != null,
                icon: Icons.class_outlined,
                onChanged: (_selectedBatch == null || _isLoadingDivisions) ? null : (DivisionData? value) {
                  setState(() {
                    _selectedDivision = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNewParameterField<SubjectData>(
                label: 'Select Subject',
                selectedItem: _selectedSubject,
                hint: 'Subject',
                items: _subjects.map((e) => DropdownMenuItem(value: e, child: Text(e.subjectName))).toList(),
                isLoading: _isLoadingSubjects,
                isEnabled: _selectedClass != null,
                icon: Icons.book_outlined,
                onChanged: (_selectedClass == null || _isLoadingSubjects || _subjects.isEmpty) ? null : (SubjectData? value) {
                  setState(() {
                    _selectedSubject = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNewParameterField<T>({
    required String label,
    required T? selectedItem,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required Function(T?)? onChanged,
    required IconData icon,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    final List<T> itemValues = items.map((e) => e.value).whereType<T>().toList();
    final bool isInItems = selectedItem != null && itemValues.contains(selectedItem);
    final T? dropdownValue = isInItems ? selectedItem : null;
    final bool showInvalidSelection = selectedItem != null && !isInItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isEnabled ? const Color(0xFF2C3E50) : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isEnabled ? Colors.white : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled
                  ? (dropdownValue != null
                  ? const Color(0xFF4A90E2).withOpacity(0.3)
                  : Colors.grey.shade300)
                  : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              if (isEnabled && dropdownValue != null)
                BoxShadow(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(
              hintText: isLoading ? 'Loading...' : hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: isLoading
                  ? Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.all(14),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    const Color(0xFF4A90E2).withOpacity(0.7),
                  ),
                ),
              )
                  : Icon(
                icon,
                color: isEnabled
                    ? (dropdownValue != null
                    ? const Color(0xFF4A90E2)
                    : Colors.grey.shade500)
                    : Colors.grey.shade400,
                size: 20,
              ),
            ),
            value: dropdownValue,
            items: items,
            onChanged: isEnabled && !isLoading ? onChanged : null,
            icon: const SizedBox.shrink(),
            style: TextStyle(
              color: isEnabled ? const Color(0xFF2C3E50) : Colors.grey.shade500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            isExpanded: true,
            menuMaxHeight: 200,
          ),
        ),
        AnimatedOpacity(
          opacity: showInvalidSelection ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: showInvalidSelection
              ? Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Color(0xFFEF4444)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Previous selection is unavailable. Please reselect.',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              size: 48,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to Mark Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete all fields above to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (_isLoadingStudents) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF4A90E2),
            ),
            SizedBox(height: 16),
            Text(
              'Loading students...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      );
    }

    return _fadeAnimation != null
        ? FadeTransition(
      opacity: _fadeAnimation!,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                return _buildStudentCard(_students[index], index);
              },
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    )
        : Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              return _buildStudentCard(_students[index], index);
            },
          ),
        ),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildStudentCard(AttendanceStudent student, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: student.attendanceStatus
                ? const Color(0xFF10B981).withOpacity(0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
                child: Text(
                  student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : '?',
                  style: const TextStyle(
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Roll No: ${student.studentRollNo}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAttendanceToggle(student),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceToggle(AttendanceStudent student) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAttendanceButton(
          student,
          true,
          'P',
          const Color(0xFF10B981),
          student.attendanceStatus == true,
        ),
        const SizedBox(width: 8),
        _buildAttendanceButton(
          student,
          false,
          'A',
          const Color(0xFFEF4444),
          student.attendanceStatus == false,
        ),
      ],
    );
  }

  Widget _buildAttendanceButton(
      AttendanceStudent student,
      bool status,
      String label,
      Color color,
      bool isSelected,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          student.attendanceStatus = status;
        });
        print('Updated ${student.name} attendance to: $status');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: isSelected ? 0 : 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () async {
            print('=== SUBMIT ATTENDANCE CLICKED ===');

            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving attendance...'),
                  ],
                ),
              ),
            );

            try {
              // Format date for API (dd-MM-yyyy format)
              final formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);

              final success = await TeacherAttendanceService.saveAttendance(
                attendanceDate: formattedDate,
                subjectId: _selectedSubject!.subjectId,
                classMasterId: _selectedClass!.classMasterId,
                classId: _selectedBatch!.classId,
                divisionId: _selectedDivision!.divisionId,
                students: _students,
              );

              Navigator.of(context).pop(); // Close loading dialog

              if (success) {
                final presentCount = _students.where((s) => s.attendanceStatus == true).length;
                final absentCount = _students.where((s) => s.attendanceStatus == false).length;

                _showSuccessSnackBar(
                    'Attendance saved successfully! Present: $presentCount, Absent: $absentCount'
                );
              } else {
                _showErrorSnackBar('Failed to save attendance. Please try again.');
              }
            } catch (e) {
              Navigator.of(context).pop(); // Close loading dialog
              print('Error saving attendance: $e');
              _showErrorSnackBar('Error saving attendance: $e');
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Submit Attendance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A90E2),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildReportsTab() {
    return const Center(
      child: Text(
        'Reports functionality will be implemented here',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

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

  // Mock students data (replace with actual API call later)
  List<Student> _students = [];

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

  // Generate mock students when all parameters are selected
  void _generateMockStudents() {
    setState(() {
      _students = List.generate(
        20, // Reduced number for better performance
            (index) => Student(
          id: 'STU${10001 + index}',
          name: 'Student ${index + 1}',
          rollNumber: (index + 1).toString().padLeft(2, '0'),
          profileImage: '',
          attendanceHistory: {},
        ),
      );
    });
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
          content: Column(
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
              Text(
                'This will load ${_students.length} students for attendance marking.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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

    // Hide the parameters card with animation
    _slideAnimationController?.forward().then((_) {
      setState(() {
        _showParametersCard = false;
      });
      // Show students with fade animation
      _animationController?.forward();
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
    return Column(
      children: [
        if (_showParametersCard)
          SlideTransition(
            position: _slideAnimation!,
            child: _buildParameterSelectionCard(),
          ),
        if (_isParametersConfirmed)
          _buildSelectedParametersSummary(),
        if (_isParametersConfirmed)
          Expanded(child: _buildStudentList())
        else if (!_showParametersCard)
          const SizedBox.shrink()
        else
          Expanded(child: _buildEmptyState()),
      ],
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

  Widget _buildParameterSelectionCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                _buildDateSelector(),
                const SizedBox(height: 20),
                _buildParameterGrid(),
                if (_canShowStudentList()) ...[
                  const SizedBox(height: 20),
                  _buildConfirmButton(),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _generateMockStudents();
          _showConfirmationDialog();
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
          'Proceed to Attendance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }



  Widget _buildCardHeader() {
    final completedSteps = _getCompletedSteps();
    final progress = completedSteps / 4.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Select Parameters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completedSteps/4',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }



  Widget _buildDateSelector() {
    const SizedBox(height: 22);
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade50,
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
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
            const SizedBox(width: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // Include all the other existing methods like _buildParameterGrid, _buildStudentList, etc.
  // For brevity, I'm showing the key structural changes. The rest of the methods remain the same.

  Widget _buildParameterGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildParameterDropdown<ClassData>(
              label: 'Class',
              value: _selectedClass?.className,
              items: _classes.map((e) => DropdownMenuItem(value: e, child: Text(e.className))).toList(),
              isLoading: _isLoadingClasses,
              onChanged: _isLoadingClasses ? null : (ClassData? value) {
                setState(() => _selectedClass = value);
                if (value != null) {
                  _loadBatches(value.classMasterId);
                  _loadSubjects(value.classMasterId);
                }
              },
              icon: Icons.school,
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildParameterDropdown<BatchData>(
              label: 'Batch',
              value: _selectedBatch?.batch,
              items: _batches.map((e) => DropdownMenuItem(value: e, child: Text(e.batch))).toList(),
              isLoading: _isLoadingBatches,
              isEnabled: _selectedClass != null,
              onChanged: (_selectedClass == null || _isLoadingBatches) ? null : (BatchData? value) {
                setState(() => _selectedBatch = value);
                if (value != null) {
                  _loadDivisions(value.classId);
                }
              },
              icon: Icons.group,
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildParameterDropdown<DivisionData>(
              label: 'Division',
              value: _selectedDivision?.name,
              items: _divisions.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
              isLoading: _isLoadingDivisions,
              isEnabled: _selectedBatch != null,
              onChanged: (_selectedBatch == null || _isLoadingDivisions) ? null : (DivisionData? value) {
                setState(() {
                  _selectedDivision = value;
                });
              },
              icon: Icons.class_,
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildParameterDropdown<SubjectData>(
              label: 'Subject',
              value: _selectedSubject?.subjectName,
              items: _subjects.map((e) => DropdownMenuItem(value: e, child: Text(e.subjectName))).toList(),
              isLoading: _isLoadingSubjects,
              isEnabled: _selectedClass != null,
              onChanged: (_selectedClass == null || _isLoadingSubjects || _subjects.isEmpty) ? null : (SubjectData? value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
              icon: Icons.book,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildParameterDropdown<T>({
    required String label,
    required String? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?)? onChanged,
    required IconData icon,
    bool isLoading = false,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isEnabled ? const Color(0xFF2C3E50) : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          decoration: InputDecoration(
            hintText: isLoading ? 'Loading...' : 'Select $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: isLoading
                ? Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(12),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF4A90E2)),
              ),
            )
                : Icon(icon, color: isEnabled ? const Color(0xFF4A90E2) : Colors.grey.shade400),
            filled: !isEnabled,
            fillColor: Colors.grey.shade100,
          ),
          value: items.any((item) => item.value.toString() == value) ? items.firstWhere((item) => item.value.toString() == value).value : null,
          items: items,
          onChanged: isEnabled && !isLoading ? onChanged : null,
          icon: const SizedBox.shrink(),
          style: TextStyle(
            color: isEnabled ? const Color(0xFF2C3E50) : Colors.grey.shade500,
            fontSize: 14,
          ),
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select All Parameters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose class, batch, division, and subject\nto proceed with attendance',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
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

  Widget _buildStudentCard(Student student, int index) {
    final attendance = student.attendanceHistory[_selectedDate] ?? AttendanceStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: attendance == AttendanceStatus.present
                ? const Color(0xFF10B981).withOpacity(0.3)
                : attendance == AttendanceStatus.absent
                ? const Color(0xFFEF4444).withOpacity(0.3)
                : Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'student_${student.id}',
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
                  child: Text(
                    student.name.substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                      'Roll No: ${student.rollNumber}',
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

  Widget _buildAttendanceToggle(Student student) {
    final currentStatus = student.attendanceHistory[_selectedDate] ?? AttendanceStatus.pending;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAttendanceButton(
          student,
          AttendanceStatus.present,
          'P',
          const Color(0xFF10B981),
          currentStatus == AttendanceStatus.present,
        ),
        const SizedBox(width: 8),
        _buildAttendanceButton(
          student,
          AttendanceStatus.absent,
          'A',
          const Color(0xFFEF4444),
          currentStatus == AttendanceStatus.absent,
        ),
      ],
    );
  }

  Widget _buildAttendanceButton(
      Student student,
      AttendanceStatus status,
      String label,
      Color color,
      bool isSelected,
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          student.attendanceHistory[_selectedDate] = status;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
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
              fontSize: 16,
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
          onPressed: () {
            final markedStudents = _students.where((student) =>
            student.attendanceHistory[_selectedDate] != null &&
                student.attendanceHistory[_selectedDate] != AttendanceStatus.pending
            ).length;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Attendance saved for $markedStudents students!'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
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

// Keep the existing data models
class Student {
  final String id;
  final String name;
  final String rollNumber;
  final String profileImage;
  final Map<DateTime, AttendanceStatus> attendanceHistory;

  Student({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.profileImage,
    required this.attendanceHistory,
  });
}

enum AttendanceStatus { present, absent, pending }

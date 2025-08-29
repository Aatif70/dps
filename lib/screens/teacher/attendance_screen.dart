import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/services/teacher_attendance_service.dart';
import 'package:intl/intl.dart';
import 'package:dps/widgets/custom_snackbar.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen>
    with TickerProviderStateMixin {
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

  // NEW: Attendance Records Tab
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoadingRecords = false;

  @override
  void initState() {
    super.initState();
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
      CustomSnackbar.showError(context, message: 'Failed to load students');
    } finally {
      setState(() => _isLoadingStudents = false);
    }
  }

  // NEW: Load attendance records for date range
  Future<void> _loadAttendanceRecords() async {
    print('=== LOADING ATTENDANCE RECORDS ===');
    print('From Date: ${DateFormat('dd-MM-yyyy').format(_fromDate)}');
    print('To Date: ${DateFormat('dd-MM-yyyy').format(_toDate)}');

    setState(() => _isLoadingRecords = true);

    try {
      final records = await TeacherAttendanceService.getAttendanceRecords(
        fromDate: DateFormat('dd-MM-yyyy').format(_fromDate),
        toDate: DateFormat('dd-MM-yyyy').format(_toDate),
      );

      setState(() {
        _attendanceRecords = records;
      });

      print('Loaded ${_attendanceRecords.length} attendance records successfully');
    } catch (e) {
      print('Error loading attendance records: $e');
      CustomSnackbar.showError(context, message: 'Failed to load attendance records');
    } finally {
      setState(() => _isLoadingRecords = false);
    }
  }

  // NEW: Navigate to attendance details screen
  void _navigateToAttendanceDetails(AttendanceRecord record) {
    print('=== NAVIGATING TO ATTENDANCE DETAILS ===');
    print('Attendance ID: ${record.attId}');
    print('Date: ${record.attDate}');
    print('Subject: ${record.subjectName}');
    print('Class: ${record.className}');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttendanceDetailsScreen(attendanceRecord: record),
      ),
    );
  }

  // NEW: Show date range picker for records
  Future<void> _showDateRangePicker() async {
    print('=== SHOWING DATE RANGE PICKER ===');
    
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _fromDate,
        end: _toDate,
      ),
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

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      print('Date range selected: ${DateFormat('dd-MM-yyyy').format(_fromDate)} to ${DateFormat('dd-MM-yyyy').format(_toDate)}');
      _loadAttendanceRecords();
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
    CustomSnackbar.showError(context, message: message);
  }

  void _showSuccessSnackBar(String message) {
    CustomSnackbar.showSuccess(context, message: message);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: const TabBar(
            labelColor: Color(0xFF4A90E2),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF4A90E2),
            tabs: [
              Tab(
                icon: Icon(Icons.add_circle_outline),
                text: 'Mark Attendance',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'View Records',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMarkAttendanceTab(),
            _buildViewRecordsTab(),
          ],
        ),
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

  // NEW: View Records Tab
  Widget _buildViewRecordsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 16),
          _buildAttendanceRecordsList(),
        ],
      ),
    );
  }

  // NEW: Date Range Selector
  Widget _buildDateRangeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.date_range,
                  color: Color(0xFF4A90E2),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _showDateRangePicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From: ${DateFormat('dd MMM yyyy').format(_fromDate)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'To: ${DateFormat('dd MMM yyyy').format(_toDate)}',
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
                    Icons.calendar_today,
                    color: Color(0xFF4A90E2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadAttendanceRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoadingRecords
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Loading...'),
                      ],
                    )
                  : const Text(
                      'Load Records',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Attendance Records List
  Widget _buildAttendanceRecordsList() {
    if (_attendanceRecords.isEmpty && !_isLoadingRecords) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No attendance records found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Select a date range and load records',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _attendanceRecords.length,
      itemBuilder: (context, index) {
        return _buildAttendanceRecordCard(_attendanceRecords[index]);
      },
    );
  }

  // NEW: Attendance Record Card
  Widget _buildAttendanceRecordCard(AttendanceRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: () => _navigateToAttendanceDetails(record),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Color(0xFF4A90E2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.subjectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            '${record.className} - ${record.batch}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        record.subTypeName,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMM yyyy').format(record.attDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${record.timeFrom} - ${record.timeTo}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.name,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
        top: false,
        minimum: const EdgeInsets.only(bottom: 6),
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
              // Format date for API (MM/dd/yyyy format)
              final formattedDate = DateFormat('MM/dd/yyyy').format(_selectedDate);

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
          child: const Text('Submit Attendance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
}

// NEW: Attendance Details Screen
class AttendanceDetailsScreen extends StatefulWidget {
  final AttendanceRecord attendanceRecord;

  const AttendanceDetailsScreen({
    super.key,
    required this.attendanceRecord,
  });

  @override
  State<AttendanceDetailsScreen> createState() => _AttendanceDetailsScreenState();
}

class _AttendanceDetailsScreenState extends State<AttendanceDetailsScreen> {
  List<StudentAttendanceDetail> _studentDetails = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    print('=== LOADING STUDENT DETAILS ===');
    print('Attendance ID: ${widget.attendanceRecord.attId}');

    setState(() => _isLoading = true);

    try {
      final details = await TeacherAttendanceService.getStudentDetails(
        attId: widget.attendanceRecord.attId,
      );

      setState(() {
        _studentDetails = details;
      });

      print('Loaded ${_studentDetails.length} student details successfully');
    } catch (e) {
      print('Error loading student details: $e');
      CustomSnackbar.showError(context, message: 'Failed to load student details');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    CustomSnackbar.showError(context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Attendance Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildAttendanceSummary()),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildStudentsHeader()),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          _buildStudentSliver(),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90E2),
            const Color(0xFF357ABD).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.attendanceRecord.subjectName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.attendanceRecord.className} • ${widget.attendanceRecord.batch}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: DateFormat('EEE, dd MMM yyyy').format(widget.attendanceRecord.attDate),
                ),
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: '${widget.attendanceRecord.timeFrom} - ${widget.attendanceRecord.timeTo}',
                ),
                _buildInfoChip(
                  icon: Icons.category,
                  label: widget.attendanceRecord.subTypeName,
                ),
                _buildInfoChip(
                  icon: Icons.person,
                  label: widget.attendanceRecord.name,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  int _presentCount() => _studentDetails.where((s) => s.status).length;
  int _absentCount() => _studentDetails.where((s) => !s.status).length;

  Widget _buildStudentsHeader() {
    final total = _studentDetails.length;
    final present = _presentCount();
    final absent = _absentCount();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Students',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
                letterSpacing: 0.2,
              ),
            ),
          ),
          _buildCountChip('$total Total', const Color(0xFF4A90E2)),
          const SizedBox(width: 8),
          _buildCountChip('$present Present', const Color(0xFF10B981)),
          const SizedBox(width: 8),
          _buildCountChip('$absent Absent', const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildCountChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentSliver() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              CircularProgressIndicator(
                color: Color(0xFF4A90E2),
              ),
              SizedBox(height: 16),
              Text(
                'Loading student details...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_studentDetails.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No student details found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildStudentDetailCard(_studentDetails[index]),
          childCount: _studentDetails.length,
        ),
      ),
    );
  }

  Widget _buildStudentDetailCard(StudentAttendanceDetail student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: student.status
                ? const Color(0xFF10B981).withOpacity(0.3)
                : const Color(0xFFEF4444).withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: student.status
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFEF4444).withOpacity(0.1),
                child: Text(
                  student.name.isNotEmpty ? student.name.substring(0, 1).toUpperCase() : '?',
                  style: TextStyle(
                    color: student.status ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
                      'PRN: ${student.collegePRN}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: student.status
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  student.status ? 'Present' : 'Absent',
                  style: TextStyle(
                    color: student.status ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

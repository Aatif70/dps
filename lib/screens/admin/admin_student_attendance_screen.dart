import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dps/services/admin_student_attendance_service.dart';
import 'package:dps/widgets/custom_snackbar.dart';

class AdminStudentAttendanceScreen extends StatefulWidget {
  const AdminStudentAttendanceScreen({super.key});

  @override
  State<AdminStudentAttendanceScreen> createState() => _AdminStudentAttendanceScreenState();
}

class _AdminStudentAttendanceScreenState extends State<AdminStudentAttendanceScreen> {
  List<BatchData> _batches = [];
  List<DivisionData> _divisions = [];
  BatchData? _selectedBatch;
  DivisionData? _selectedDivision;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  ClassAttendanceData? _attendanceData;
  bool _isLoading = false;
  bool _isLoadingBatches = true;
  bool _isLoadingDivisions = false;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    print('=== LOADING BATCHES ===');
    setState(() {
      _isLoadingBatches = true;
    });

    try {
      final batches = await AdminStudentAttendanceService.getBatches();
      print('Loaded ${batches.length} batches');
      
      if (mounted) {
        setState(() {
          _batches = batches;
          _isLoadingBatches = false;
          if (batches.isNotEmpty) {
            _selectedBatch = batches.first;
            _loadDivisions();
          }
        });
      }
    } catch (e) {
      print('Error loading batches: $e');
      if (mounted) {
        setState(() {
          _isLoadingBatches = false;
        });
        CustomSnackbar.showError(
          context,
          message: 'Failed to load batches. Please try again.',
        );
      }
    }
  }

  Future<void> _loadDivisions() async {
    if (_selectedBatch == null) return;

    print('=== LOADING DIVISIONS ===');
    setState(() {
      _isLoadingDivisions = true;
      _selectedDivision = null;
    });

    try {
      final divisions = await AdminStudentAttendanceService.getDivisionsByClass(_selectedBatch!.classId);
      print('Loaded ${divisions.length} divisions for class ${_selectedBatch!.classId}');
      
      if (mounted) {
        setState(() {
          _divisions = divisions;
          _isLoadingDivisions = false;
          if (divisions.isNotEmpty) {
            _selectedDivision = divisions.first;
          }
        });
      }
    } catch (e) {
      print('Error loading divisions: $e');
      if (mounted) {
        setState(() {
          _isLoadingDivisions = false;
        });
        CustomSnackbar.showError(
          context,
          message: 'Failed to load divisions. Please try again.',
        );
      }
    }
  }

  Future<void> _loadAttendanceData() async {
    if (_selectedBatch == null || _selectedDivision == null) {
      CustomSnackbar.showError(
        context,
        message: 'Please select both class and division.',
      );
      return;
    }

    print('=== LOADING ATTENDANCE DATA ===');
    setState(() {
      _isLoading = true;
      _attendanceData = null;
    });

    try {
      final data = await AdminStudentAttendanceService.getClassAttendance(
        month: _selectedMonth,
        year: _selectedYear,
        classId: _selectedBatch!.classId,
        divisionId: _selectedDivision!.divisionId,
      );

      print('Attendance data loaded: $data');
      
      if (mounted) {
        setState(() {
          _attendanceData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading attendance data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.showError(
          context,
          message: 'Failed to load attendance data. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: RefreshIndicator(
        onRefresh: _loadAttendanceData,
        child: _isLoadingBatches
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selection Controls
                    _buildSelectionControls(),
                    const SizedBox(height: 25),

                    // Attendance Summary
                    if (_attendanceData != null) ...[
                      _buildAttendanceSummary(context),
                      const SizedBox(height: 25),
                    ],

                    // Top Students
                    if (_attendanceData != null && _attendanceData!.topStudents.isNotEmpty) ...[
                      _buildTopStudents(context),
                      const SizedBox(height: 25),
                    ],

                    // Load Button
                    if (_selectedBatch != null && _selectedDivision != null)
                      _buildLoadButton(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Student Attendance',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF2D3748),
          size: 20,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF58CC02),
              size: 20,
            ),
          ),
          onPressed: _loadAttendanceData,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildSelectionControls() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list_rounded,
                color: Color(0xFF4A90E2),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Select Parameters',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Class Selection
          _buildDropdownField(
            label: 'Class',
            value: _selectedBatch?.batchName,
            items: _batches.map((b) => b.batchName).toList(),
            onChanged: (value) {
              if (value != null) {
                final selectedBatch = _batches.firstWhere((b) => b.batchName == value);
                setState(() {
                  _selectedBatch = selectedBatch;
                  _selectedDivision = null;
                });
                _loadDivisions();
              }
            },
            isLoading: _isLoadingBatches,
          ),
          const SizedBox(height: 16),

          // Division Selection
          _buildDropdownField(
            label: 'Division',
            value: _selectedDivision?.name,
            items: _divisions.map((d) => d.name).toList(),
            onChanged: (value) {
              if (value != null) {
                final selectedDivision = _divisions.firstWhere((d) => d.name == value);
                setState(() {
                  _selectedDivision = selectedDivision;
                });
              }
            },
            isLoading: _isLoadingDivisions,
          ),
          const SizedBox(height: 16),

          // Month and Year Selection
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Month',
                  value: DateFormat('MMMM').format(DateTime(2024, _selectedMonth)),
                  items: List.generate(12, (index) => DateFormat('MMMM').format(DateTime(2024, index + 1))),
                  onChanged: (value) {
                    if (value != null) {
                      final monthIndex = List.generate(12, (index) => DateFormat('MMMM').format(DateTime(2024, index + 1))).indexOf(value) + 1;
                      setState(() {
                        _selectedMonth = monthIndex;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Year',
                  value: _selectedYear.toString(),
                  items: List.generate(5, (index) => (DateTime.now().year - 2 + index).toString()),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedYear = int.parse(value);
                      });
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                isLoading ? 'Loading...' : 'Select $label',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Color(0xFF2D3748)),
                  ),
                );
              }).toList(),
              onChanged: isLoading ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSummary(BuildContext context) {
    final data = _attendanceData!;
    final percentage = data.attendancePercentage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: percentage >= 80 
              ? [const Color(0xFF58CC02), const Color(0xFF4CAF50)]
              : percentage >= 60
                  ? [const Color(0xFFFFA726), const Color(0xFFFF9800)]
                  : [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (percentage >= 80 ? const Color(0xFF58CC02) : percentage >= 60 ? const Color(0xFFFFA726) : const Color(0xFFFF6B6B)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.document_scanner_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Attendance Summary',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${data.totalStudents} Students',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  percentage >= 80 ? Icons.check_circle_rounded : percentage >= 60 ? Icons.warning_rounded : Icons.error_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Present',
                  data.totalPresent.toString(),
                  const Color(0xFF00CEC9),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Absent',
                  data.totalAbsent.toString(),
                  const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStudents(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFD79A8),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Top Students',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFD79A8).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_attendanceData!.topStudents.length} Students',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFD79A8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attendanceData!.topStudents.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final student = _attendanceData!.topStudents[index];
              return _buildTopStudentItem(context, student, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopStudentItem(BuildContext context, TopStudent student, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFD79A8).withOpacity(0.1),
                  const Color(0xFFFD79A8).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFD79A8),
                  fontSize: 16,
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
                  student.studentName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Student ID: ${student.studentId}',
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFD79A8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${student.presentDays} days',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFD79A8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _loadAttendanceData,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Load Attendance Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}

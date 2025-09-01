import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:dps/services/admin_student_attendance_service.dart';
import 'package:dps/widgets/custom_snackbar.dart';

class AdminStudentAttendanceByDateScreen extends StatefulWidget {
  const AdminStudentAttendanceByDateScreen({super.key});

  @override
  State<AdminStudentAttendanceByDateScreen> createState() => _AdminStudentAttendanceByDateScreenState();
}

class _AdminStudentAttendanceByDateScreenState extends State<AdminStudentAttendanceByDateScreen> {
  String _selectedFilterOption = 'monthYear'; // 'date' or 'monthYear'
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  StudentAttendanceData? _attendanceData;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: RefreshIndicator(
        onRefresh: _loadAttendanceData,
        child: SingleChildScrollView(
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

              // Class-wise Results
              if (_attendanceData != null && _attendanceData!.result.isNotEmpty) ...[
                _buildClassResults(context),
                const SizedBox(height: 25),
              ],

              // Load Button
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
        'Attendance by Date',
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
              color: const Color(0xFF58CC02).withValues(alpha:0.1),
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
                color: Color(0xFF00CEC9),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Select Filter Option',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filter Option Selection
          _buildFilterOptionSelector(),
          const SizedBox(height: 20),

          // Date or Month/Year Selection based on filter option
          if (_selectedFilterOption == 'date') ...[
            _buildDateSelector(),
          ] else ...[
            _buildMonthYearSelector(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterOptionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Option',
          style: TextStyle(
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
              value: _selectedFilterOption,
              isExpanded: true,
              items: const [
                DropdownMenuItem<String>(
                  value: 'date',
                  child: Text(
                    'By Date',
                    style: TextStyle(color: Color(0xFF2D3748)),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'monthYear',
                  child: Text(
                    'By Month/Year',
                    style: TextStyle(color: Color(0xFF2D3748)),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilterOption = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF00CEC9),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('dd MMM, yyyy').format(_selectedDate),
                  style: const TextStyle(
                    color: Color(0xFF2D3748),
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthYearSelector() {
    return Row(
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
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
                'Select $label',
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
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _loadAttendanceData() async {
    debugPrint('=== LOADING ATTENDANCE DATA BY DATE ===');
    setState(() {
      _isLoading = true;
      _attendanceData = null;
    });

    try {
      final data = await AdminStudentAttendanceService.getStudentAttendance(
        filterOption: _selectedFilterOption,
        selectedDate: _selectedFilterOption == 'date' ? DateFormat('yyyy-MM-dd').format(_selectedDate) : null,
        month: _selectedFilterOption == 'monthYear' ? _selectedMonth : null,
        year: _selectedFilterOption == 'monthYear' ? _selectedYear : null,
      );

      debugPrint('Attendance data loaded: $data');
      
      if (mounted) {
        setState(() {
          _attendanceData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading attendance data: $e');
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

  Widget _buildAttendanceSummary(BuildContext context) {
    final data = _attendanceData!;
    final totalPresent = data.result.fold(0, (sum, item) => sum + item.presentCount);
    final totalAbsent = data.result.fold(0, (sum, item) => sum + item.absentCount);
    final totalStudents = totalPresent + totalAbsent;
    final percentage = totalStudents > 0 ? (totalPresent / totalStudents) * 100 : 0;

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
            color: (percentage >= 80 ? const Color(0xFF58CC02) : percentage >= 60 ? const Color(0xFFFFA726) : const Color(0xFFFF6B6B)).withValues(alpha:0.3),
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
                          Icons.analytics_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Overall Attendance',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.9),
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
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${data.result.length} Classes',
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
                  color: Colors.white.withValues(alpha:0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.3),
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
                  totalPresent.toString(),
                  const Color(0xFF00CEC9),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Absent',
                  totalAbsent.toString(),
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
        color: Colors.white.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.3),
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
              color: Colors.white.withValues(alpha:0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassResults(BuildContext context) {
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
                      Icons.class_rounded,
                      color: Color(0xFF00CEC9),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Class-wise Results',
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
                    color: const Color(0xFF00CEC9).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_attendanceData!.result.length} Classes',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00CEC9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attendanceData!.result.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final result = _attendanceData!.result[index];
              return _buildClassResultItem(context, result);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClassResultItem(BuildContext context, ClassAttendanceResult result) {
    final percentage = result.attendancePercentage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00CEC9).withValues(alpha:0.1),
                  const Color(0xFF00CEC9).withValues(alpha:0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                result.className,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00CEC9),
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
                  'Class ${result.className}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.totalStudents} Students',
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: percentage >= 80 ? const Color(0xFF58CC02) : percentage >= 60 ? const Color(0xFFFFA726) : const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00CEC9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${result.presentCount}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00CEC9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${result.absentCount}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
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
            backgroundColor: const Color(0xFF00CEC9),
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

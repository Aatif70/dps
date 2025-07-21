import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedClass = 'Class 10-A';

  // Mock data for classes
  final List<String> _classes = [
    'Class 10-A',
    'Class 10-B',
    'Class 11-A',
    'Class 11-B',
    'Class 12-A',
  ];

  // Mock data for students in a class
  final List<Student> _students = List.generate(
    25,
    (index) => Student(
      id: 'STU${10001 + index}',
      name: 'Student ${index + 1}',
      rollNumber: (index + 1).toString().padLeft(2, '0'),
      profileImage: '',
      attendanceHistory: {
        DateTime.now().subtract(const Duration(days: 1)): AttendanceStatus.present,
        DateTime.now().subtract(const Duration(days: 2)): AttendanceStatus.present,
        DateTime.now().subtract(const Duration(days: 3)): index % 5 == 0 ? AttendanceStatus.absent : AttendanceStatus.present,
        DateTime.now().subtract(const Duration(days: 4)): AttendanceStatus.present,
        DateTime.now().subtract(const Duration(days: 5)): index % 7 == 0 ? AttendanceStatus.absent : AttendanceStatus.present,
      },
    ),
  );

  // Mock attendance statistics
  final Map<String, Map<String, double>> _classAttendanceStats = {
    'Class 10-A': {'Apr': 0.92, 'May': 0.88, 'Jun': 0.75, 'Jul': 0.95, 'Aug': 0.85, 'Sep': 0.90},
    'Class 10-B': {'Apr': 0.90, 'May': 0.85, 'Jun': 0.78, 'Jul': 0.92, 'Aug': 0.88, 'Sep': 0.86},
    'Class 11-A': {'Apr': 0.88, 'May': 0.90, 'Jun': 0.82, 'Jul': 0.89, 'Aug': 0.91, 'Sep': 0.85},
    'Class 11-B': {'Apr': 0.85, 'May': 0.82, 'Jun': 0.80, 'Jul': 0.88, 'Aug': 0.87, 'Sep': 0.83},
    'Class 12-A': {'Apr': 0.95, 'May': 0.92, 'Jun': 0.88, 'Jul': 0.94, 'Aug': 0.93, 'Sep': 0.91},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.attendance),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A90E2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4A90E2),
          tabs: const [
            Tab(text: 'Mark Attendance'),
            Tab(text: 'Reports'),
          ],
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
        _buildClassAndDateSelector(),
        Expanded(
          child: _buildStudentAttendanceList(),
        ),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildClassAndDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Class Selector
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Class',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: _selectedClass,
            items: _classes.map((String classItem) {
              return DropdownMenuItem<String>(
                value: classItem,
                child: Text(classItem),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedClass = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // Date Selector
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF4A90E2)),
                  const SizedBox(width: 12),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildStudentAttendanceList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final attendance = student.attendanceHistory[_selectedDate] ?? AttendanceStatus.pending;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Student Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF4A90E2).withOpacity(0.1),
                  child: Text(
                    student.name.substring(0, 1),
                    style: const TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
                // Attendance Radio Buttons
                Row(
                  children: [
                    _buildAttendanceRadio(
                      student,
                      AttendanceStatus.present,
                      Icons.check_circle_outline,
                      const Color(0xFF4ade80),
                    ),
                    const SizedBox(width: 8),
                    _buildAttendanceRadio(
                      student,
                      AttendanceStatus.absent,
                      Icons.cancel_outlined,
                      const Color(0xFFf87171),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceRadio(Student student, AttendanceStatus status, IconData icon, Color color) {
    final currentStatus = student.attendanceHistory[_selectedDate] ?? AttendanceStatus.pending;
    final isSelected = currentStatus == status;
    
    return InkWell(
      onTap: () {
        setState(() {
          student.attendanceHistory[_selectedDate] = status;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              status == AttendanceStatus.present ? 'Present' : 'Absent',
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
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
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Save attendance logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Attendance saved successfully!'),
              backgroundColor: Color(0xFF4A90E2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Submit Attendance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttendanceOverview(),
          const SizedBox(height: 24),
          _buildMonthlyAttendanceChart(),
          const SizedBox(height: 24),
          _buildLowAttendanceStudents(),
        ],
      ),
    );
  }

  Widget _buildAttendanceOverview() {
    final stats = _classAttendanceStats[_selectedClass] ?? {};
    final currentMonth = DateFormat('MMM').format(DateTime.now());
    final currentAttendance = stats[currentMonth] ?? 0.0;
    
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
              'Attendance Overview',
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
                    'Current Month',
                    '${(currentAttendance * 100).toStringAsFixed(1)}%',
                    const Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Average',
                    '${(_calculateAverageAttendance(stats) * 100).toStringAsFixed(1)}%',
                    const Color(0xFF58CC02),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Highest',
                    '${(_findHighestAttendance(stats) * 100).toStringAsFixed(1)}%',
                    const Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Lowest',
                    '${(_findLowestAttendance(stats) * 100).toStringAsFixed(1)}%',
                    const Color(0xFFE74C3C),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAverageAttendance(Map<String, double> stats) {
    if (stats.isEmpty) return 0.0;
    final total = stats.values.fold<double>(0, (sum, value) => sum + value);
    return total / stats.length;
  }

  double _findHighestAttendance(Map<String, double> stats) {
    if (stats.isEmpty) return 0.0;
    return stats.values.reduce((curr, next) => curr > next ? curr : next);
  }

  double _findLowestAttendance(Map<String, double> stats) {
    if (stats.isEmpty) return 0.0;
    return stats.values.reduce((curr, next) => curr < next ? curr : next);
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

  Widget _buildMonthlyAttendanceChart() {
    final stats = _classAttendanceStats[_selectedClass] ?? {};
    
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
              'Monthly Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: stats.entries.map((entry) {
                  final month = entry.key;
                  final percentage = entry.value;
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: constraints.maxHeight * percentage,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4A90E2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          month,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Color(0xFF4A90E2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowAttendanceStudents() {
    // Filter students with low attendance (below 80%)
    final lowAttendanceStudents = _students.where((student) {
      final attendanceRate = _calculateStudentAttendanceRate(student);
      return attendanceRate < 0.8;
    }).toList();
    
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
              'Low Attendance Students',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            lowAttendanceStudents.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No students with low attendance!',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lowAttendanceStudents.length,
                    itemBuilder: (context, index) {
                      final student = lowAttendanceStudents[index];
                      final attendanceRate = _calculateStudentAttendanceRate(student);
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFf87171).withOpacity(0.1),
                          child: Text(
                            student.name.substring(0, 1),
                            style: const TextStyle(
                              color: Color(0xFFf87171),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('Roll No: ${student.rollNumber}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf87171).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(attendanceRate * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Color(0xFFf87171),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  double _calculateStudentAttendanceRate(Student student) {
    final totalDays = student.attendanceHistory.length;
    if (totalDays == 0) return 0.0;
    
    final presentDays = student.attendanceHistory.values
        .where((status) => status == AttendanceStatus.present)
        .length;
        
    return presentDays / totalDays;
  }
}

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
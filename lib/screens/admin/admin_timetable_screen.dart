import 'package:flutter/material.dart';
import '../../widgets/admin_timetable_widget.dart';
import '../../services/admin_timetable_service.dart';

class AdminTimetableScreen extends StatefulWidget {
  const AdminTimetableScreen({Key? key}) : super(key: key);

  @override
  State createState() => _AdminTimetableScreenState();
}

class _AdminTimetableScreenState extends State<AdminTimetableScreen>
    with SingleTickerProviderStateMixin {
  bool _showAddForm = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Form data (keeping all original backend connectivity)
  ClassMasterItem? _selectedClass;
  BatchItem? _selectedBatch;
  DivisionItem? _selectedDivision;
  EmployeeItem? _selectedEmployee;
  SubjectItem? _selectedSubject;
  String _selectedWeekDay = 'Monday';
  String _fromTime = '09:00';
  String _toTime = '10:00';
  int _subTypeId = 1;

  // Data lists
  List _classes = [];
  List _batches = [];
  List _divisions = [];
  List _employees = [];
  List _subjects = [];

  final List<String> _weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  final List<Map<String, dynamic>> _subjectTypes = [
    {'id': 1, 'name': 'Theory'},
    {'id': 2, 'name': 'Practical'},
    {'id': 3, 'name': 'Lab'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Keep all original backend methods unchanged
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      print('🚀 === LOADING INITIAL DATA ===');
      
      print('📚 === LOADING CLASSES ===');
      final classes = await AdminTimetableService.getClasses();
      print('✅ Classes loaded: ${classes.length}');
      for (int i = 0; i < classes.length; i++) {
        final cls = classes[i];
        print('   📖 Class $i: ID=${cls.classMasterId}, Name="${cls.className}", Year=${cls.courseYear}');
      }
      
      print('👥 === LOADING EMPLOYEES ===');
      final employees = await AdminTimetableService.getEmployees();
      print('✅ Employees loaded: ${employees.length}');
      for (int i = 0; i < employees.length; i++) {
        final emp = employees[i];
        print('   👤 Employee $i: ID=${emp.empId}, Name="${emp.name}", Designation="${emp.designationName}"');
      }
      
      setState(() {
        _classes = classes;
        _employees = employees;
        _isLoading = false;
      });
      
      print('🎯 === INITIAL DATA LOADED SUCCESSFULLY ===');
      print('   📚 Classes count: ${_classes.length}');
      print('   👥 Employees count: ${_employees.length}');
      
    } catch (e) {
      print('❌ === ERROR LOADING INITIAL DATA ===');
      print('   Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBatches() async {
    if (_selectedClass == null) return;
    try {
      print('🎯 === LOADING BATCHES ===');
      print('   📚 Selected Class: ID=${_selectedClass!.classMasterId}, Name="${_selectedClass!.className}"');
      
      final batches = await AdminTimetableService.getBatchesByClassMaster(
          _selectedClass!.classMasterId);
      
      print('✅ Batches loaded: ${batches.length}');
      for (int i = 0; i < batches.length; i++) {
        final batch = batches[i];
        print('   📦 Batch $i: ID=${batch.classId}, Name="${batch.batchName}", Year=${batch.courseYear}');
      }
      
      setState(() {
        _batches = batches;
        _selectedBatch = null;
        _selectedDivision = null;
        _selectedSubject = null;
      });
      
      print('🎯 === BATCHES LOADED SUCCESSFULLY ===');
      print('   📦 Batches count: ${_batches.length}');
      
    } catch (e) {
      print('❌ === ERROR LOADING BATCHES ===');
      print('   Error: $e');
    }
  }

  Future<void> _loadDivisions() async {
    if (_selectedBatch == null) return;
    try {
      print('🎯 === LOADING DIVISIONS ===');
      print('   📦 Selected Batch: ID=${_selectedBatch!.classId}, Name="${_selectedBatch!.batchName}"');
      
      final divisions = await AdminTimetableService.getDivisionsByClass(
          _selectedBatch!.classId);
      
      print('✅ Divisions loaded: ${divisions.length}');
      for (int i = 0; i < divisions.length; i++) {
        final division = divisions[i];
        print('   🏫 Division $i: ID=${division.divisionId}, Name="${division.divName}"');
      }
      
      setState(() {
        _divisions = divisions;
        _selectedDivision = null;
      });
      
      print('🎯 === DIVISIONS LOADED SUCCESSFULLY ===');
      print('   🏫 Divisions count: ${_divisions.length}');
      
    } catch (e) {
      print('❌ === ERROR LOADING DIVISIONS ===');
      print('   Error: $e');
    }
  }

  Future<void> _loadSubjects() async {
    if (_selectedClass == null || _selectedEmployee == null) return;
    try {
      print('🎯 === LOADING SUBJECTS ===');
      print('   📚 Selected Class: ID=${_selectedClass!.classMasterId}, Name="${_selectedClass!.className}"');
      print('   👤 Selected Employee: ID=${_selectedEmployee!.empId}, Name="${_selectedEmployee!.name}"');
      
      final subjects = await AdminTimetableService.getSubjectsByClassMasterAndEmployee(
          _selectedClass!.classMasterId, _selectedEmployee!.empId);
      
      print('✅ Subjects loaded: ${subjects.length}');
      for (int i = 0; i < subjects.length; i++) {
        final subject = subjects[i];
        print('   📖 Subject $i: ID=${subject.subjectId}, Name="${subject.subjectName}"');
      }
      
      setState(() {
        _subjects = subjects;
        _selectedSubject = null;
      });
      
      print('🎯 === SUBJECTS LOADED SUCCESSFULLY ===');
      print('   📖 Subjects count: ${_subjects.length}');
      
    } catch (e) {
      print('❌ === ERROR LOADING SUBJECTS ===');
      print('   Error: $e');
      print('   Stack trace: $e');
    }
  }

  Future<void> _addTimetable() async {
    if (_selectedClass == null ||
        _selectedBatch == null ||
        _selectedDivision == null ||
        _selectedEmployee == null ||
        _selectedSubject == null) {
      _showSnackBar('Please fill all required fields', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AdminTimetableService.addTimetable(
        classId: _selectedBatch!.classId,
        batchId: _selectedBatch!.classId,
        divisionId: _selectedDivision!.divisionId,
        empId: _selectedEmployee!.empId,
        weekDay: _selectedWeekDay,
        subId: _selectedSubject!.subjectId,
        fromTime: _fromTime,
        toTime: _toTime,
        subTypeId: _subTypeId,
      );

      if (result['success'] == true) {
        _showSnackBar('Timetable added successfully!');
        _resetForm();
        _toggleAddForm();
      } else {
        _showSnackBar(result['message'] ?? 'Failed to add timetable', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedClass = null;
      _selectedBatch = null;
      _selectedDivision = null;
      _selectedEmployee = null;
      _selectedSubject = null;
      _selectedWeekDay = 'Monday';
      _fromTime = '09:00';
      _toTime = '10:00';
      _subTypeId = 1;
      _batches = [];
      _divisions = [];
      _subjects = [];
    });
  }

  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;
      if (_showAddForm) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _resetForm();
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading && _classes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : const AdminTimetableWidget(),
              ),
            ],
          ),
          // Sliding add form
          if (_showAddForm) _buildSlidingAddForm(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Timetable',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      actions: [
        IconButton(
          onPressed: _toggleAddForm,
          icon: AnimatedRotation(
            turns: _showAddForm ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _showAddForm ? Icons.close : Icons.add,
              color: const Color(0xFF6366F1),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlidingAddForm() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Form content
                Expanded(
                  child: _buildAddTimetableForm(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddTimetableForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Timetable',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),

                     // Form fields with modern styling
           _buildModernDropdownField<ClassMasterItem>(
             label: 'Class',
             value: _selectedClass,
             items: _classes.cast<ClassMasterItem>(),
             onChanged: (value) {
               setState(() {
                 _selectedClass = value;
                 _selectedBatch = null;
                 _selectedDivision = null;
                 _selectedSubject = null;
                 _batches = [];
                 _divisions = [];
                 _subjects = [];
               });
               if (value != null) {
                 _loadBatches();
                 // Only load subjects if both class and employee are selected
                 if (_selectedEmployee != null) {
                   _loadSubjects();
                 }
               }
             },
             displayText: (item) => item.className,
           ),

           _buildModernDropdownField<BatchItem>(
             label: 'Batch',
             value: _selectedBatch,
             items: _batches.cast<BatchItem>(),
             onChanged: (value) {
               setState(() {
                 _selectedBatch = value;
                 _selectedDivision = null;
                 _divisions = [];
               });
               if (value != null) {
                 _loadDivisions();
               }
             },
             displayText: (item) => item.batchName,
           ),

           _buildModernDropdownField<DivisionItem>(
             label: 'Division',
             value: _selectedDivision,
             items: _divisions.cast<DivisionItem>(),
             onChanged: (value) {
               setState(() {
                 _selectedDivision = value;
               });
             },
             displayText: (item) => item.divName,
           ),

           _buildModernDropdownField<EmployeeItem>(
             label: 'Teacher',
             value: _selectedEmployee,
             items: _employees.cast<EmployeeItem>(),
             onChanged: (value) {
               setState(() {
                 _selectedEmployee = value;
                 _selectedSubject = null;
                 _subjects = [];
               });
               // Only load subjects if both class and employee are selected
               if (value != null && _selectedClass != null) {
                 _loadSubjects();
               }
             },
             displayText: (item) => '${item.name} (${item.designationName})',
           ),

           _buildModernDropdownField<SubjectItem>(
             label: 'Subject',
             value: _selectedSubject,
             items: _subjects.cast<SubjectItem>(),
             onChanged: (value) {
               setState(() {
                 _selectedSubject = value;
               });
             },
             displayText: (item) => item.subjectName,
           ),

          _buildModernDropdownField<String>(
            label: 'Week Day',
            value: _selectedWeekDay,
            items: _weekDays,
            onChanged: (value) {
              setState(() {
                _selectedWeekDay = value ?? 'Monday';
              });
            },
            displayText: (item) => item,
          ),

          // Time fields
          Row(
            children: [
              Expanded(
                child: _buildModernDropdownField<String>(
                  label: 'From Time',
                  value: _fromTime,
                  items: _getTimeSlots(),
                  onChanged: (value) {
                    setState(() {
                      _fromTime = value ?? '09:00';
                    });
                  },
                  displayText: (item) => item,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernDropdownField<String>(
                  label: 'To Time',
                  value: _toTime,
                  items: _getTimeSlots(),
                  onChanged: (value) {
                    setState(() {
                      _toTime = value ?? '10:00';
                    });
                  },
                  displayText: (item) => item,
                ),
              ),
            ],
          ),

          _buildModernDropdownField<Map<String, dynamic>>(
            label: 'Subject Type',
            value: _subjectTypes.firstWhere((type) => type['id'] == _subTypeId),
            items: _subjectTypes,
            onChanged: (value) {
              setState(() {
                _subTypeId = value?['id'] ?? 1;
              });
            },
            displayText: (item) => item['name'],
          ),

          const SizedBox(height: 30),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addTimetable,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : const Text(
                'Add Timetable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) displayText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: Text('Select $label'),
                items: items.map((T item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(displayText(item)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTimeSlots() {
    return [
      '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
      '11:00', '11:30', '12:00', '12:30', '13:00', '13:30',
      '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
      '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
    ];
  }
}

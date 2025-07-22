import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for assignments
  final List<Assignment> _assignments = [
    Assignment(
      id: 'HW-2023-001',
      title: 'Linear Equations',
      description: 'Solve problems 1-15 from Chapter 5',
      subject: 'Mathematics',
      classAssigned: 'Class 10-A',
      assignedDate: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 3)),
      status: AssignmentStatus.active,
      attachments: ['Chapter5_Problems.pdf'],
      submissionCount: 18,
      totalStudents: 32,
    ),
    Assignment(
      id: 'HW-2023-002',
      title: 'Photosynthesis',
      description: 'Complete the experiment report and answer questions on page 45',
      subject: 'Science',
      classAssigned: 'Class 11-A',
      assignedDate: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 4)),
      status: AssignmentStatus.active,
      attachments: ['Experiment_Guide.pdf', 'Report_Template.docx'],
      submissionCount: 12,
      totalStudents: 28,
    ),
    Assignment(
      id: 'HW-2023-003',
      title: 'Essay Writing',
      description: 'Write a 500-word essay on "Environmental Conservation"',
      subject: 'English',
      classAssigned: 'Class 10-B',
      assignedDate: DateTime.now().subtract(const Duration(days: 3)),
      dueDate: DateTime.now().add(const Duration(days: 1)),
      status: AssignmentStatus.active,
      submissionCount: 22,
      totalStudents: 30,
    ),
    Assignment(
      id: 'HW-2023-004',
      title: 'Newton\'s Laws of Motion',
      description: 'Complete the worksheet on Newton\'s Laws of Motion',
      subject: 'Physics',
      classAssigned: 'Class 11-A',
      assignedDate: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      status: AssignmentStatus.completed,
      attachments: ['Newton_Laws_Worksheet.pdf'],
      submissionCount: 26,
      totalStudents: 28,
      gradedCount: 26,
    ),
    Assignment(
      id: 'HW-2023-005',
      title: 'Quadratic Equations',
      description: 'Solve the problems from Exercise 4.2',
      subject: 'Mathematics',
      classAssigned: 'Class 10-A',
      assignedDate: DateTime.now().subtract(const Duration(days: 15)),
      dueDate: DateTime.now().subtract(const Duration(days: 8)),
      status: AssignmentStatus.completed,
      submissionCount: 30,
      totalStudents: 32,
      gradedCount: 30,
    ),
  ];

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
    final activeAssignments = _assignments.where((a) => a.status == AssignmentStatus.active).toList();
    final completedAssignments = _assignments.where((a) => a.status == AssignmentStatus.completed).toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.homework),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveAssignmentsTab(activeAssignments),
          _buildCompletedAssignmentsTab(completedAssignments),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateAssignmentDialog(context);
        },
        backgroundColor: const Color(0xFF58CC02),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveAssignmentsTab(List<Assignment> assignments) {
    if (assignments.isEmpty) {
      return _buildEmptyState('No active assignments', 'Create a new assignment by tapping the + button');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAssignmentSummary(assignments),
          const SizedBox(height: 24),
          Text(
            'Active Assignments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...assignments.map((assignment) => _buildAssignmentCard(assignment)).toList(),
        ],
      ),
    );
  }

  Widget _buildCompletedAssignmentsTab(List<Assignment> assignments) {
    if (assignments.isEmpty) {
      return _buildEmptyState('No completed assignments', 'Completed assignments will appear here');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return _buildCompletedAssignmentCard(assignments[index]);
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

  Widget _buildAssignmentSummary(List<Assignment> assignments) {
    final totalSubmissions = assignments.fold<int>(0, (sum, a) => sum + a.submissionCount);
    final totalStudents = assignments.fold<int>(0, (sum, a) => sum + a.totalStudents);
    final submissionRate = totalStudents > 0 ? totalSubmissions / totalStudents : 0.0;
    
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
              'Assignment Summary',
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
                    'Active',
                    assignments.length.toString(),
                    const Color(0xFF58CC02),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Submission Rate',
                    '${(submissionRate * 100).toStringAsFixed(1)}%',
                    const Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Due Soon',
                    _getDueSoonCount(assignments).toString(),
                    const Color(0xFFFF9500),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Pending Review',
                    _getPendingReviewCount(assignments).toString(),
                    const Color(0xFF8E44AD),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getDueSoonCount(List<Assignment> assignments) {
    final now = DateTime.now();
    return assignments.where((a) => 
      a.dueDate.difference(now).inDays <= 2 && 
      a.dueDate.isAfter(now)
    ).length;
  }

  int _getPendingReviewCount(List<Assignment> assignments) {
    return assignments.fold<int>(
      0, 
      (sum, a) => sum + (a.submissionCount - (a.gradedCount ?? 0))
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

  Widget _buildAssignmentCard(Assignment assignment) {
    final daysLeft = assignment.dueDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 1;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to assignment detail screen
        },
        borderRadius: BorderRadius.circular(16),
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
                      color: _getSubjectColor(assignment.subject).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSubjectIcon(assignment.subject),
                      color: _getSubjectColor(assignment.subject),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${assignment.subject} • ${assignment.classAssigned}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Due Soon',
                        style: TextStyle(
                          color: const Color(0xFFE74C3C),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                assignment.description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due: ${DateFormat('d MMM, yyyy').format(assignment.dueDate)}',
                    style: TextStyle(
                      color: isUrgent ? const Color(0xFFE74C3C) : Colors.grey.shade600,
                      fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Color(0xFF58CC02),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${assignment.submissionCount}/${assignment.totalStudents}',
                        style: const TextStyle(
                          color: Color(0xFF58CC02),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (assignment.attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_file,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${assignment.attachments.length} attachment${assignment.attachments.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedAssignmentCard(Assignment assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to assignment detail screen
        },
        borderRadius: BorderRadius.circular(16),
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
                      color: _getSubjectColor(assignment.subject).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getSubjectIcon(assignment.subject),
                      color: _getSubjectColor(assignment.subject),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${assignment.subject} • ${assignment.classAssigned}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF58CC02),
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due date: ${DateFormat('d MMM, yyyy').format(assignment.dueDate)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Submissions: ${assignment.submissionCount}/${assignment.totalStudents}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateAssignmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCreateAssignmentForm(),
    );
  }

  Widget _buildCreateAssignmentForm() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Assignment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'This is just a placeholder form. In a real app, this would be a complete form to create new assignments.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Mathematics', 'Science', 'English', 'Physics']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Class 10-A', 'Class 10-B', 'Class 11-A']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () {
                    // Show date picker
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Upload attachment logic
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add Attachment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Assignment created successfully!'),
                          backgroundColor: Color(0xFF58CC02),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58CC02),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Create Assignment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return const Color(0xFF4A90E2);
      case 'science':
        return const Color(0xFF58CC02);
      case 'english':
        return const Color(0xFF8E44AD);
      case 'physics':
        return const Color(0xFFFF9500);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.menu_book;
      case 'physics':
        return Icons.flash_on;
      default:
        return Icons.school;
    }
  }
}

enum AssignmentStatus { active, completed }

class Assignment {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String classAssigned;
  final DateTime assignedDate;
  final DateTime dueDate;
  final AssignmentStatus status;
  final List<String> attachments;
  final int submissionCount;
  final int totalStudents;
  final int? gradedCount;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.classAssigned,
    required this.assignedDate,
    required this.dueDate,
    required this.status,
    this.attachments = const [],
    required this.submissionCount,
    required this.totalStudents,
    this.gradedCount,
  });
} 
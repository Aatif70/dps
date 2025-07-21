import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  // Mock data for homework assignments
  final List<HomeworkAssignment> _allAssignments = [
    HomeworkAssignment(
      id: 'HW-2023-001',
      subject: 'Mathematics',
      title: 'Linear Equations',
      description: 'Solve problems 1-15 from Chapter 5',
      assignedDate: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(days: 3)),
      status: HomeworkStatus.pending,
      teacherName: 'Mr. Rajesh Kumar',
      attachments: ['Chapter5_Problems.pdf'],
    ),
    HomeworkAssignment(
      id: 'HW-2023-002',
      subject: 'Science',
      title: 'Photosynthesis',
      description: 'Complete the experiment report and answer questions on page 45',
      assignedDate: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 4)),
      status: HomeworkStatus.pending,
      teacherName: 'Mrs. Priya Singh',
      attachments: ['Experiment_Guide.pdf', 'Report_Template.docx'],
    ),
    HomeworkAssignment(
      id: 'HW-2023-003',
      subject: 'English',
      title: 'Essay Writing',
      description: 'Write a 500-word essay on "Environmental Conservation"',
      assignedDate: DateTime.now().subtract(const Duration(days: 3)),
      dueDate: DateTime.now().add(const Duration(days: 1)),
      status: HomeworkStatus.pending,
      teacherName: 'Mrs. Anjali Sharma',
    ),
    HomeworkAssignment(
      id: 'HW-2023-004',
      subject: 'History',
      title: 'The Mughal Empire',
      description: 'Create a timeline of key events during the Mughal Empire',
      assignedDate: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(hours: 12)),
      status: HomeworkStatus.pending,
      teacherName: 'Mr. Suresh Patel',
      attachments: ['Mughal_Empire_Reference.pdf'],
    ),
    HomeworkAssignment(
      id: 'HW-2023-005',
      subject: 'Computer Science',
      title: 'HTML Basics',
      description: 'Create a simple personal webpage using HTML and CSS',
      assignedDate: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      status: HomeworkStatus.completed,
      submittedDate: DateTime.now().subtract(const Duration(days: 4)),
      grade: 'A',
      comments: 'Excellent work! Creative design and well-structured code.',
      teacherName: 'Ms. Riya Agarwal',
    ),
    HomeworkAssignment(
      id: 'HW-2023-006',
      subject: 'Geography',
      title: 'Climate Zones',
      description: 'Create a poster illustrating different climate zones and their characteristics',
      assignedDate: DateTime.now().subtract(const Duration(days: 15)),
      dueDate: DateTime.now().subtract(const Duration(days: 5)),
      status: HomeworkStatus.completed,
      submittedDate: DateTime.now().subtract(const Duration(days: 5)),
      grade: 'B+',
      comments: 'Good work, but could use more detail on the tropical zone.',
      teacherName: 'Mrs. Kavita Nair',
    ),
  ];

  late List<HomeworkAssignment> _pendingAssignments;
  late List<HomeworkAssignment> _completedAssignments;
  
  @override
  void initState() {
    super.initState();
    _updateLists();
  }
  
  void _updateLists() {
    _pendingAssignments = _allAssignments
        .where((assignment) => assignment.status == HomeworkStatus.pending)
        .toList();
    
    _completedAssignments = _allAssignments
        .where((assignment) => assignment.status == HomeworkStatus.completed)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.homework),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHomeworkSummary(),
            _buildPendingHomework(),
            _buildCompletedHomework(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open homework submission screen
        },
        backgroundColor: const Color(0xFF58CC02),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHomeworkSummary() {
    // Count urgent assignments (due within 24 hours)
    final urgentCount = _pendingAssignments
        .where((hw) => 
            hw.dueDate.difference(DateTime.now()).inHours <= 24)
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Homework Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (urgentCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$urgentCount Urgent',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '${_pendingAssignments.length}',
                'Pending',
                Icons.assignment_outlined,
              ),
              _buildSummaryItem(
                '${_completedAssignments.length}',
                'Completed',
                Icons.assignment_turned_in_outlined,
              ),
              _buildSummaryItem(
                '${_allAssignments.length}',
                'Total',
                Icons.school_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingHomework() {
    if (_pendingAssignments.isEmpty) {
      return _buildEmptyState('No pending homework', 'Great job! You\'re all caught up.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Pending Assignments',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pendingAssignments.length,
          itemBuilder: (context, index) {
            return _buildHomeworkCard(_pendingAssignments[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCompletedHomework() {
    if (_completedAssignments.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all completed homework
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _completedAssignments.length > 2
              ? 2
              : _completedAssignments.length,
          itemBuilder: (context, index) {
            return _buildHomeworkCard(_completedAssignments[index]);
          },
        ),
      ],
    );
  }

  Widget _buildHomeworkCard(HomeworkAssignment assignment) {
    final bool isUrgent = assignment.status == HomeworkStatus.pending &&
        assignment.dueDate.difference(DateTime.now()).inHours <= 24;
    
    final Color subjectColor = _getSubjectColor(assignment.subject);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: subjectColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSubjectIcon(assignment.subject),
                    color: subjectColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  assignment.subject,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: subjectColor,
                  ),
                ),
                const Spacer(),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 12,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due Soon',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (assignment.status == HomeworkStatus.completed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  assignment.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                if (assignment.attachments.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Attachments',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: assignment.attachments
                        .map((file) => _buildAttachmentChip(file))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                ],
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment.status == HomeworkStatus.pending
                              ? 'Due Date'
                              : 'Submitted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          assignment.status == HomeworkStatus.pending
                              ? DateFormat('dd MMM yyyy, h:mm a').format(assignment.dueDate)
                              : DateFormat('dd MMM yyyy').format(assignment.submittedDate!),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    if (assignment.status == HomeworkStatus.pending)
                      SizedBox(
                        width: 100, // Fixed width for the button
                        child: ElevatedButton(
                          onPressed: () {
                            // Submit homework
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF58CC02),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text('Submit'),
                        ),
                      )
                    else if (assignment.grade != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF58CC02).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            assignment.grade!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF58CC02),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (assignment.status == HomeworkStatus.completed && assignment.comments != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Teacher\'s Comments',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.comments!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentChip(String fileName) {
    IconData icon;
    Color color;

    if (fileName.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf;
      color = Colors.red.shade700;
    } else if (fileName.endsWith('.docx') || fileName.endsWith('.doc')) {
      icon = Icons.description;
      color = Colors.blue.shade700;
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
      icon = Icons.image;
      color = Colors.green.shade700;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.download,
            size: 14,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in,
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

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return const Color(0xFF4A90E2);
      case 'science':
        return const Color(0xFF58CC02);
      case 'english':
        return const Color(0xFFE74C3C);
      case 'history':
        return const Color(0xFF8E44AD);
      case 'geography':
        return const Color(0xFFFF9500);
      case 'computer science':
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF718096);
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
      case 'history':
        return Icons.history_edu;
      case 'geography':
        return Icons.public;
      case 'computer science':
        return Icons.computer;
      default:
        return Icons.school;
    }
  }
}

enum HomeworkStatus { pending, completed }

class HomeworkAssignment {
  final String id;
  final String subject;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime dueDate;
  final HomeworkStatus status;
  final DateTime? submittedDate;
  final String? grade;
  final String? comments;
  final List<String> attachments;
  final String teacherName;

  HomeworkAssignment({
    required this.id,
    required this.subject,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.dueDate,
    required this.status,
    this.submittedDate,
    this.grade,
    this.comments,
    this.attachments = const [],
    required this.teacherName,
  });
} 
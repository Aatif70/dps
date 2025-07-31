import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _achievementAnimationController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _achievementPulseAnimation;

  // Enhanced mock data for homework assignments
  final List<HomeworkAssignment> _allAssignments = [
    HomeworkAssignment(
      id: 'HW-2024-001',
      subject: 'Mathematics',
      title: 'Linear Equations & Graphs',
      description: 'Complete exercises 1-20 from Chapter 8. Focus on graphing linear equations and finding intercepts.',
      assignedDate: DateTime.now().subtract(const Duration(days: 2)),
      dueDate: DateTime.now().add(const Duration(hours: 6)),
      status: HomeworkStatus.pending,
      teacherName: 'Mr. Rajesh Kumar',
      attachments: ['Chapter8_Exercises.pdf', 'Graph_Paper.pdf'],
      priority: HomeworkPriority.urgent,
      estimatedTime: 45,
    ),
    HomeworkAssignment(
      id: 'HW-2024-002',
      subject: 'Science',
      title: 'Photosynthesis Lab Report',
      description: 'Write a comprehensive lab report based on our photosynthesis experiment. Include observations, results, and conclusion.',
      assignedDate: DateTime.now().subtract(const Duration(days: 1)),
      dueDate: DateTime.now().add(const Duration(days: 2)),
      status: HomeworkStatus.pending,
      teacherName: 'Mrs. Priya Singh',
      attachments: ['Lab_Report_Template.docx', 'Experiment_Data.xlsx'],
      priority: HomeworkPriority.medium,
      estimatedTime: 60,
    ),
    HomeworkAssignment(
      id: 'HW-2024-003',
      subject: 'English',
      title: 'Creative Writing Essay',
      description: 'Write a 750-word creative essay on "A Day in 2050". Use vivid imagery and creative storytelling techniques.',
      assignedDate: DateTime.now().subtract(const Duration(days: 3)),
      dueDate: DateTime.now().add(const Duration(days: 4)),
      status: HomeworkStatus.pending,
      teacherName: 'Mrs. Anjali Sharma',
      priority: HomeworkPriority.medium,
      estimatedTime: 90,
    ),
    HomeworkAssignment(
      id: 'HW-2024-004',
      subject: 'Computer Science',
      title: 'Python Programming Project',
      description: 'Create a simple calculator program using Python. Include all basic operations and error handling.',
      assignedDate: DateTime.now().subtract(const Duration(days: 7)),
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      status: HomeworkStatus.completed,
      submittedDate: DateTime.now().subtract(const Duration(days: 2)),
      grade: 'A+',
      comments: 'Excellent work! Your code is well-structured and includes creative features. Keep it up!',
      teacherName: 'Ms. Riya Agarwal',
      priority: HomeworkPriority.high,
      estimatedTime: 120,
    ),
    HomeworkAssignment(
      id: 'HW-2024-005',
      subject: 'History',
      title: 'World War II Timeline',
      description: 'Create a detailed timeline of major World War II events with key dates and significance.',
      assignedDate: DateTime.now().subtract(const Duration(days: 10)),
      dueDate: DateTime.now().subtract(const Duration(days: 3)),
      status: HomeworkStatus.completed,
      submittedDate: DateTime.now().subtract(const Duration(days: 4)),
      grade: 'B+',
      comments: 'Good research and presentation. Include more analysis of events\' impact next time.',
      teacherName: 'Mr. Suresh Patel',
      attachments: ['WWII_Reference.pdf'],
      priority: HomeworkPriority.medium,
      estimatedTime: 75,
    ),
  ];

  late List<HomeworkAssignment> _pendingAssignments;
  late List<HomeworkAssignment> _completedAssignments;
  late List<HomeworkAssignment> _urgentAssignments;

  int _totalCompleted = 45;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _achievementAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Setup animations
    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _achievementPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _achievementAnimationController,
      curve: Curves.easeInOut,
    ));

    _updateLists();
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _headerAnimationController.forward();
  }

  void _updateLists() {
    _pendingAssignments = _allAssignments
        .where((assignment) => assignment.status == HomeworkStatus.pending)
        .toList();
    _completedAssignments = _allAssignments
        .where((assignment) => assignment.status == HomeworkStatus.completed)
        .toList();
    _urgentAssignments = _pendingAssignments
        .where((assignment) =>
    assignment.dueDate.difference(DateTime.now()).inHours <= 24)
        .toList();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _achievementAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Animated Header with Gamification
            AnimatedBuilder(
              animation: _headerSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _headerSlideAnimation.value),
                  child: _buildEnhancedHomeworkSummary(context),
                );
              },
            ),

            const SizedBox(height: 25),

            // Quick Stats Overview
            _buildQuickStatsOverview(context),

            const SizedBox(height: 25),

            // Urgent Assignments (if any)
            if (_urgentAssignments.isNotEmpty)
              _buildUrgentAssignments(context),

            // Pending Homework
            if (_pendingAssignments.isNotEmpty)
              _buildEnhancedPendingHomework(context),

            const SizedBox(height: 25),

            // Completed Homework
            if (_completedAssignments.isNotEmpty)
              _buildEnhancedCompletedHomework(context),

            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: _buildEnhancedFAB(context),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'My Homework',
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
              Icons.filter_list_rounded,
              color: Color(0xFF58CC02),
              size: 20,
            ),
          ),
          onPressed: () {
            _showFilterOptions(context);
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedHomeworkSummary(BuildContext context) {
    final completionRate = _totalCompleted > 0
        ? (_completedAssignments.length / _allAssignments.length)
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withOpacity(0.3),
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
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Your Progress 📚',
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
                      '${_pendingAssignments.length} Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_completedAssignments.length} Completed This Month',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                  ],
                ),
              ),

              // Enhanced Progress Indicator
              Stack(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: completionRate,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(completionRate * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Complete',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (_urgentAssignments.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_urgentAssignments.length} assignment${_urgentAssignments.length > 1 ? 's' : ''} due within 24 hours!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatsOverview(BuildContext context) {
    final stats = [
      StatData(
        title: 'To Do',
        value: _pendingAssignments.length.toString(),
        color: const Color(0xFF4A90E2),
        icon: Icons.assignment_outlined,
        subtitle: 'Assignments',
      ),
      StatData(
        title: 'Urgent',
        value: _urgentAssignments.length.toString(),
        color: const Color(0xFFE74C3C),
        icon: Icons.schedule_rounded,
        subtitle: 'Due soon',
      ),
      StatData(
        title: 'Done',
        value: _completedAssignments.length.toString(),
        color: const Color(0xFF58CC02),
        icon: Icons.check_circle_outlined,
        subtitle: 'Completed',
      ),

    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return _buildQuickStatCard(stats[index]);
        },
      ),
    );
  }

  Widget _buildQuickStatCard(StatData stat) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: stat.color,
            ),
          ),
          Text(
            stat.title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            stat.subtitle,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentAssignments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.priority_high_rounded,
                color: Color(0xFFE74C3C),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Urgent - Due Soon!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE74C3C),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _urgentAssignments.length,
          itemBuilder: (context, index) {
            return _buildEnhancedHomeworkCard(_urgentAssignments[index], isUrgent: true);
          },
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildEnhancedPendingHomework(BuildContext context) {
    final nonUrgentPending = _pendingAssignments
        .where((assignment) => !_urgentAssignments.contains(assignment))
        .toList();

    if (nonUrgentPending.isEmpty && _urgentAssignments.isEmpty) {
      return _buildEmptyState(
        'No pending homework! 🎉',
        'Great job! You\'re all caught up. Take some time to relax or review your completed work.',
        Icons.celebration_rounded,
        const Color(0xFF58CC02),
      );
    }

    if (nonUrgentPending.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(
                Icons.assignment_rounded,
                color: Color(0xFF4A90E2),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Upcoming Assignments',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: nonUrgentPending.length,
          itemBuilder: (context, index) {
            return _buildEnhancedHomeworkCard(nonUrgentPending[index]);
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedCompletedHomework(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF58CC02),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recently Completed',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  // View all completed homework
                },
                icon: const Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: Color(0xFF4A90E2),
                ),
                label: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _completedAssignments.length > 3 ? 3 : _completedAssignments.length,
          itemBuilder: (context, index) {
            return _buildEnhancedHomeworkCard(_completedAssignments[index]);
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedHomeworkCard(HomeworkAssignment assignment, {bool isUrgent = false}) {
    final subjectColor = _getSubjectColor(assignment.subject);
    final timeLeft = assignment.status == HomeworkStatus.pending
        ? assignment.dueDate.difference(DateTime.now())
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isUrgent
            ? Border.all(color: const Color(0xFFE74C3C), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isUrgent
                ? const Color(0xFFE74C3C).withOpacity(0.15)
                : Colors.grey.shade100,
            blurRadius: isUrgent ? 16 : 12,
            offset: Offset(0, isUrgent ? 8 : 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Subject Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  subjectColor.withOpacity(0.1),
                  subjectColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSubjectIcon(assignment.subject),
                    color: subjectColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            assignment.subject,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: subjectColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(assignment.priority).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getPriorityText(assignment.priority),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(assignment.priority),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.teacherName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (assignment.status == HomeworkStatus.completed)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF58CC02),
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),

          // Enhanced Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  assignment.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    height: 1.5,
                  ),
                ),

                if (assignment.estimatedTime != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Color(0xFF4A90E2),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Est. ${assignment.estimatedTime} mins',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A90E2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Enhanced Attachments Section
                if (assignment.attachments.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.attachment_rounded,
                        size: 16,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Attachments (${assignment.attachments.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: assignment.attachments
                        .map((file) => _buildEnhancedAttachmentChip(file))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Enhanced Bottom Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignment.status == HomeworkStatus.pending
                                ? 'Due Date'
                                : 'Submitted',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assignment.status == HomeworkStatus.pending
                                ? DateFormat('EEE, d MMM - h:mm a').format(assignment.dueDate)
                                : DateFormat('d MMM yyyy').format(assignment.submittedDate!),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          if (timeLeft != null && assignment.status == HomeworkStatus.pending) ...[
                            const SizedBox(height: 4),
                            Text(
                              _formatTimeLeft(timeLeft),
                              style: TextStyle(
                                fontSize: 12,
                                color: isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF58CC02),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (assignment.status == HomeworkStatus.pending)
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () => _submitHomework(assignment),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isUrgent ? const Color(0xFFE74C3C) : const Color(0xFF58CC02),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.upload_rounded, size: 16),
                          label: const Text(
                            'Submit',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    else if (assignment.grade != null)
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
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
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90E2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.visibility_rounded,
                              color: Color(0xFF4A90E2),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Enhanced Teacher Comments
                if (assignment.status == HomeworkStatus.completed &&
                    assignment.comments != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF58CC02).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.comment_rounded,
                              size: 16,
                              color: Color(0xFF58CC02),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Teacher\'s Feedback',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF58CC02),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          assignment.comments!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D3748),
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ],
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

  Widget _buildEnhancedAttachmentChip(String fileName) {
    final fileData = _getFileData(fileName);

    return GestureDetector(
      onTap: () => _downloadAttachment(fileName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: fileData.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: fileData.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              fileData.icon,
              size: 16,
              color: fileData.color,
            ),
            const SizedBox(width: 8),
            Text(
              fileName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fileData.color,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.download_rounded,
              size: 14,
              color: fileData.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showSubmissionOptions(context);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 24,
        ),
        label: const Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatTimeLeft(Duration timeLeft) {
    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays} day${timeLeft.inDays > 1 ? 's' : ''} left';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours} hour${timeLeft.inHours > 1 ? 's' : ''} left';
    } else if (timeLeft.inMinutes > 0) {
      return '${timeLeft.inMinutes} minutes left';
    } else {
      return 'Due now!';
    }
  }

  FileData _getFileData(String fileName) {
    if (fileName.endsWith('.pdf')) {
      return FileData(Icons.picture_as_pdf_rounded, const Color(0xFFE74C3C));
    } else if (fileName.endsWith('.docx') || fileName.endsWith('.doc')) {
      return FileData(Icons.description_rounded, const Color(0xFF4A90E2));
    } else if (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) {
      return FileData(Icons.table_chart_rounded, const Color(0xFF58CC02));
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
      return FileData(Icons.image_rounded, const Color(0xFFFF9500));
    } else {
      return FileData(Icons.insert_drive_file_rounded, const Color(0xFF718096));
    }
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
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF718096);
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'english':
        return Icons.menu_book_rounded;
      case 'history':
        return Icons.history_edu_rounded;
      case 'geography':
        return Icons.public_rounded;
      case 'computer science':
        return Icons.computer_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _getPriorityColor(HomeworkPriority priority) {
    switch (priority) {
      case HomeworkPriority.urgent:
        return const Color(0xFFE74C3C);
      case HomeworkPriority.high:
        return const Color(0xFFFF9500);
      case HomeworkPriority.medium:
        return const Color(0xFF4A90E2);
      case HomeworkPriority.low:
        return const Color(0xFF58CC02);
    }
  }

  String _getPriorityText(HomeworkPriority priority) {
    switch (priority) {
      case HomeworkPriority.urgent:
        return 'URGENT';
      case HomeworkPriority.high:
        return 'HIGH';
      case HomeworkPriority.medium:
        return 'MEDIUM';
      case HomeworkPriority.low:
        return 'LOW';
    }
  }

  // Action Methods
  void _submitHomework(HomeworkAssignment assignment) {
    // Implement homework submission
  }

  void _downloadAttachment(String fileName) {
    // Implement file download
  }

  void _showFilterOptions(BuildContext context) {
    // Show filter bottom sheet
  }

  void _showSubmissionOptions(BuildContext context) {
    // Show submission options bottom sheet
  }
}

// Enhanced Data Models
enum HomeworkStatus { pending, completed }
enum HomeworkPriority { low, medium, high, urgent }

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
  final HomeworkPriority priority;
  final int? estimatedTime; // in minutes

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
    this.priority = HomeworkPriority.medium,
    this.estimatedTime,
  });
}

class StatData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final String subtitle;

  const StatData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.subtitle,
  });
}

class FileData {
  final IconData icon;
  final Color color;

  const FileData(this.icon, this.color);
}

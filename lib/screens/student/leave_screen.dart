import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/services/leave_service.dart';
import 'package:dps/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _streakAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _streakPulseAnimation;

  // Real data from API
  List<StudentLeaveRecord> _studentLeaves = [];
  List<LeaveRequest> _leaveRequests = [];
  bool _isLoading = true;

  int _consecutiveApprovals = 5;
  int _totalLeaveDays = 15;

  // Persist leave application form state
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _fromDate = DateTime.now().add(const Duration(days: 1));
  DateTime _toDate = DateTime.now().add(const Duration(days: 1));
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _streakAnimationController = AnimationController(
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

    _streakPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _streakAnimationController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
    _loadLeaveData();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _headerAnimationController.forward();
  }

  Future<void> _loadLeaveData() async {
    debugPrint('=== LEAVE SCREEN DEBUG START ===');
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Leave Screen - Calling LeaveService.getStudentLeaves()');
      final studentLeaves = await LeaveService.getStudentLeaves();
      debugPrint('Leave Screen - Received ${studentLeaves.length} student leave records');

      // Convert to legacy format for compatibility with existing UI
      final leaveRequests = studentLeaves.map((leave) => leave.toLegacyLeaveRequest()).toList();
      debugPrint('Leave Screen - Converted to ${leaveRequests.length} legacy leave requests');

      setState(() {
        _studentLeaves = studentLeaves;
        _leaveRequests = leaveRequests;
        _isLoading = false;
      });

      debugPrint('Leave Screen - State updated successfully');
      debugPrint('=== LEAVE SCREEN DEBUG END ===');
    } catch (e, stackTrace) {
      debugPrint('Leave Screen - Error occurred: $e');
      debugPrint('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        CustomSnackbar.showError(
          context,
          message: 'Failed to load leave data. Please try again.',
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _streakAnimationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildEnhancedAppBar(context),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pendingLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.pending).toList();
    final approvedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.approved).toList();
    final rejectedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.rejected).toList();
    final consumedLeaveDays = _getTotalApprovedLeaveDays();
    final remainingLeaveDays = _totalLeaveDays - consumedLeaveDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: RefreshIndicator(
        onRefresh: _loadLeaveData,
        child: Column(
          children: [
            // Enhanced Tab Section
            _buildEnhancedTabSection(context),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEnhancedLeaveList(
                    context,
                    pendingLeaves,
                    'No pending leave requests! 📝',
                    'All your leave applications are processed. Apply for new leave using the button below.',
                    Icons.pending_actions_rounded,
                    const Color(0xFFFF9500),
                  ),
                  _buildEnhancedLeaveList(
                    context,
                    approvedLeaves,
                    'No approved leaves yet! ✅',
                    'Your approved leave requests will appear here once processed by your teacher.',
                    Icons.check_circle_rounded,
                    const Color(0xFF58CC02),
                  ),
                  _buildEnhancedLeaveList(
                    context,
                    rejectedLeaves,
                    'No rejected leaves! 🎉',
                    'Great! You haven\'t had any leave requests rejected. Keep maintaining good communication.',
                    Icons.cancel_rounded,
                    const Color(0xFFE74C3C),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildEnhancedFAB(context),
    );
  }

  // Rest of the existing UI methods remain the same
  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Leave Management',
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
              color: const Color(0xFF8E44AD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF8E44AD),
              size: 20,
            ),
          ),
          onPressed: _loadLeaveData,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedTabSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF8E44AD),
        unselectedLabelColor: const Color(0xFF718096),
        indicatorColor: const Color(0xFF8E44AD),
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_empty_rounded, size: 14),
                const SizedBox(width: 2),
                Text('Pending (${_leaveRequests.where((leave) => leave.status == LeaveStatus.pending).length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 14),
                const SizedBox(width: 2),
                Text('Approved (${_leaveRequests.where((leave) => leave.status == LeaveStatus.approved).length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cancel_outlined, size: 14),
                const SizedBox(width: 2),
                Text('Rejected (${_leaveRequests.where((leave) => leave.status == LeaveStatus.rejected).length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLeaveList(
      BuildContext context,
      List<LeaveRequest> leaves,
      String emptyTitle,
      String emptyMessage,
      IconData emptyIcon,
      Color emptyColor,
      ) {
    if (leaves.isEmpty) {
      return _buildEmptyState(emptyTitle, emptyMessage, emptyIcon, emptyColor);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        return _buildEnhancedLeaveCard(leaves[index]);
      },
    );
  }

  // Enhanced leave card that shows real data
  Widget _buildEnhancedLeaveCard(LeaveRequest leave) {
    final statusColor = _getStatusColor(leave.status);
    final statusIcon = _getStatusIcon(leave.status);
    // final typeColor = _getLeaveTypeColor(leave.leaveType);
    final daysCount = leave.toDate.difference(leave.fromDate).inDays + 1;

    // Find the corresponding StudentLeaveRecord for additional info
    final studentLeave = _studentLeaves.firstWhere(
          (sl) => sl.sleaveId.toString() == leave.id.replaceAll('SL-', '').replaceAll(RegExp(r'^0+'), ''),
      orElse: () => StudentLeaveRecord(
        sleaveId: 0,
        student: '',
        className: '',
        division: '',
        employee: '',
        status: '',
        description: '',
        toDate: DateTime.now(),
        fromDate: DateTime.now(),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.1),
                  statusColor.withOpacity(0.05),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.2),
                        statusColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              leave.reason,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          //   decoration: BoxDecoration(
                          //     color: typeColor.withOpacity(0.1),
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   child: Text(
                          //     _getLeaveTypeText(leave.leaveType),
                          //     style: TextStyle(
                          //       fontSize: 10,
                          //       fontWeight: FontWeight.bold,
                          //       color: typeColor,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Text(
                      //   'ID: ${leave.id}',
                      //   style: const TextStyle(
                      //     fontSize: 12,
                      //     color: Color(0xFF718096),
                      //   ),
                      // ),
                      if (studentLeave.className.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Class: ${studentLeave.className} - Div: ${studentLeave.division}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(leave.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
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
                // Date Range Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E44AD).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateColumn(
                              'From Date',
                              DateFormat('dd MMM yyyy').format(leave.fromDate),
                              Icons.event_rounded,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E44AD).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF8E44AD),
                              size: 16,
                            ),
                          ),
                          Expanded(
                            child: _buildDateColumn(
                              'To Date',
                              DateFormat('dd MMM yyyy').format(leave.toDate),
                              Icons.event_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$daysCount ${daysCount > 1 ? 'Days' : 'Day'} Leave',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Description Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.description_rounded,
                          color: Color(0xFF718096),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        leave.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2D3748),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Timeline Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildTimelineItem(
                        'Applied',
                        DateFormat('dd MMM yyyy, h:mm a').format(leave.appliedOn),
                        Icons.send_rounded,
                        const Color(0xFF4A90E2),
                        isCompleted: true,
                      ),
                      if (leave.status != LeaveStatus.pending) ...[
                        const SizedBox(height: 12),
                        _buildTimelineItem(
                          _getStatusText(leave.status),
                          leave.actionOn != null
                              ? DateFormat('dd MMM yyyy, h:mm a').format(leave.actionOn!)
                              : 'Pending',
                          _getStatusIcon(leave.status),
                          statusColor,
                          isCompleted: leave.status != LeaveStatus.pending,
                        ),
                      ],
                    ],
                  ),
                ),

                // Action By Section (Teacher/Employee)
                if (leave.actionBy != null && studentLeave.employee.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: statusColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Processed by',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                              ),
                            ),
                            Text(
                              studentLeave.employee,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                // Action Buttons for Pending Leaves
                // if (leave.status == LeaveStatus.pending) ...[
                //   const SizedBox(height: 20),
                //   Row(
                //     children: [
                //       Expanded(
                //         child: OutlinedButton.icon(
                //           onPressed: () => _cancelLeaveRequest(leave),
                //           style: OutlinedButton.styleFrom(
                //             side: const BorderSide(color: Color(0xFFE74C3C)),
                //             foregroundColor: const Color(0xFFE74C3C),
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(12),
                //             ),
                //             padding: const EdgeInsets.symmetric(vertical: 12),
                //           ),
                //           icon: const Icon(Icons.cancel_rounded, size: 16),
                //           label: const Text(
                //             'Cancel Request',
                //             style: TextStyle(fontWeight: FontWeight.w600),
                //           ),
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       Expanded(
                //         child: ElevatedButton.icon(
                //           onPressed: () => _editLeaveRequest(leave),
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: const Color(0xFF4A90E2),
                //             foregroundColor: Colors.white,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(12),
                //             ),
                //             padding: const EdgeInsets.symmetric(vertical: 12),
                //           ),
                //           icon: const Icon(Icons.edit_rounded, size: 16),
                //           label: const Text(
                //             'Edit',
                //             style: TextStyle(fontWeight: FontWeight.w600),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Keep all existing helper methods
  Widget _buildDateColumn(String label, String date, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF8E44AD),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
      String title,
      String time,
      IconData icon,
      Color color, {
        bool isCompleted = false,
      }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isCompleted ? Colors.white : color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? const Color(0xFF2D3748) : const Color(0xFF718096),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? const Color(0xFF718096) : const Color(0xFFA0AEC0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 24),
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
      ),
    );
  }

  Widget _buildEnhancedFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E44AD).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showNewLeaveApplication(context);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 24,
        ),
        label: const Text(
          'Apply Leave',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Helper Methods
  int _getTotalApprovedLeaveDays() {
    final approvedLeaves = _leaveRequests
        .where((leave) => leave.status == LeaveStatus.approved)
        .toList();

    int total = 0;
    for (var leave in approvedLeaves) {
      total += leave.toDate.difference(leave.fromDate).inDays + 1;
    }
    return total;
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return const Color(0xFFFF9500);
      case LeaveStatus.approved:
        return const Color(0xFF58CC02);
      case LeaveStatus.rejected:
        return const Color(0xFFE74C3C);
    }
  }

  IconData _getStatusIcon(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return Icons.hourglass_empty_rounded;
      case LeaveStatus.approved:
        return Icons.check_circle_rounded;
      case LeaveStatus.rejected:
        return Icons.cancel_rounded;
    }
  }

  String _getStatusText(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }

  // Color _getLeaveTypeColor(LeaveType type) {
  //   switch (type) {
  //     case LeaveType.sick:
  //       return const Color(0xFFE74C3C);
  //     case LeaveType.personal:
  //       return const Color(0xFF4A90E2);
  //     case LeaveType.emergency:
  //       return const Color(0xFFFF9500);
  //   }
  // }

  // String _getLeaveTypeText(LeaveType type) {
  //   switch (type) {
  //     case LeaveType.sick:
  //       return 'Medical';
  //     case LeaveType.personal:
  //       return 'Personal';
  //     case LeaveType.emergency:
  //       return 'Emergency';
  //   }
  // }

  // Action Methods
  // void _cancelLeaveRequest(LeaveRequest leave) {
  //   // TODO: Implement cancel leave request
  //   CustomSnackbar.showInfo(
  //     context,
  //     message: 'Cancel leave feature will be implemented soon.',
  //   );
  // }
  //
  // void _editLeaveRequest(LeaveRequest leave) {
  //   // TODO: Implement edit leave request
  //   CustomSnackbar.showInfo(
  //     context,
  //     message: 'Edit leave feature will be implemented soon.',
  //   );
  // }

  void _showNewLeaveApplication(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => _buildLeaveApplicationForm(context, scrollController),
      ),
    );
  }

  Widget _buildLeaveApplicationForm(BuildContext context, ScrollController scrollController) {
    return StatefulBuilder(
      builder: (context, setModalState) {
                return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Dismiss keyboard when tapping on the header area
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Dismiss keyboard when tapping on the title area
                    FocusScope.of(context).unfocus();
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        color: Color(0xFF8E44AD),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Apply for Leave',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(), // Better scroll physics
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // From Date
                      GestureDetector(
                        onTap: () {
                          // Dismiss keyboard when tapping on the label
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text(
                          'From Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          // Dismiss keyboard before showing date picker
                          FocusScope.of(context).unfocus();
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _fromDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setModalState(() {
                              _fromDate = date;
                              if (_toDate.isBefore(_fromDate)) {
                                _toDate = _fromDate;
                              }
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF8E44AD)),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd MMM yyyy').format(_fromDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // To Date
                      GestureDetector(
                        onTap: () {
                          // Dismiss keyboard when tapping on the label
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text(
                          'To Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          // Dismiss keyboard before showing date picker
                          FocusScope.of(context).unfocus();
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _toDate,
                            firstDate: _fromDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setModalState(() {
                              _toDate = date;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF8E44AD)),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd MMM yyyy').format(_toDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      GestureDetector(
                        onTap: () {
                          // Dismiss keyboard when tapping on the label
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        textInputAction: TextInputAction.done, // Shows "Done" button on keyboard
                        onSubmitted: (_) {
                          // Dismiss keyboard when user taps "Done"
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter reason for leave...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF8E44AD)),
                          ),
                          // Add suffix icon to dismiss keyboard
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.keyboard_hide),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Add some empty space that can be tapped to dismiss keyboard
                      GestureDetector(
                        onTap: () {
                          // Dismiss keyboard when tapping on empty space
                          FocusScope.of(context).unfocus();
                        },
                        child: Container(
                          height: 20,
                          color: Colors.transparent,
                        ),
                      ),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () async {
                            // Dismiss keyboard before submitting
                            FocusScope.of(context).unfocus();
                            
                            if (_descriptionController.text.trim().isEmpty) {
                              CustomSnackbar.showError(
                                context,
                                message: 'Please enter a description for your leave.',
                              );
                              return;
                            }

                            setModalState(() {
                              _isSubmitting = true;
                            });

                            try {
                              debugPrint('=== SUBMITTING LEAVE APPLICATION ===');
                              final success = await LeaveService.addLeave(
                                fromDate: DateFormat('dd-MM-yyyy').format(_fromDate),
                                toDate: DateFormat('dd-MM-yyyy').format(_toDate),
                                description: _descriptionController.text.trim(),
                              );

                              if (success) {
                                Navigator.pop(context);
                                CustomSnackbar.showSuccess(
                                  context,
                                  message: 'Leave application submitted successfully!',
                                );
                                _loadLeaveData(); // Refresh the data
                              } else {
                                CustomSnackbar.showError(
                                  context,
                                  message: 'Failed to submit leave application. Please try again.',
                                );
                              }
                            } catch (e) {
                              debugPrint('Error submitting leave: $e');
                              CustomSnackbar.showError(
                                context,
                                message: 'An error occurred. Please try again.',
                              );
                            } finally {
                              setModalState(() {
                                _isSubmitting = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E44AD),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                            'Submit Leave Application',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ), // Close SingleChildScrollView
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Keep existing FileData class
class FileData {
  final IconData icon;
  final Color color;
  const FileData(this.icon, this.color);
}

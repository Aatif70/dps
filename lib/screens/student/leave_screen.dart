import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
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

  // Enhanced mock data for leave requests
  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 'LR-2024-001',
      reason: 'Medical Leave',
      description: 'Suffering from viral fever and doctor has advised complete rest for recovery',
      fromDate: DateTime.now().add(const Duration(days: 3)),
      toDate: DateTime.now().add(const Duration(days: 5)),
      status: LeaveStatus.pending,
      appliedOn: DateTime.now().subtract(const Duration(hours: 3)),
      leaveType: LeaveType.sick,
      attachments: ['Medical_Certificate.pdf'],
    ),
    LeaveRequest(
      id: 'LR-2024-002',
      reason: 'Family Function',
      description: 'Need to attend my cousin\'s wedding ceremony at my hometown',
      fromDate: DateTime.now().add(const Duration(days: 10)),
      toDate: DateTime.now().add(const Duration(days: 12)),
      status: LeaveStatus.approved,
      appliedOn: DateTime.now().subtract(const Duration(days: 5)),
      actionBy: 'Ms. Deepa Sharma',
      actionOn: DateTime.now().subtract(const Duration(days: 3)),
      leaveType: LeaveType.personal,
    ),
    LeaveRequest(
      id: 'LR-2024-003',
      reason: 'Personal Emergency',
      description: 'Family emergency requiring immediate attention and travel',
      fromDate: DateTime.now().subtract(const Duration(days: 8)),
      toDate: DateTime.now().subtract(const Duration(days: 7)),
      status: LeaveStatus.approved,
      appliedOn: DateTime.now().subtract(const Duration(days: 10)),
      actionBy: 'Mr. Rajesh Kumar',
      actionOn: DateTime.now().subtract(const Duration(days: 9)),
      leaveType: LeaveType.emergency,
    ),
    LeaveRequest(
      id: 'LR-2024-004',
      reason: 'Religious Festival',
      description: 'Need to attend a religious ceremony at my native place for cultural obligations',
      fromDate: DateTime.now().subtract(const Duration(days: 15)),
      toDate: DateTime.now().subtract(const Duration(days: 12)),
      status: LeaveStatus.rejected,
      appliedOn: DateTime.now().subtract(const Duration(days: 20)),
      actionBy: 'Ms. Deepa Sharma',
      actionOn: DateTime.now().subtract(const Duration(days: 18)),
      remarks: 'Leave application submitted too late. Please apply at least one week in advance for planned absences.',
      leaveType: LeaveType.personal,
    ),
  ];

  int _consecutiveApprovals = 5;
  int _totalLeaveDays = 15;

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
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _headerAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _streakAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.pending).toList();
    final approvedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.approved).toList();
    final rejectedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.rejected).toList();

    final consumedLeaveDays = _getTotalApprovedLeaveDays();
    final remainingLeaveDays = _totalLeaveDays - consumedLeaveDays;


    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: Column(
        children: [


          // Enhanced Animated Leave Balance
          AnimatedBuilder(
            animation: _headerSlideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _headerSlideAnimation.value),
                child: _buildEnhancedLeaveBalance(
                    context,
                    _totalLeaveDays,
                    consumedLeaveDays,
                    remainingLeaveDays
                ),
              );
            },
          ),

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
      floatingActionButton: _buildEnhancedFAB(context),
    );
  }

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
              Icons.calendar_month_rounded,
              color: Color(0xFF8E44AD),
              size: 20,
            ),
          ),
          onPressed: () {
            _showLeaveCalendar(context);
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedLeaveBalance(
      BuildContext context,
      int total,
      int consumed,
      int remaining,
      ) {
    final usagePercentage = total > 0 ? consumed / total : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E44AD).withOpacity(0.3),
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
                          Icons.event_available_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Leave Balance 🏖️',
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
                      '$remaining Days Left',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$consumed of $total days used',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Enhanced Achievement Badge
                    AnimatedBuilder(
                      animation: _streakPulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: _streakPulseAnimation.value,
                                child: const Icon(
                                  Icons.trending_up_rounded,
                                  color: Color(0xFF58CC02),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_consecutiveApprovals Approved Streak! 🎯',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Enhanced Progress Ring
              Stack(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: usagePercentage,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        usagePercentage > 0.8 ? Colors.orange : Colors.white,
                      ),
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
                            '${(usagePercentage * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Used',
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

          const SizedBox(height: 20),

          // Enhanced Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceStatItem('Total', total, Icons.calendar_today_rounded),
                _buildStatDivider(),
                _buildBalanceStatItem('Used', consumed, Icons.event_busy_rounded),
                _buildStatDivider(),
                _buildBalanceStatItem('Available', remaining, Icons.event_available_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildEnhancedTabSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_empty_rounded, size: 16),
                const SizedBox(width: 6),
                const Text('Pending'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 16),
                const SizedBox(width: 6),
                const Text('Approved'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cancel_outlined, size: 16),
                const SizedBox(width: 6),
                const Text('Rejected'),
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

  Widget _buildEnhancedLeaveCard(LeaveRequest leave) {
    final statusColor = _getStatusColor(leave.status);
    final statusIcon = _getStatusIcon(leave.status);
    final typeColor = _getLeaveTypeColor(leave.leaveType);
    final daysCount = leave.toDate.difference(leave.fromDate).inDays + 1;

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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getLeaveTypeText(leave.leaveType),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${leave.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
                      ),
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

                // Attachments Section
                if (leave.attachments.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.attachment_rounded,
                        color: Color(0xFF718096),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Attachments (${leave.attachments.length})',
                        style: const TextStyle(
                          fontSize: 14,
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
                    children: leave.attachments
                        .map((file) => _buildAttachmentChip(file))
                        .toList(),
                  ),
                ],

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

                // Action By Section
                if (leave.actionBy != null) ...[
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
                              '${_getStatusText(leave.status)} by',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF718096),
                              ),
                            ),
                            Text(
                              leave.actionBy!,
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

                // Remarks Section
                if (leave.remarks != null && leave.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: leave.status == LeaveStatus.rejected
                          ? const Color(0xFFE74C3C).withOpacity(0.05)
                          : const Color(0xFF58CC02).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: leave.status == LeaveStatus.rejected
                            ? const Color(0xFFE74C3C).withOpacity(0.2)
                            : const Color(0xFF58CC02).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.comment_rounded,
                              size: 16,
                              color: leave.status == LeaveStatus.rejected
                                  ? const Color(0xFFE74C3C)
                                  : const Color(0xFF58CC02),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remarks',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: leave.status == LeaveStatus.rejected
                                    ? const Color(0xFFE74C3C)
                                    : const Color(0xFF58CC02),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          leave.remarks!,
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

                // Action Buttons for Pending Leaves
                if (leave.status == LeaveStatus.pending) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelLeaveRequest(leave),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE74C3C)),
                            foregroundColor: const Color(0xFFE74C3C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.cancel_rounded, size: 16),
                          label: const Text(
                            'Cancel Request',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _editLeaveRequest(leave),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: const Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      Color color,
      {bool isCompleted = false}
      ) {
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

  Widget _buildAttachmentChip(String fileName) {
    final fileData = _getFileData(fileName);

    return GestureDetector(
      onTap: () => _viewAttachment(fileName),
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
            Flexible(
              child: Text(
                fileName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fileData.color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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
        shape: BoxShape.circle,
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

  Color _getLeaveTypeColor(LeaveType type) {
    switch (type) {
      case LeaveType.sick:
        return const Color(0xFFE74C3C);
      case LeaveType.personal:
        return const Color(0xFF4A90E2);
      case LeaveType.emergency:
        return const Color(0xFFFF9500);
    }
  }

  String _getLeaveTypeText(LeaveType type) {
    switch (type) {
      case LeaveType.sick:
        return 'Medical';
      case LeaveType.personal:
        return 'Personal';
      case LeaveType.emergency:
        return 'Emergency';
    }
  }

  FileData _getFileData(String fileName) {
    if (fileName.endsWith('.pdf')) {
      return FileData(Icons.picture_as_pdf_rounded, const Color(0xFFE74C3C));
    } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
      return FileData(Icons.description_rounded, const Color(0xFF4A90E2));
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) {
      return FileData(Icons.image_rounded, const Color(0xFF58CC02));
    } else {
      return FileData(Icons.insert_drive_file_rounded, const Color(0xFF718096));
    }
  }

  // Action Methods
  void _showLeaveCalendar(BuildContext context) {
    // Show leave calendar
  }

  void _cancelLeaveRequest(LeaveRequest leave) {
    // Cancel leave request
  }

  void _editLeaveRequest(LeaveRequest leave) {
    // Edit leave request
  }

  void _viewAttachment(String fileName) {
    // View attachment
  }

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
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

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  // Leave application form fields would go here
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.construction_rounded,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Leave Application Form',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Form implementation in progress',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Data Models
enum LeaveStatus { pending, approved, rejected }
enum LeaveType { sick, personal, emergency }

class LeaveRequest {
  final String id;
  final String reason;
  final String description;
  final DateTime fromDate;
  final DateTime toDate;
  final LeaveStatus status;
  final DateTime appliedOn;
  final String? actionBy;
  final DateTime? actionOn;
  final String? remarks;
  final LeaveType leaveType;
  final List<String> attachments;

  const LeaveRequest({
    required this.id,
    required this.reason,
    required this.description,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.appliedOn,
    this.actionBy,
    this.actionOn,
    this.remarks,
    this.leaveType = LeaveType.personal,
    this.attachments = const [],
  });
}

class FileData {
  final IconData icon;
  final Color color;

  const FileData(this.icon, this.color);
}

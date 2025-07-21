import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for leave requests
  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 'LR-2023-001',
      reason: 'Medical Leave',
      description: 'Suffering from viral fever and doctor has advised rest',
      fromDate: DateTime.now().add(const Duration(days: 3)),
      toDate: DateTime.now().add(const Duration(days: 5)),
      status: LeaveStatus.pending,
      appliedOn: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    LeaveRequest(
      id: 'LR-2023-002',
      reason: 'Family Function',
      description: 'Need to attend my cousin\'s wedding',
      fromDate: DateTime.now().add(const Duration(days: 10)),
      toDate: DateTime.now().add(const Duration(days: 12)),
      status: LeaveStatus.approved,
      appliedOn: DateTime.now().subtract(const Duration(days: 5)),
      actionBy: 'Ms. Deepa Sharma',
      actionOn: DateTime.now().subtract(const Duration(days: 3)),
    ),
    LeaveRequest(
      id: 'LR-2023-003',
      reason: 'Personal Emergency',
      description: 'Family emergency requiring immediate attention',
      fromDate: DateTime.now().subtract(const Duration(days: 8)),
      toDate: DateTime.now().subtract(const Duration(days: 7)),
      status: LeaveStatus.approved,
      appliedOn: DateTime.now().subtract(const Duration(days: 10)),
      actionBy: 'Mr. Rajesh Kumar',
      actionOn: DateTime.now().subtract(const Duration(days: 9)),
    ),
    LeaveRequest(
      id: 'LR-2023-004',
      reason: 'Religious Festival',
      description: 'Need to attend a religious ceremony at my native place',
      fromDate: DateTime.now().subtract(const Duration(days: 15)),
      toDate: DateTime.now().subtract(const Duration(days: 12)),
      status: LeaveStatus.rejected,
      appliedOn: DateTime.now().subtract(const Duration(days: 20)),
      actionBy: 'Ms. Deepa Sharma',
      actionOn: DateTime.now().subtract(const Duration(days: 18)),
      remarks: 'Leave application submitted too late. Please apply at least one week in advance for planned absences.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.pending).toList();
    final approvedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.approved).toList();
    final rejectedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.rejected).toList();
    
    // Calculate leave balance
    final totalLeaveDays = 15;
    final consumedLeaveDays = _getTotalApprovedLeaveDays();
    final remainingLeaveDays = totalLeaveDays - consumedLeaveDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.leave),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8E44AD),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF8E44AD),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildLeaveBalance(totalLeaveDays, consumedLeaveDays, remainingLeaveDays),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaveList(pendingLeaves, 'No pending leave requests'),
                _buildLeaveList(approvedLeaves, 'No approved leave requests'),
                _buildLeaveList(rejectedLeaves, 'No rejected leave requests'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Apply new leave
        },
        backgroundColor: const Color(0xFF8E44AD),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLeaveBalance(int total, int consumed, int remaining) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E44AD).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBalanceItem('Total', total),
          _buildDivider(),
          _buildBalanceItem('Consumed', consumed),
          _buildDivider(),
          _buildBalanceItem('Remaining', remaining, isHighlighted: true),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, int value, {bool isHighlighted = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: isHighlighted ? 26 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Days',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildLeaveList(List<LeaveRequest> leaves, String emptyMessage) {
    if (leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        return _buildLeaveCard(leaves[index]);
      },
    );
  }

  Widget _buildLeaveCard(LeaveRequest leave) {
    final fromDate = DateFormat('dd MMM yyyy').format(leave.fromDate);
    final toDate = DateFormat('dd MMM yyyy').format(leave.toDate);
    final daysCount = leave.toDate.difference(leave.fromDate).inDays + 1;

    Color statusColor;
    IconData statusIcon;

    switch (leave.status) {
      case LeaveStatus.pending:
        statusColor = const Color(0xFFFF9500);
        statusIcon = Icons.hourglass_empty;
        break;
      case LeaveStatus.approved:
        statusColor = const Color(0xFF58CC02);
        statusIcon = Icons.check_circle;
        break;
      case LeaveStatus.rejected:
        statusColor = const Color(0xFFE74C3C);
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              color: statusColor.withOpacity(0.1),
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
                    color: statusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  leave.reason,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fromDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            toDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E44AD).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$daysCount ${daysCount > 1 ? 'Days' : 'Day'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8E44AD),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Reason:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leave.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Applied On',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy, h:mm a').format(leave.appliedOn),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (leave.status != LeaveStatus.pending)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getStatusText(leave.status)} By',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              leave.actionBy ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (leave.remarks != null && leave.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Remarks:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    leave.remarks!,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: leave.status == LeaveStatus.rejected
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFF2D3748),
                    ),
                  ),
                ],
                if (leave.status == LeaveStatus.pending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Cancel leave request
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE74C3C)),
                            foregroundColor: const Color(0xFFE74C3C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Cancel Request'),
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

  int _getTotalApprovedLeaveDays() {
    final approvedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.approved).toList();
    int total = 0;
    
    for (var leave in approvedLeaves) {
      total += leave.toDate.difference(leave.fromDate).inDays + 1;
    }
    
    return total;
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
}

enum LeaveStatus { pending, approved, rejected }

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
  });
} 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';
import '../../services/teacher_leave_service.dart';

class TeacherLeaveScreen extends StatefulWidget {
  const TeacherLeaveScreen({super.key});

  @override
  State<TeacherLeaveScreen> createState() => _TeacherLeaveScreenState();
}

class _TeacherLeaveScreenState extends State<TeacherLeaveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<LeaveRequest> _leaveRequests = [];
  bool _isLoading = true;

  // Date range for fetching data
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaveData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaveData() async {
    setState(() => _isLoading = true);
    try {
      final leaveList = await TeacherLeaveService.getLeaveList(
        fromDate: _fromDate,
        toDate: _toDate,
      );
      setState(() {
        _leaveRequests = leaveList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading leave data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8E44AD),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadLeaveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.pending).toList();
    final approvedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.approved).toList();
    final rejectedLeaves = _leaveRequests.where((leave) => leave.status == LeaveStatus.rejected).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8E44AD)))
          : RefreshIndicator(
        onRefresh: _loadLeaveData,
        child: Column(
          children: [
            _buildEnhancedTabSection(context),
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
      ),
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
              Icons.date_range,
              color: Color(0xFF8E44AD),
              size: 20,
            ),
          ),
          onPressed: _selectDateRange,
        ),
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

  Widget _buildLeaveList(List<LeaveRequest> leaves, String emptyMessage) {
    if (leaves.isEmpty) {
      return _buildEnhancedEmptyState(emptyMessage);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        return _buildEnhancedLeaveCard(leaves[index]);
      },
    );
  }

  Widget _buildEnhancedEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF8E44AD).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: Color(0xFF8E44AD),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${DateFormat('MMM dd').format(_fromDate)} - ${DateFormat('MMM dd, yyyy').format(_toDate)}',
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

  Widget _buildEnhancedLeaveCard(LeaveRequest leave) {
    final statusColor = _getStatusColor(leave.status);
    final statusIcon = _getStatusIcon(leave.status);
    final isPending = leave.status == LeaveStatus.pending;
    final daysCount = _calculateDays(leave.fromDate, leave.toDate);

    return GestureDetector(
      onTap: () {
        if (isPending) {
          _showLeaveDetailDialog(context, leave);
        }
      },
      child: Container(
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
          // Header
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
                  child: Icon(statusIcon, color: statusColor, size: 24),
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
                              leave.student,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${leave.className} - Div: ${leave.division}',
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
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
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

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dates
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
                            const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
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

                // Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.description_rounded, color: Color(0xFF718096), size: 16),
                        SizedBox(width: 8),
                        Text(
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
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
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

                // Timeline-like section (applied/processed)
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
                        DateFormat('dd MMM yyyy').format(leave.fromDate),
                        Icons.send_rounded,
                        const Color(0xFF4A90E2),
                        isCompleted: true,
                      ),
                      if (leave.status != LeaveStatus.pending) ...[
                        const SizedBox(height: 12),
                        _buildTimelineItem(
                          _getStatusText(leave.status),
                          '-',
                          _getStatusIcon(leave.status),
                          statusColor,
                          isCompleted: true,
                        ),
                      ],
                    ],
                  ),
                ),

                if ((leave.employee ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_rounded, color: statusColor, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Processed by',
                              style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        leave.employee ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ],

                if (isPending) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _rejectLeave(leave),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE74C3C)),
                            foregroundColor: const Color(0xFFE74C3C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approveLeave(leave),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E44AD),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Approve'),
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
    ),
    );
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

  Widget _buildDateColumn(String label, String date, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8E44AD), size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
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

  Widget _buildTimelineItem(String title, String time, IconData icon, Color color, {bool isCompleted = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isCompleted ? Colors.white : color, size: 16),
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

  void _showLeaveDetailDialog(BuildContext context, LeaveRequest leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Student', leave.student),
              _buildDetailItem('Class', leave.className),
              _buildDetailItem('Division', leave.division),
              _buildDetailItem('Description', leave.description),
              _buildDetailItem('From Date', DateFormat('dd MMM, yyyy').format(leave.fromDate)),
              _buildDetailItem('To Date', DateFormat('dd MMM, yyyy').format(leave.toDate)),
              _buildDetailItem('Duration', '${_calculateDays(leave.fromDate, leave.toDate)} days'),
              if (leave.doc != null && leave.doc!.isNotEmpty)
                _buildDetailItem('Attachment', 'Document attached'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectLeave(leave);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveLeave(leave);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E44AD),
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _approveLeave(LeaveRequest leave) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF8E44AD)),
      ),
    );

    try {
      final success = await TeacherLeaveService.approveOrRejectLeave(
        leaveId: leave.sleaveId,
        status: 'Approved',
      );

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request approved successfully'),
            backgroundColor: Color(0xFF8E44AD),
          ),
        );
        _loadLeaveData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to approve leave request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _rejectLeave(LeaveRequest leave) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF8E44AD)),
      ),
    );

    try {
      final success = await TeacherLeaveService.approveOrRejectLeave(
        leaveId: leave.sleaveId,
        status: 'Rejected',
      );

      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request rejected'),
            backgroundColor: Color(0xFFE74C3C),
          ),
        );
        _loadLeaveData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject leave request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _calculateDays(DateTime fromDate, DateTime toDate) {
    return toDate.difference(fromDate).inDays + 1;
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

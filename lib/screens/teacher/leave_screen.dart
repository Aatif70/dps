import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class TeacherLeaveScreen extends StatefulWidget {
  const TeacherLeaveScreen({super.key});

  @override
  State<TeacherLeaveScreen> createState() => _TeacherLeaveScreenState();
}

class _TeacherLeaveScreenState extends State<TeacherLeaveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data for leave requests
  final List<LeaveRequest> _leaveRequests = [
    LeaveRequest(
      id: 'LR-2023-001',
      studentName: 'Priya Sharma',
      studentClass: 'Class 10-A',
      rollNumber: '12',
      reason: 'Medical Leave',
      description: 'Suffering from viral fever and doctor has advised rest',
      fromDate: DateTime.now().add(const Duration(days: 3)),
      toDate: DateTime.now().add(const Duration(days: 5)),
      status: LeaveStatus.pending,
      appliedOn: DateTime.now().subtract(const Duration(hours: 3)),
      attachments: ['Medical_Certificate.pdf'],
    ),
    LeaveRequest(
      id: 'LR-2023-002',
      studentName: 'Rahul Kumar',
      studentClass: 'Class 10-B',
      rollNumber: '05',
      reason: 'Family Function',
      description: 'Need to attend cousin\'s wedding',
      fromDate: DateTime.now().add(const Duration(days: 10)),
      toDate: DateTime.now().add(const Duration(days: 12)),
      status: LeaveStatus.approved,
      appliedOn: DateTime.now().subtract(const Duration(days: 5)),
      actionBy: 'Dr. Rajesh Kumar',
      actionOn: DateTime.now().subtract(const Duration(days: 3)),
    ),
    LeaveRequest(
      id: 'LR-2023-003',
      studentName: 'Amit Singh',
      studentClass: 'Class 11-A',
      rollNumber: '08',
      reason: 'Personal Emergency',
      description: 'Family emergency requiring immediate attention',
      fromDate: DateTime.now().subtract(const Duration(days: 8)),
      toDate: DateTime.now().subtract(const Duration(days: 7)),
      status: LeaveStatus.approved,
      appliedOn: DateTime.now().subtract(const Duration(days: 10)),
      actionBy: 'Dr. Rajesh Kumar',
      actionOn: DateTime.now().subtract(const Duration(days: 9)),
    ),
    LeaveRequest(
      id: 'LR-2023-004',
      studentName: 'Neha Gupta',
      studentClass: 'Class 10-A',
      rollNumber: '15',
      reason: 'Sports Competition',
      description: 'Selected for inter-school basketball tournament',
      fromDate: DateTime.now().add(const Duration(days: 5)),
      toDate: DateTime.now().add(const Duration(days: 7)),
      status: LeaveStatus.pending,
      appliedOn: DateTime.now().subtract(const Duration(days: 1)),
      attachments: ['Selection_Letter.pdf'],
    ),
    LeaveRequest(
      id: 'LR-2023-005',
      studentName: 'Ravi Patel',
      studentClass: 'Class 11-B',
      rollNumber: '22',
      reason: 'Religious Festival',
      description: 'Need to attend important religious ceremony',
      fromDate: DateTime.now().subtract(const Duration(days: 15)),
      toDate: DateTime.now().subtract(const Duration(days: 14)),
      status: LeaveStatus.rejected,
      appliedOn: DateTime.now().subtract(const Duration(days: 20)),
      actionBy: 'Dr. Rajesh Kumar',
      actionOn: DateTime.now().subtract(const Duration(days: 18)),
      comments: 'Request submitted too late and attendance is mandatory for pre-exam review.',
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveList(pendingLeaves, 'No pending leave requests'),
          _buildLeaveList(approvedLeaves, 'No approved leave requests'),
          _buildLeaveList(rejectedLeaves, 'No rejected leave requests'),
        ],
      ),
    );
  }

  Widget _buildLeaveList(List<LeaveRequest> leaves, String emptyMessage) {
    if (leaves.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        return _buildLeaveCard(leaves[index]);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequest leave) {
    final isPending = leave.status == LeaveStatus.pending;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          if (isPending) {
            _showLeaveDetailDialog(context, leave);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getStatusColor(leave.status).withOpacity(0.1),
                    child: Text(
                      leave.studentName.substring(0, 1),
                      style: TextStyle(
                        color: _getStatusColor(leave.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${leave.studentClass} • Roll No: ${leave.rollNumber}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(leave.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(leave.status),
                      style: TextStyle(
                        color: _getStatusColor(leave.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.label_outline,
                          size: 16,
                          color: Color(0xFF8E44AD),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          leave.reason,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8E44AD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      leave.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('d MMM').format(leave.fromDate)} - ${DateFormat('d MMM').format(leave.toDate)}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${_calculateDays(leave.fromDate, leave.toDate)} days)',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (leave.attachments.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${leave.attachments.length}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (!isPending) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Action by: ${leave.actionBy}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      DateFormat('d MMM, yyyy').format(leave.actionOn!),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (leave.comments != null && leave.comments!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Comment: ${leave.comments}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
              if (isPending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showRejectDialog(leave),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE74C3C),
                          side: const BorderSide(color: Color(0xFFE74C3C)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
      ),
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
              _buildDetailItem('Student', leave.studentName),
              _buildDetailItem('Class', leave.studentClass),
              _buildDetailItem('Roll Number', leave.rollNumber),
              _buildDetailItem('Reason', leave.reason),
              _buildDetailItem('Description', leave.description),
              _buildDetailItem('From Date', DateFormat('dd MMM, yyyy').format(leave.fromDate)),
              _buildDetailItem('To Date', DateFormat('dd MMM, yyyy').format(leave.toDate)),
              _buildDetailItem('Duration', '${_calculateDays(leave.fromDate, leave.toDate)} days'),
              _buildDetailItem('Applied On', DateFormat('dd MMM, yyyy').format(leave.appliedOn)),
              if (leave.attachments.isNotEmpty)
                _buildDetailItem('Attachments', leave.attachments.join(', ')),
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
              _showRejectDialog(leave);
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

  void _showRejectDialog(LeaveRequest leave) {
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Leave Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Enter comments',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectLeave(leave, commentController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _approveLeave(LeaveRequest leave) {
    setState(() {
      final index = _leaveRequests.indexWhere((l) => l.id == leave.id);
      if (index != -1) {
        _leaveRequests[index] = LeaveRequest(
          id: leave.id,
          studentName: leave.studentName,
          studentClass: leave.studentClass,
          rollNumber: leave.rollNumber,
          reason: leave.reason,
          description: leave.description,
          fromDate: leave.fromDate,
          toDate: leave.toDate,
          status: LeaveStatus.approved,
          appliedOn: leave.appliedOn,
          actionBy: 'Dr. Rajesh Kumar', // Current teacher
          actionOn: DateTime.now(),
          attachments: leave.attachments,
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave request approved successfully'),
        backgroundColor: Color(0xFF8E44AD),
      ),
    );
  }

  void _rejectLeave(LeaveRequest leave, String comments) {
    setState(() {
      final index = _leaveRequests.indexWhere((l) => l.id == leave.id);
      if (index != -1) {
        _leaveRequests[index] = LeaveRequest(
          id: leave.id,
          studentName: leave.studentName,
          studentClass: leave.studentClass,
          rollNumber: leave.rollNumber,
          reason: leave.reason,
          description: leave.description,
          fromDate: leave.fromDate,
          toDate: leave.toDate,
          status: LeaveStatus.rejected,
          appliedOn: leave.appliedOn,
          actionBy: 'Dr. Rajesh Kumar', // Current teacher
          actionOn: DateTime.now(),
          attachments: leave.attachments,
          comments: comments,
        );
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave request rejected'),
        backgroundColor: Color(0xFFE74C3C),
      ),
    );
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

enum LeaveStatus { pending, approved, rejected }

class LeaveRequest {
  final String id;
  final String studentName;
  final String studentClass;
  final String rollNumber;
  final String reason;
  final String description;
  final DateTime fromDate;
  final DateTime toDate;
  final LeaveStatus status;
  final DateTime appliedOn;
  final String? actionBy;
  final DateTime? actionOn;
  final List<String> attachments;
  final String? comments;

  LeaveRequest({
    required this.id,
    required this.studentName,
    required this.studentClass,
    required this.rollNumber,
    required this.reason,
    required this.description,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.appliedOn,
    this.actionBy,
    this.actionOn,
    this.attachments = const [],
    this.comments,
  });
} 
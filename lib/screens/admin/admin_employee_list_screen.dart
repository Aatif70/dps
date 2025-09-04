import 'package:flutter/material.dart';
import 'package:AES/services/admin_employee_list_service.dart';
import 'package:AES/constants/app_routes.dart';

class AdminEmployeeListScreen extends StatefulWidget {
  const AdminEmployeeListScreen({super.key});

  @override
  State<AdminEmployeeListScreen> createState() => _AdminEmployeeListScreenState();
}

class _AdminEmployeeListScreenState extends State<AdminEmployeeListScreen> {
  bool _isLoading = true;
  List<EmployeeItem> _employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });
    final items = await AdminEmployeeListService.fetchEmployees();
    if (!mounted) return;
    setState(() {
      _employees = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employees',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                strokeWidth: 3,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEmployees,
              color: const Color(0xFF6C5CE7),
              child: _employees.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        _EmptyState(message: 'No employees found'),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _employees.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final emp = _employees[index];
                        return InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.adminEmployeeDetails,
                            arguments: () {
                              print('[AdminEmployeeList] Tapped EmpId: ' + emp.empId.toString() + ', Name: ' + emp.name);
                              return emp.empId;
                            }(),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: _EmployeeCard(item: emp),
                        );
                      },
                    ),
            ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeItem item;
  const _EmployeeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withValues(alpha:0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: Color(0xFF6C5CE7)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CEC9).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.designationName,
                        style: const TextStyle(
                          color: Color(0xFF00CEC9),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      item.mobile.isNotEmpty ? item.mobile : (item.phoneNo ?? '-'),
                      style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.email,
                        style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.group_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}



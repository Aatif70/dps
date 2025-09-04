import 'package:flutter/material.dart';
import 'package:AES/constants/app_routes.dart';
import 'package:AES/services/admin_employee_metrics_service.dart';

class AdminEmployeesHubScreen extends StatefulWidget {
  const AdminEmployeesHubScreen({super.key});

  @override
  State<AdminEmployeesHubScreen> createState() => _AdminEmployeesHubScreenState();
}

class _AdminEmployeesHubScreenState extends State<AdminEmployeesHubScreen> {
  EmployeeMetrics? _metrics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final m = await AdminEmployeeMetricsService.fetchMetrics();
    if (!mounted) return;
    setState(() {
      _metrics = m;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<_HubItem> items = [


      _HubItem(
        title: 'Employee List',
        subtitle: 'Browse all employees and their contact info',
        icon: Icons.groups_rounded,
        color: const Color(0xFF4A90E2),
        route: AppRoutes.adminEmployees,
      ),
      _HubItem(
        title: 'Attendance',
        subtitle: 'Mark, update and review attendance',
        icon: Icons.fact_check_rounded,
        color: const Color(0xFF6C5CE7),
        route: AppRoutes.adminEmployeeAttendanceHub,
      ),
    ];

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
      body: RefreshIndicator(
        onRefresh: _load,
        color: const Color(0xFFE74C3C),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildMetricsCard(context);
            }
          final _HubItem item = items[index - 1];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, item.route),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha:0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        Text(item.subtitle, style: const TextStyle(color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: items.length + 1,
        ),
      ),
    );
  }
}

class _HubItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _HubItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}

Widget _buildMetricsPill(String label, String value, Color color, {Color? bg}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha:0.9),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha:0.3), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(width: 6),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
      ],
    ),
  );
}

extension on _AdminEmployeesHubScreenState {
  Widget _buildMetricsCard(BuildContext context) {
    if (_loading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade100, blurRadius: 16, offset: const Offset(0, 8)),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final int total = _metrics?.empCount ?? 0;
    final int present = _metrics?.presentCount ?? 0;
    final int absent = _metrics?.absentCount ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF6C5CE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4A90E2).withValues(alpha:0.25), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.group_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Staff Overview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 6),
                  Text('$total Employees', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricsPill('Present', present.toString(), const Color(0xFF10B981), bg: const Color(0xFF10B981).withValues(alpha:0.2)),
              _buildMetricsPill('Absent', absent.toString(), const Color(0xFFEF4444), bg: const Color(0xFFEF4444).withValues(alpha:0.2)),
            ],
          ),
        ],
      ),
    );
  }
}



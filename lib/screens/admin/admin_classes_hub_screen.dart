import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';

class AdminClassesHubScreen extends StatelessWidget {
  const AdminClassesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _HubItem(
        title: 'Class Masters',
        subtitle: 'List of classes and years',
        icon: Icons.class_,
        color: const Color(0xFF4A90E2),
        route: AppRoutes.adminClassMasters,
      ),
      _HubItem(
        title: 'Batches',
        subtitle: 'Academic year batches',
        icon: Icons.layers_rounded,
        color: const Color(0xFF58CC02),
        route: AppRoutes.adminBatches,
      ),
      _HubItem(
        title: 'Divisions',
        subtitle: 'Class divisions & incharges',
        icon: Icons.group_work_rounded,
        color: const Color(0xFFE17055),
        route: AppRoutes.adminDivisions,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Classes', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.pushNamed(context, item.route),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6)),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 14),
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
        itemCount: items.length,
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



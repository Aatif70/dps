import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';

class AdminFeesHubScreen extends StatelessWidget {
  const AdminFeesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_FeesItem> items = [
      _FeesItem(
        title: 'Fees Receipts',
        subtitle: 'View latest student fees receipts',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF6C5CE7),
        route: AppRoutes.adminFeesReceipts,
      ),
      _FeesItem(
        title: 'Concession Receipts',
        subtitle: 'View latest concession receipts',
        icon: Icons.discount_rounded,
        color: const Color(0xFFFD79A8),
        route: AppRoutes.adminConcessionReceipts,
      ),
      _FeesItem(
        title: 'Payment Vouchers',
        subtitle: 'View latest outgoing payments',
        icon: Icons.payment_rounded,
        color: const Color(0xFFE17055),
        route: AppRoutes.adminPaymentVouchers,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Fees')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final _FeesItem item = items[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(context, item.route),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
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

class _FeesItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _FeesItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}



import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';

class AdminFeesHubScreen extends StatelessWidget {
  const AdminFeesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_FeesItem> items = [
      _FeesItem(
        title: 'Search by Student',
        subtitle: 'Find a student and view fees',
        icon: Icons.person_search_rounded,
        color: const Color(0xFFFF7043),
        route: AppRoutes.adminFeesStudentSearch,
      ),
      _FeesItem(
        title: 'Fees Receipts',
        subtitle: 'View latest student fees receipts',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFEF6C00), // deep orange
        route: AppRoutes.adminFeesReceipts,
      ),
      _FeesItem(
        title: 'Concession Receipts',
        subtitle: 'View latest concession receipts',
        icon: Icons.discount_rounded,
        color: const Color(0xFFD81B60), // pink
        route: AppRoutes.adminConcessionReceipts,
      ),
      _FeesItem(
        title: 'Payment Vouchers',
        subtitle: 'View latest outgoing payments',
        icon: Icons.payment_rounded,
        color: const Color(0xFFE65100), // orange
        route: AppRoutes.adminPaymentVouchers,
      ),
      _FeesItem(
        title: 'Class-wise Summary',
        subtitle: 'Paid vs pending per class',
        icon: Icons.analytics_outlined,
        color: const Color(0xFFFF6E6E),
        route: AppRoutes.adminFeesClassSummary,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fees',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF8A65), // warm orange
                        Color(0xFFFF6E6E), // warm coral
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8A65).withValues(alpha:0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fees Management',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage receipts, concessions and vouchers',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha:0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _buildSectionTitle('Quick Actions', Icons.local_atm_rounded, const Color(0xFFEF6C00)),
                const SizedBox(height: 16),
                _buildItemsGrid(items),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsGrid(List<_FeesItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, item.route),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha:0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.color.withValues(alpha:0.12),
                          item.color.withValues(alpha:0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.icon, color: item.color, size: 28),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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



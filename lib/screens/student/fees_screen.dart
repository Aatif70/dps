import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  // Enhanced mock data with more realistic structure
  final List<FeeRecord> feeRecords = [
    FeeRecord(
      id: 'FEE-2023-001',
      type: 'Tuition Fee',
      amount: 15000,
      dueDate: DateTime(2023, 10, 15),
      status: PaymentStatus.paid,
      paidOn: DateTime(2023, 10, 10),
      receiptNo: 'RCP-2023-1024',
      category: FeeCategory.tuition,
    ),
    FeeRecord(
      id: 'FEE-2023-002',
      type: 'Library Fee',
      amount: 2000,
      dueDate: DateTime(2023, 10, 15),
      status: PaymentStatus.paid,
      paidOn: DateTime(2023, 10, 10),
      receiptNo: 'RCP-2023-1025',
      category: FeeCategory.library,
    ),
    FeeRecord(
      id: 'FEE-2023-003',
      type: 'Computer Lab Fee',
      amount: 3000,
      dueDate: DateTime(2023, 10, 15),
      status: PaymentStatus.paid,
      paidOn: DateTime(2023, 10, 10),
      receiptNo: 'RCP-2023-1026',
      category: FeeCategory.computer,
    ),
    FeeRecord(
      id: 'FEE-2023-004',
      type: 'Sports Fee',
      amount: 2500,
      dueDate: DateTime(2023, 10, 15),
      status: PaymentStatus.paid,
      paidOn: DateTime(2023, 10, 10),
      receiptNo: 'RCP-2023-1027',
      category: FeeCategory.sports,
    ),
    FeeRecord(
      id: 'FEE-2024-001',
      type: 'Tuition Fee',
      amount: 15000,
      dueDate: DateTime(2024, 1, 15),
      status: PaymentStatus.pending,
      category: FeeCategory.tuition,
    ),
    FeeRecord(
      id: 'FEE-2024-002',
      type: 'Library Fee',
      amount: 2000,
      dueDate: DateTime(2024, 1, 15),
      status: PaymentStatus.pending,
      category: FeeCategory.library,
    ),
    FeeRecord(
      id: 'FEE-2024-003',
      type: 'Computer Lab Fee',
      amount: 3000,
      dueDate: DateTime(2024, 1, 15),
      status: PaymentStatus.pending,
      category: FeeCategory.computer,
    ),
    FeeRecord(
      id: 'FEE-2024-004',
      type: 'Sports Fee',
      amount: 2500,
      dueDate: DateTime(2024, 1, 15),
      status: PaymentStatus.overdue,
      category: FeeCategory.sports,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pendingFees = feeRecords.where((fee) =>
    fee.status == PaymentStatus.pending ||
        fee.status == PaymentStatus.overdue).toList();
    final totalPending = pendingFees.fold<double>(0, (sum, fee) => sum + fee.amount);
    final paidFees = feeRecords.where((fee) => fee.status == PaymentStatus.paid).toList();
    final overdueFees = feeRecords.where((fee) => fee.status == PaymentStatus.overdue).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Fees Summary
            _buildEnhancedFeesSummary(context, totalPending, overdueFees.isNotEmpty),

            const SizedBox(height: 25),

            // Enhanced Fee Categories Overview
            _buildEnhancedFeeCategories(context),

            const SizedBox(height: 25),

            // Quick Payment Actions
            if (pendingFees.isNotEmpty)
              _buildQuickPaymentActions(context, pendingFees),

            const SizedBox(height: 25),

            // Enhanced Pending Fees
            if (pendingFees.isNotEmpty)
              _buildEnhancedPendingFees(context, pendingFees),

            const SizedBox(height: 25),

            // Enhanced Payment History
            _buildEnhancedPaymentHistory(context, paidFees),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Fee Management',
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
              color: const Color(0xFFFF9500).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFFFF9500),
              size: 20,
            ),
          ),
          onPressed: () {
            // Show all receipts
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedFeesSummary(BuildContext context, double totalPending, bool hasOverdue) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasOverdue
              ? [const Color(0xFFE74C3C), const Color(0xFFC0392B)]
              : [const Color(0xFFFF9500), const Color(0xFFE67E00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (hasOverdue ? const Color(0xFFE74C3C) : const Color(0xFFFF9500))
                .withOpacity(0.3),
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
                        Icon(
                          hasOverdue ? Icons.warning_rounded : Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasOverdue ? 'Overdue Fees' : 'Pending Fees',
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
                      currencyFormat.format(totalPending),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Due: ${DateFormat('d MMM yyyy').format(DateTime(2024, 1, 15))}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Payment Status Indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  hasOverdue ? Icons.schedule_rounded : Icons.payment_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Enhanced Pay Now Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: totalPending > 0 ? () => _showPaymentOptions(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: hasOverdue ? const Color(0xFFE74C3C) : const Color(0xFFFF9500),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.white.withOpacity(0.7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment_rounded,
                    size: 20,
                    color: hasOverdue ? const Color(0xFFE74C3C) : const Color(0xFFFF9500),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    totalPending > 0 ? 'Pay Now' : 'All Paid',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasOverdue ? const Color(0xFFE74C3C) : const Color(0xFFFF9500),
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

  Widget _buildEnhancedFeeCategories(BuildContext context) {
    final categories = [
      CategoryData(
        title: 'Tuition',
        amount: 15000,
        color: const Color(0xFF4A90E2),
        icon: Icons.school_rounded,
        category: FeeCategory.tuition,
      ),
      CategoryData(
        title: 'Library',
        amount: 2000,
        color: const Color(0xFF58CC02),
        icon: Icons.menu_book_rounded,
        category: FeeCategory.library,
      ),
      CategoryData(
        title: 'Computer',
        amount: 3000,
        color: const Color(0xFFE74C3C),
        icon: Icons.computer_rounded,
        category: FeeCategory.computer,
      ),
      CategoryData(
        title: 'Sports',
        amount: 2500,
        color: const Color(0xFF8E44AD),
        icon: Icons.sports_soccer_rounded,
        category: FeeCategory.sports,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.category_rounded,
                color: Color(0xFF4A90E2),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Fee Categories',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildEnhancedCategoryCard(categories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(CategoryData category) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            category.color.withOpacity(0.1),
            category.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: category.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 24,
            ),
          ),
          const Spacer(),
          Text(
            category.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(category.amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: category.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPaymentActions(BuildContext context, List<FeeRecord> pendingFees) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flash_on_rounded,
                color: Color(0xFFFF9500),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  'Pay All',
                  Icons.payment_rounded,
                  const Color(0xFF58CC02),
                      () => _payAllFees(context, pendingFees),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  context,
                  'Pay Partial',
                  Icons.payments_rounded,
                  const Color(0xFF4A90E2),
                      () => _showPartialPayment(context, pendingFees),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPendingFees(BuildContext context, List<FeeRecord> pendingFees) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pending_actions_rounded,
                      color: const Color(0xFFFF9500),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pending Fees',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${pendingFees.length} Items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingFees.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final fee = pendingFees[index];
              return _buildEnhancedFeeItem(context, fee, currencyFormat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFeeItem(BuildContext context, FeeRecord fee, NumberFormat currencyFormat) {
    final isOverdue = fee.status == PaymentStatus.overdue;
    final statusColor = isOverdue ? const Color(0xFFE74C3C) : const Color(0xFFFF9500);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(fee.category).withOpacity(0.1),
                  _getCategoryColor(fee.category).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(fee.category),
              color: _getCategoryColor(fee.category),
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
                    Text(
                      fee.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'OVERDUE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: ${DateFormat('d MMM, yyyy').format(fee.dueDate)}',
                  style: TextStyle(
                    color: isOverdue ? const Color(0xFFE74C3C) : const Color(0xFF718096),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(fee.amount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _payIndividualFee(context, fee),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pay',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPaymentHistory(BuildContext context, List<FeeRecord> paidFees) {
    if (paidFees.isEmpty) return const SizedBox();

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      color: Color(0xFF58CC02),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Payment History',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    // Show all payment history
                  },
                  icon: const Icon(
                    Icons.receipt_long_rounded,
                    size: 16,
                    color: Color(0xFF4A90E2),
                  ),
                  label: const Text(
                    'View All',
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paidFees.take(5).length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final fee = paidFees[index];
              return _buildEnhancedPaymentHistoryItem(context, fee, currencyFormat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPaymentHistoryItem(BuildContext context, FeeRecord fee, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0x1A58CC02),
                  Color(0x0D58CC02),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF58CC02),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paid on: ${DateFormat('d MMM, yyyy').format(fee.paidOn!)}',
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(fee.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _showReceipt(context, fee),
                child: Text(
                  fee.receiptNo!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A90E2),
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for enhanced functionality
  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildPaymentOptionsSheet(context),
    );
  }

  Widget _buildPaymentOptionsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          Text(
            'Choose Payment Method',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),

          const SizedBox(height: 24),

          _buildPaymentMethodButton(
            context,
            'UPI Payment',
            Icons.account_balance_wallet_rounded,
            const Color(0xFF4A90E2),
                () {
              Navigator.pop(context);
              // Implement UPI payment
            },
          ),

          const SizedBox(height: 12),

          _buildPaymentMethodButton(
            context,
            'Credit/Debit Card',
            Icons.credit_card_rounded,
            const Color(0xFF58CC02),
                () {
              Navigator.pop(context);
              // Implement card payment
            },
          ),

          const SizedBox(height: 12),

          _buildPaymentMethodButton(
            context,
            'Net Banking',
            Icons.account_balance_rounded,
            const Color(0xFFE74C3C),
                () {
              Navigator.pop(context);
              // Implement net banking
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _payAllFees(BuildContext context, List<FeeRecord> fees) {
    // Implement pay all functionality
  }

  void _showPartialPayment(BuildContext context, List<FeeRecord> fees) {
    // Show partial payment selection
  }

  void _payIndividualFee(BuildContext context, FeeRecord fee) {
    // Implement individual fee payment
  }

  void _showReceipt(BuildContext context, FeeRecord fee) {
    // Show receipt details
  }

  // Helper methods for categories
  Color _getCategoryColor(FeeCategory category) {
    switch (category) {
      case FeeCategory.tuition:
        return const Color(0xFF4A90E2);
      case FeeCategory.library:
        return const Color(0xFF58CC02);
      case FeeCategory.computer:
        return const Color(0xFFE74C3C);
      case FeeCategory.sports:
        return const Color(0xFF8E44AD);
    }
  }

  IconData _getCategoryIcon(FeeCategory category) {
    switch (category) {
      case FeeCategory.tuition:
        return Icons.school_rounded;
      case FeeCategory.library:
        return Icons.menu_book_rounded;
      case FeeCategory.computer:
        return Icons.computer_rounded;
      case FeeCategory.sports:
        return Icons.sports_soccer_rounded;
    }
  }
}

// Enhanced data models
enum PaymentStatus { pending, paid, overdue }
enum FeeCategory { tuition, library, computer, sports }

class FeeRecord {
  final String id;
  final String type;
  final double amount;
  final DateTime dueDate;
  final PaymentStatus status;
  final DateTime? paidOn;
  final String? receiptNo;
  final FeeCategory category;

  const FeeRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.category,
    this.paidOn,
    this.receiptNo,
  });
}

class CategoryData {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final FeeCategory category;

  const CategoryData({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.category,
  });
}

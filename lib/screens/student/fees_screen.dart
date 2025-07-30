import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/services/fee_service.dart';
import 'package:dps/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  List<PaidFeeRecord> paidFees = [];
  bool isLoading = true;
  Map<String, double> categoryTotals = {};
  Map<String, int> categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _loadPaidFees();
  }

  Future<void> _loadPaidFees() async {
    print('=== FEES SCREEN DEBUG START ===');
    setState(() {
      isLoading = true;
    });

    try {
      print('Fees Screen - Calling FeeService.getPaidFees()');
      final fees = await FeeService.getPaidFees();
      print('Fees Screen - Received ${fees.length} fee records');

      // Calculate category totals
      final totals = <String, double>{};
      final counts = <String, int>{};

      print('Fees Screen - Processing categories:');
      for (int i = 0; i < fees.length; i++) {
        final fee = fees[i];
        print('Processing fee $i: ${fee.toString()}');

        final category = FeeCategory.getCategoryFromParticular(fee.particular);
        totals[category] = (totals[category] ?? 0) + fee.amount;
        counts[category] = (counts[category] ?? 0) + 1;

        print('Updated totals: $totals');
        print('Updated counts: $counts');
      }

      print('Final category totals: $totals');
      print('Final category counts: $counts');

      setState(() {
        paidFees = fees;
        categoryTotals = totals;
        categoryCounts = counts;
        isLoading = false;
      });

      print('Fees Screen - State updated successfully');
      print('=== FEES SCREEN DEBUG END ===');
    } catch (e, stackTrace) {
      print('Fees Screen - Error occurred: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        isLoading = false;
      });
      if (mounted) {
        CustomSnackbar.showError(
          context,
          message: 'Failed to load fee data. Please try again.',
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final totalPaid = paidFees.fold(0.0, (sum, fee) => sum + fee.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: RefreshIndicator(
        onRefresh: _loadPaidFees,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Summary
              _buildPaymentSummary(context, totalPaid),
              const SizedBox(height: 25),

              // Fee Categories Overview
              if (categoryTotals.isNotEmpty)
                _buildFeeCategories(context),

              if (categoryTotals.isNotEmpty)
                const SizedBox(height: 25),

              // Pending Fees Notice
              _buildPendingFeesNotice(context),
              const SizedBox(height: 25),

              // Payment History
              _buildPaymentHistory(context),
              const SizedBox(height: 30),
            ],
          ),
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
              color: const Color(0xFF58CC02).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF58CC02),
              size: 20,
            ),
          ),
          onPressed: _loadPaidFees,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildPaymentSummary(BuildContext context, double totalPaid) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withOpacity(0.3),
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
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total Paid',
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
                      currencyFormat.format(totalPaid),
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
                        '${paidFees.length} Payments',
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
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCategories(BuildContext context) {
    final categories = categoryTotals.entries.map((entry) {
      return CategoryData(
        title: entry.key,
        amount: entry.value,
        count: categoryCounts[entry.key] ?? 0,
        color: FeeCategory.getCategoryColor(entry.key),
        icon: FeeCategory.getCategoryIcon(entry.key),
      );
    }).toList();

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
                'Payment Categories',
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
              return _buildCategoryCard(categories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(CategoryData category) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${category.count}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: category.color,
                  ),
                ),
              ),
            ],
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

  Widget _buildPendingFeesNotice(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFE69C),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF856404),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Fees Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Currently showing payment history only. Contact office for pending fee information.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF856404).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(BuildContext context) {
    if (paidFees.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(40),
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
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No Payment History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your payment history will appear here once fees are paid.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${paidFees.length} Records',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF58CC02),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paidFees.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final fee = paidFees[index];
              return _buildPaymentHistoryItem(context, fee, currencyFormat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem(BuildContext context, PaidFeeRecord fee, NumberFormat currencyFormat) {
    final category = FeeCategory.getCategoryFromParticular(fee.particular);
    final categoryColor = FeeCategory.getCategoryColor(category);
    final categoryIcon = FeeCategory.getCategoryIcon(category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColor.withOpacity(0.1),
                  categoryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              categoryIcon,
              color: categoryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.particular.trim(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  fee.className,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Paid: ${DateFormat('d MMM, yyyy').format(fee.paymentDate)}',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPaymentModeColor(fee.paymentMode).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fee.paymentMode,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getPaymentModeColor(fee.paymentMode),
                        ),
                      ),
                    ),
                  ],
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
                onTap: () => _showReceiptDetails(context, fee),
                child: Text(
                  fee.receiptNo,
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

  Color _getPaymentModeColor(String paymentMode) {
    switch (paymentMode.toLowerCase()) {
      case 'cash':
        return const Color(0xFF58CC02);
      case 'online':
        return const Color(0xFF4A90E2);
      case 'card':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF6C757D);
    }
  }

  void _showReceiptDetails(BuildContext context, PaidFeeRecord fee) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildReceiptDetailsSheet(context, fee),
    );
  }

  Widget _buildReceiptDetailsSheet(BuildContext context, PaidFeeRecord fee) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 2,
    );

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
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF4A90E2),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Receipt Details',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReceiptDetailRow('Receipt No:', fee.receiptNo),
          _buildReceiptDetailRow('Fee Type:', fee.particular.trim()),
          _buildReceiptDetailRow('Class:', fee.className),
          _buildReceiptDetailRow('Payment Mode:', fee.paymentMode),
          _buildReceiptDetailRow('Amount:', currencyFormat.format(fee.amount)),
          _buildReceiptDetailRow('Payment Date:', DateFormat('d MMMM, yyyy - h:mm a').format(fee.paymentDate)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF718096),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for category data
class CategoryData {
  final String title;
  final double amount;
  final int count;
  final Color color;
  final IconData icon;

  const CategoryData({
    required this.title,
    required this.amount,
    required this.count,
    required this.color,
    required this.icon,
  });
}

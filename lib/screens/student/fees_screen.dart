import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  // Mock data for fees
  final List<FeeRecord> feeRecords = [
    FeeRecord(
      id: 'FEE-2023-001',
      type: 'Tuition Fee',
      amount: 15000,
      dueDate: DateTime(2023, 10, 15),
      status: PaymentStatus.paid,
      paidOn: DateTime(2023, 10, 10),
      receiptNo: 'RCP-2023-1024',
    ),
    FeeRecord(
      id: 'FEE-2023-002',
      type: 'Library Fee',
      amount: 2000,
      dueDate: DateTime(2023, 10, 15),
      status: PaymentStatus.paid,
      paidOn: DateTime(2023, 10, 10),
      receiptNo: 'RCP-2023-1024',
    ),
    FeeRecord(
      id: 'FEE-2023-003',
      type: 'Computer Lab Fee',
      amount: 3000,
      dueDate: DateTime(2023, 10, 15),
      status: PaymentStatus.paid,
      paidOn: DateTime(2023, 10, 10),
      receiptNo: 'RCP-2023-1024',
    ),
    FeeRecord(
      id: 'FEE-2023-004',
      type: 'Sports Fee',
      amount: 2500,
      dueDate: DateTime(2023, 10, 15),
      status: PaymentStatus.paid,
      paidOn: DateTime(2023, 10, 10),
      receiptNo: 'RCP-2023-1024',
    ),
    FeeRecord(
      id: 'FEE-2024-001',
      type: 'Tuition Fee',
      amount: 15000,
      dueDate: DateTime(2024, 1, 15),
      status: PaymentStatus.pending,
    ),
    FeeRecord(
      id: 'FEE-2024-002',
      type: 'Library Fee',
      amount: 2000,
      dueDate: DateTime(2024, 1, 15),
      status: PaymentStatus.pending,
    ),
    FeeRecord(
      id: 'FEE-2024-003',
      type: 'Computer Lab Fee',
      amount: 3000,
      dueDate: DateTime(2024, 1, 15),
      status: PaymentStatus.pending,
    ),
    FeeRecord(
      id: 'FEE-2024-004',
      type: 'Sports Fee',
      amount: 2500,
      dueDate: DateTime(2024, 1, 15),
      status: PaymentStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pendingFees = feeRecords.where((fee) => fee.status == PaymentStatus.pending).toList();
    final totalPending = pendingFees.fold<double>(0, (sum, fee) => sum + fee.amount);
    final paidFees = feeRecords.where((fee) => fee.status == PaymentStatus.paid).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.fees),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeesSummary(totalPending),
            _buildFeeCategories(),
            _buildPendingFees(pendingFees),
            _buildPaymentHistory(paidFees),
          ],
        ),
      ),
    );
  }

  Widget _buildFeesSummary(double totalPending) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9500), Color(0xFFFF7A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9500).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pending Fees',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Due: ${DateFormat('d MMM').format(DateTime(2024, 1, 15))}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            currencyFormat.format(totalPending),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFFF9500),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Pay Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCategories() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeeCategory('Tuition', '₹15,000', const Color(0xFF4A90E2)),
              _buildFeeCategory('Library', '₹2,000', const Color(0xFF58CC02)),
              _buildFeeCategory('Computer', '₹3,000', const Color(0xFFE74C3C)),
              _buildFeeCategory('Sports', '₹2,500', const Color(0xFF8E44AD)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCategory(String title, String amount, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              _getCategoryIcon(title),
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tuition':
        return Icons.school;
      case 'library':
        return Icons.menu_book;
      case 'computer':
        return Icons.computer;
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.payments;
    }
  }

  Widget _buildPendingFees(List<FeeRecord> pendingFees) {
    if (pendingFees.isEmpty) {
      return const SizedBox();
    }

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Fees',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9500).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingFees.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final fee = pendingFees[index];
              return ListTile(
                title: Text(
                  fee.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Due: ${DateFormat('d MMM, yyyy').format(fee.dueDate)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  currencyFormat.format(fee.amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFFFF9500),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(List<FeeRecord> paidFees) {
    if (paidFees.isEmpty) {
      return const SizedBox();
    }

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paidFees.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final fee = paidFees[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF58CC02).withOpacity(0.1),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF58CC02),
                    size: 18,
                  ),
                ),
                title: Text(
                  fee.type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  'Paid on: ${DateFormat('d MMM, yyyy').format(fee.paidOn!)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(fee.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Receipt: ${fee.receiptNo}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum PaymentStatus { pending, paid, overdue }

class FeeRecord {
  final String id;
  final String type;
  final double amount;
  final DateTime dueDate;
  final PaymentStatus status;
  final DateTime? paidOn;
  final String? receiptNo;

  const FeeRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidOn,
    this.receiptNo,
  });
} 
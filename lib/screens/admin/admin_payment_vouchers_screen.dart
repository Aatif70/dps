import 'package:flutter/material.dart';
import 'package:dps/services/admin_dashboard_service.dart';

class AdminPaymentVouchersScreen extends StatefulWidget {
  const AdminPaymentVouchersScreen({super.key});

  @override
  State<AdminPaymentVouchersScreen> createState() => _AdminPaymentVouchersScreenState();
}

class _AdminPaymentVouchersScreenState extends State<AdminPaymentVouchersScreen> {
  bool _loading = true;
  List<PaymentVoucherData> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final List<PaymentVoucherData> list = await AdminDashboardService.getLast10PaymentVouchers();
    if (!mounted) return;
    setState(() {
      _vouchers = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Vouchers')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _vouchers.isEmpty
                ? const Center(child: Text('No payment vouchers found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final PaymentVoucherData item = _vouchers[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE17055).withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.payment, color: Color(0xFFE17055), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.paidTo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${item.mHead} • ${item.formattedDate}',
                                      style: const TextStyle(color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Text(item.formattedAmount,
                                style: const TextStyle(
                                  color: Color(0xFFE17055),
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: _vouchers.length,
                  ),
      ),
    );
  }
}



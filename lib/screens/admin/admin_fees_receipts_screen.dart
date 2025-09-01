import 'package:flutter/material.dart';
import 'package:dps/services/admin_dashboard_service.dart';

class AdminFeesReceiptsScreen extends StatefulWidget {
  const AdminFeesReceiptsScreen({super.key});

  @override
  State<AdminFeesReceiptsScreen> createState() => _AdminFeesReceiptsScreenState();
}

class _AdminFeesReceiptsScreenState extends State<AdminFeesReceiptsScreen> {
  bool _loading = true;
  List<FeesReceiptData> _receipts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    final List<FeesReceiptData> list = await AdminDashboardService.getLast10FeesReceipt();
    if (!mounted) return;
    setState(() {
      _receipts = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fees Receipts')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _receipts.isEmpty
                ? const Center(child: Text('No receipts found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final FeesReceiptData item = _receipts[index];
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
                                color: const Color(0xFF6C5CE7).withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.receipt, color: Color(0xFF6C5CE7), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.studentName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${item.receiptNo} • ${item.formattedDate}',
                                      style: const TextStyle(color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            Text(item.formattedAmount,
                                style: const TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: _receipts.length,
                  ),
      ),
    );
  }
}



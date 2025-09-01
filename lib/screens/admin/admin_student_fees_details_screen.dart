import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dps/services/admin_student_service.dart';

class AdminStudentFeesDetailsScreen extends StatefulWidget {
  const AdminStudentFeesDetailsScreen({super.key});

  @override
  State<AdminStudentFeesDetailsScreen> createState() => _AdminStudentFeesDetailsScreenState();
}

class _AdminStudentFeesDetailsScreenState extends State<AdminStudentFeesDetailsScreen> {
  bool _loading = true;
  AdminFeesDetails? _data;
  int? _studentId;

  final _df = DateFormat('dd MMM, yyyy');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (_studentId == null && args != null) {
      final raw = args['id'] ?? args['studentId'];
      if (raw != null) {
        _studentId = raw is int ? raw as int : int.tryParse(raw.toString());
      }
      if (_studentId != null) {
        _load();
      }
    }
  }

  Widget _buildMeta(AdminFeesDetails d) {
    final items = <Widget>[];
    void addMeta(String label, String? value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        items.add(_metaItem(label, value));
      }
    }
    void addMetaNum(String label, num? value) {
      if (value != null) {
        items.add(_metaItem(label, value.toString()));
      }
    }

    addMeta('Category', d.category);
    addMeta('Caste', d.caste);
    addMetaNum('Admission Year', d.admissionYear);
    addMeta('Admission Category', d.admissionCategory);
    addMetaNum('Refund Amount', d.refundAmount);

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Student Meta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items,
        ),
      ]),
    );
  }

  Widget _metaItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
        Text(value, style: const TextStyle(color: Color(0xFF64748B))),
      ]),
    );
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await AdminStudentService.fetchStudentFeesDetails(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _data = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Fees Details', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('No data'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(_data!),
                      const SizedBox(height: 16),
                      _buildMeta(_data!),
                      const SizedBox(height: 16),
                      ..._buildClassWise(_data!),
                      const SizedBox(height: 16),
                      _buildReceipts(_data!),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader(AdminFeesDetails d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4A90E2).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person_rounded, color: Color(0xFF4A90E2)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(d.className, style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(d.acadYear, style: const TextStyle(color: Color(0xFF64748B))),
          ]),
        )
      ]),
    );
  }

  List<Widget> _buildClassWise(AdminFeesDetails d) {
    if (d.classWiseDetails.isEmpty) return [];
    return [
      const Text('Fee Heads', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
      const SizedBox(height: 8),
      ...d.classWiseDetails.map((cw) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              maintainState: true,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF4A90E2).withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.category_rounded, color: Color(0xFF4A90E2)),
              ),
              title: Text(cw.className, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cw.payDetails.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = cw.payDetails[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.receipt_long_rounded, color: Color(0xFF6C5CE7)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(p.particular, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('Fixed: ${p.fixedFee.toStringAsFixed(2)}  ·  Balance: ${p.balanceFee.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                            // Text('Fixed: ${p.bankName}  ·  Balance: ${p.amount}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),

                          ]),
                        ),
                        // Text(p.feeType, style: const TextStyle(color: Color(0xFF64748B))),
                      ]),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      })
    ];
  }

  Widget _buildReceipts(AdminFeesDetails d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        if (d.studentPayments.isEmpty)
          const Text('No payments found', style: TextStyle(color: Color(0xFF64748B)))
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: d.studentPayments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final r = d.studentPayments[i];
              DateTime? when;
              try { when = DateTime.parse(r.createdDate); } catch (_) {}
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.payments_rounded, color: Color(0xFF2ECC71)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.particular, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),

                      // RCPT BOLD
                      Text('${r.paymentMode} · ${when != null ? _df.format(when) : r.createdDate}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),

                      // CLASS BOLD
                      Text(r.className, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.normal )),

                      // RCPT BOLD
                      Text( 'Receipt: ${r.receiptNo}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),

                    ]),
                  ),
                  Text(    r.amount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                ]),
              );
            },
          ),
      ]),
    );
  }
}



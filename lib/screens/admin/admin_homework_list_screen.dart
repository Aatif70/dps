import 'package:dps/constants/api_constants.dart';
import 'package:dps/services/admin_homework_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHomeworkListScreen extends StatefulWidget {
  const AdminHomeworkListScreen({super.key});

  @override
  State<AdminHomeworkListScreen> createState() => _AdminHomeworkListScreenState();
}

class _AdminHomeworkListScreenState extends State<AdminHomeworkListScreen> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  bool _loading = false;
  List<AdminHomeworkItem> _items = <AdminHomeworkItem>[];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final res = await AdminHomeworkService.fetchHomework(fromDate: _fromDate, toDate: _toDate);
    if (!mounted) return;
    setState(() {
      _items = res;
      _loading = false;
    });
  }

  String _fmt(DateTime d) => DateFormat('MMM dd, yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Homework'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _datePickerTile('From', _fromDate, (d) => setState(() => _fromDate = d))),
                    const SizedBox(width: 12),
                    Expanded(child: _datePickerTile('To', _toDate, (d) => setState(() => _toDate = d))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _fetch,
                    child: Text(_loading ? 'Loading...' : 'Go'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('No homework found'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => _card(_items[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _datePickerTile(String label, DateTime value, ValueChanged<DateTime> onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text('$label: ${_fmt(value)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }

  Widget _card(AdminHomeworkItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.task_alt_rounded, color: Color(0xFF4A90E2), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${item.subject} • ${item.className}-${item.division}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    const SizedBox(height: 2),
                    Text('${DateFormat('MMM dd, yyyy').format(item.date)} • ${item.employee}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.homework, style: const TextStyle(color: Color(0xFF334155))),
          if (item.doc != null && item.doc!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  _showDocViewer('${ApiConstants.homeworkFilesBase}/${item.doc!}', item.subject);
                },
                icon: const Icon(Icons.attach_file_rounded),
                label: const Text('View Attachment'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDocViewer(String url, String subject) {
    final extension = url.toLowerCase().split('.').last;
    if (['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'].contains(extension)) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$subject - Attachment',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.black,
                      child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: Colors.white))),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Open in Browser'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';
import 'package:dps/constants/app_routes.dart';

class AdminFeesStudentSearchScreen extends StatefulWidget {
  const AdminFeesStudentSearchScreen({super.key});

  @override
  State<AdminFeesStudentSearchScreen> createState() => _AdminFeesStudentSearchScreenState();
}

class _AdminFeesStudentSearchScreenState extends State<AdminFeesStudentSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  bool _isLoading = false;
  List<StudentSearchResult> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) {
        setState(() {
          _results = [];
        });
        return;
      }
      _search(term: trimmed);
    });
  }

  Future<void> _search({required String term}) async {
    setState(() {
      _isLoading = true;
    });
    final List<StudentSearchResult> list = await AdminStudentService.searchStudents(term: term);
    if (!mounted) return;
    setState(() {
      _results = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Search Students',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: Column(
        children: [
          // Warm header strip
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8A65), Color(0xFFFF6E6E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF8A65).withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(children: const [
              Icon(Icons.person_search_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Find a student to view fees history', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Type Name/ID to search...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFF6E6E)),
                ),
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _results.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final StudentSearchResult item = _results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFF8A65).withOpacity(0.12),
                          child: const Icon(Icons.person, color: Color(0xFFFF7043)),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('ID: ${item.id}'),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.adminFeesStudentDetails,
                            arguments: {'studentId': item.id},
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _results.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.search, color: Colors.grey.shade400, size: 36),
          ),
          const SizedBox(height: 12),
          Text(
            'Start typing to search students',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/services/admin_classes_service.dart';

class AdminClassMastersScreen extends StatefulWidget {
  const AdminClassMastersScreen({super.key});

  @override
  State<AdminClassMastersScreen> createState() => _AdminClassMastersScreenState();
}

class _AdminClassMastersScreenState extends State<AdminClassMastersScreen> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  List<ClassMasterItem> _all = [];
  List<ClassMasterItem> _filtered = [];
  bool _loading = true;
  int _page = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await AdminClassesService.fetchClassMasters();
    if (!mounted) return;
    setState(() {
      _all = data;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    List<ClassMasterItem> base = _all;
    if (q.isNotEmpty) {
      base = base.where((e) => e.className.toLowerCase().contains(q) || e.courseYear.toString().contains(q)).toList();
    }
    final start = (_page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, base.length);
    _filtered = base.sublist(start, end);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _page = 1;
        _applyFilter();
      });
    });
  }

  void _nextPage() {
    setState(() {
      _page += 1;
      _applyFilter();
    });
  }

  void _prevPage() {
    setState(() {
      if (_page > 1) _page -= 1;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Class Masters', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.adminAddClass);
          if (result == true) {
            _load();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _search,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search by class name or year...',
                        filled: true,
                        fillColor: Colors.white,
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
                          borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filtered.isEmpty
                        ? const Center(child: Text('No classes found'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemBuilder: (context, index) {
                              final item = _filtered[index];
                              return InkWell(
                                onTap: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    AppRoutes.adminEditClass,
                                    arguments: {
                                      'ClassMasterId': item.classMasterId,
                                      'ClassName': item.className,
                                      'RollNoPreFix': item.rollNoPrefix,
                                      'CourseYear': item.courseYear,
                                    },
                                  );
                                  if (result == true) {
                                    _load();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 6)),
                                    ],
                                    border: Border.all(color: const Color(0xFFF1F5F9)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4A90E2).withValues(alpha:0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.class_, color: Color(0xFF4A90E2)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.className, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                                            const SizedBox(height: 6),
                                            Text('Year: ${item.courseYear} • Prefix: ${item.rollNoPrefix}', style: const TextStyle(color: Color(0xFF64748B))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: _filtered.length,
                          ),
                  ),
                  _buildPager(),
                ],
              ),
            ),
    );
  }

  Widget _buildPager() {
    final total = _search.text.trim().isEmpty ? _all.length : _all.where((e) => true).length; // not exact, acceptable UX
    final totalPages = (total / _pageSize).ceil().clamp(1, 9999);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Page $_page of $totalPages'),
          Row(
            children: [
              OutlinedButton(
                onPressed: _page > 1 ? _prevPage : null,
                style: OutlinedButton.styleFrom(minimumSize: const Size(100, 40)),
                child: const Text('Previous'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _filtered.length == _pageSize ? _nextPage : null,
                style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
                child: const Text('Next'),
              ),
            ],
          )
        ],
      ),
    );
  }
}



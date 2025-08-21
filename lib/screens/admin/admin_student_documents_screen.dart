import 'package:flutter/material.dart';
import 'package:dps/services/admin_student_service.dart';
import 'package:dps/constants/api_constants.dart';

class AdminStudentDocumentsScreen extends StatefulWidget {
  const AdminStudentDocumentsScreen({super.key});

  @override
  State<AdminStudentDocumentsScreen> createState() => _AdminStudentDocumentsScreenState();
}

class _AdminStudentDocumentsScreenState extends State<AdminStudentDocumentsScreen> {
  List<DocumentCategory> _cats = [];
  bool _loading = true;
  int? _studentId;

  String _fullUrl(String pathOrUrl) {
    if (pathOrUrl.isEmpty) return pathOrUrl;
    final base = ApiConstants.baseUrl;
    String raw = pathOrUrl.trim();
    // If we received a full URL
    if (raw.startsWith('http')) {
      final uri = Uri.tryParse(raw);
      if (uri != null) {
        final lowerPath = uri.path.toLowerCase();
        // Map /Documents/<file> to /Images/Student/<file>
        if (lowerPath.contains('/documents/')) {
          final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
          final mapped = '$base/Images/Student/$fileName';
          debugPrint('[StudentDocs] map(absolute) Documents->Images: raw="$raw" file="$fileName" -> "$mapped"');
          return mapped;
        }
        // Already absolute and not under /Documents → return as-is
        debugPrint('[StudentDocs] absolute url passthrough: $raw');
        return raw;
      }
      debugPrint('[StudentDocs] absolute url parse failed, passthrough: $raw');
      return raw;
    }
    // Relative path handling
    String sanitized = raw;
    if (sanitized.startsWith('/')) sanitized = sanitized.substring(1);
    final isPrefixed = sanitized.toLowerCase().startsWith('images/student');
    final result = isPrefixed ? '$base/$sanitized' : '$base/Images/Student/$sanitized';
    debugPrint('[StudentDocs] _fullUrl raw="$pathOrUrl" sanitized="$sanitized" base="$base" -> "$result"');
    return result;
  }

  void _openViewer(String initialPathOrUrl) {
    // Flatten all available document image URLs and find the initial index
    final List<_DocImage> images = [];
    for (final cat in _cats) {
      for (final d in cat.documents) {
        if (d.documentUrl != null && (d.documentUrl as String).trim().isNotEmpty) {
          final raw = (d.documentUrl as String).trim();
          final url = _fullUrl(raw);
          debugPrint('[StudentDocs] collect image: category="${cat.category}" type="${d.docType}" raw="$raw" full="$url"');
          images.add(_DocImage(url: url, title: d.docType));
        }
      }
    }
    if (images.isEmpty) return;
    final initialUrl = _fullUrl(initialPathOrUrl.trim());
    int initialIndex = images.indexWhere((e) => e.url == initialUrl);
    if (initialIndex < 0) initialIndex = 0;
    debugPrint('[StudentDocs] opening viewer: initialUrl="$initialUrl" index=$initialIndex total=${images.length}');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageViewerSheet(images: images, initialIndex: initialIndex),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (_studentId == null && args != null && args['studentId'] != null) {
      _studentId = args['studentId'] is int ? args['studentId'] as int : int.tryParse(args['studentId'].toString());
      if (_studentId != null) {
        _fetch();
      }
    }
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final List<DocumentCategory> list = await AdminStudentService.fetchStudentDocuments(studentId: _studentId!);
    if (!mounted) return;
    setState(() {
      _cats = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Documents', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetch,
              child: _cats.isEmpty
                  ? const Center(child: Text('No documents'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final DocumentCategory c = _cats[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 6)),
                            ],
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.category, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B))),
                              const SizedBox(height: 8),
                              ...c.documents.map((d) => Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF4A90E2)),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(d.docType, style: const TextStyle(fontWeight: FontWeight.w600))),
                                        if (d.documentUrl != null)
                                          TextButton(
                                            onPressed: () {
                                              final raw = (d.documentUrl as String).trim();
                                              debugPrint('[StudentDocs] View pressed: type="${d.docType}" raw="$raw"');
                                              _openViewer(raw);
                                            },
                                            child: const Text('View'),
                                          )
                                        else
                                          const Text('Missing', style: TextStyle(color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _cats.length,
                    ),
            ),
    );
  }
}

class _DocImage {
  final String url;
  final String title;
  const _DocImage({required this.url, required this.title});
}

class _ImageViewerSheet extends StatefulWidget {
  final List<_DocImage> images;
  final int initialIndex;
  const _ImageViewerSheet({required this.images, required this.initialIndex});

  @override
  State<_ImageViewerSheet> createState() => _ImageViewerSheetState();
}

class _ImageViewerSheetState extends State<_ImageViewerSheet> {
  late final PageController _pc;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pc = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height * 0.9;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.images[_index].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                ),
                Text('${_index + 1}/${widget.images.length}', style: const TextStyle(color: Color(0xFF64748B))),
                const SizedBox(width: 8),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // const Divider(height: 1),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: widget.images.length,
              itemBuilder: (context, i) {
                final img = widget.images[i];
                debugPrint('[StudentDocs] Page $i loading url: ${img.url}');
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 1,
                      maxScale: 4,
                      child: Image.network(
                        img.url,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          debugPrint('[StudentDocs] loading url=${img.url} bytes=${progress.cumulativeBytesLoaded}/${progress.expectedTotalBytes ?? 0}');
                          return const Center(child: CircularProgressIndicator(color: Colors.white));
                        },
                        errorBuilder: (context, error, stack) {
                          debugPrint('[StudentDocs] ERROR loading ${img.url}: $error');
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Failed to load image', style: TextStyle(color: Colors.white)),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



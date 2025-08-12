import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../../services/teacher_study_material_service.dart';


class TeacherStudyMaterialScreen extends StatefulWidget {
  const TeacherStudyMaterialScreen({super.key});

  @override
  State<TeacherStudyMaterialScreen> createState() => _TeacherStudyMaterialScreenState();
}

class _TeacherStudyMaterialScreenState extends State<TeacherStudyMaterialScreen> {
  String _selectedSubject = 'All';
  String _selectedClass = 'All';

  List<StudyMaterial> _allStudyMaterials = [];
  List<StudyMaterial> _filteredStudyMaterials = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<String> _subjects = ['All'];
  List<String> _classes = ['All'];

  @override
  void initState() {
    super.initState();
    _loadStudyMaterials();
  }

  Future<void> _loadStudyMaterials() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final materials = await TeacherStudyMaterialService.getStudyMaterials();

      setState(() {
        _allStudyMaterials = materials;
        _filteredStudyMaterials = materials;
        _isLoading = false;

        _subjects = ['All', ...materials.map((m) => m.subject).toSet().toList()];
        _classes = ['All', ...materials.map((m) => m.className).toSet().toList()];
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load study materials: $e';
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredStudyMaterials = _allStudyMaterials.where((material) {
        final subjectMatch = _selectedSubject == 'All' || material.subject == _selectedSubject;
        final classMatch = _selectedClass == 'All' || material.className == _selectedClass;
        return subjectMatch && classMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.studyMaterial),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudyMaterials,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorWidget()
          : RefreshIndicator(
        onRefresh: _loadStudyMaterials,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildFilters(),
              _buildUploadStats(),
              _buildMaterialsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showUploadDialog(context);
        },
        backgroundColor: const Color(0xFFE74C3C),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadStudyMaterials,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Subject',
                  _selectedSubject,
                  _subjects,
                      (value) {
                    setState(() {
                      _selectedSubject = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown(
                  'Class',
                  _selectedClass,
                  _classes,
                      (value) {
                    setState(() {
                      _selectedClass = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
      String label,
      String value,
      List<String> items,
      Function(String?) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(8),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadStats() {
    final totalMaterials = _allStudyMaterials.length;
    final activeMaterials = _allStudyMaterials.where((m) => m.isActive).length;
    final totalClasses = _allStudyMaterials.map((m) => m.className).toSet().length;

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Materials',
            totalMaterials.toString(),
            const Color(0xFFE74C3C),
            Icons.menu_book_rounded,
          ),
          _buildStatItem(
            'Active',
            activeMaterials.toString(),
            const Color(0xFF58CC02),
            Icons.check_circle_rounded,
          ),
          _buildStatItem(
            'Classes',
            totalClasses.toString(),
            const Color(0xFF4A90E2),
            Icons.class_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialsList() {
    if (_filteredStudyMaterials.isEmpty && !_isLoading) {
      return Container(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No study materials found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try changing the filters or upload new material',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _filteredStudyMaterials.map((material) => _buildMaterialCard(material)).toList(),
      ),
    );
  }

  Widget _buildMaterialCard(StudyMaterial material) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => _showFilePreview(material),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getTypeColor(material.materialType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getTypeIcon(material.materialType),
                        color: _getTypeColor(material.materialType),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.chapter,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (material.description != null && material.description!.isNotEmpty)
                          Text(
                            material.description!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getSubjectColor(material.subject).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                material.subject,
                                style: TextStyle(
                                  color: _getSubjectColor(material.subject),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                material.className,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            material.empName,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: material.uploadType == 'YTLink'
                          ? Colors.red[100]
                          : Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      material.uploadType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: material.uploadType == 'YTLink'
                            ? Colors.red[700]
                            : Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit functionality to be implemented')),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showFilePreview(material),
                      icon: Icon(material.uploadType == 'YTLink' ? Icons.play_arrow : Icons.visibility),
                      label: Text(material.uploadType == 'YTLink' ? 'Open' : 'Preview'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New method to show file preview in popup
  void _showFilePreview(StudyMaterial material) {
    if (material.uploadType == 'YTLink') {
      // For YouTube links, still open externally for better experience
      _handleExternalLink(material.fileName);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilePreviewModal(material: material),
    );
  }

  Future<void> _handleExternalLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open the link');
      }
    } catch (e) {
      _showErrorSnackBar('Invalid URL format');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper methods (keep existing ones)
  Color _getTypeColor(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.pdf:
        return const Color(0xFFE74C3C);
      case StudyMaterialType.video:
        return const Color(0xFF4A90E2);
      case StudyMaterialType.audio:
        return const Color(0xFF58CC02);
      case StudyMaterialType.presentation:
        return const Color(0xFFFF9500);
      case StudyMaterialType.image:
        return const Color(0xFF8E44AD);
      case StudyMaterialType.document:
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF6C757D);
    }
  }

  IconData _getTypeIcon(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.pdf:
        return Icons.picture_as_pdf;
      case StudyMaterialType.video:
        return Icons.videocam;
      case StudyMaterialType.audio:
        return Icons.audiotrack;
      case StudyMaterialType.presentation:
        return Icons.slideshow;
      case StudyMaterialType.image:
        return Icons.image;
      case StudyMaterialType.document:
        return Icons.description;
      default:
        return Icons.file_present;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'maths':
        return const Color(0xFF4A90E2);
      case 'science':
        return const Color(0xFF58CC02);
      case 'english':
        return const Color(0xFF8E44AD);
      case 'physics':
        return const Color(0xFFFF9500);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  void _showUploadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildUploadForm(),
    );
  }

  Widget _buildUploadForm() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upload Study Material',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'This is just a placeholder form. In a real app, this would be a complete form to upload study materials.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upload functionality to be implemented'),
                          backgroundColor: Color(0xFFE74C3C),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Upload Material',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// New FilePreviewModal widget
class FilePreviewModal extends StatefulWidget {
  final StudyMaterial material;

  const FilePreviewModal({Key? key, required this.material}) : super(key: key);

  @override
  State<FilePreviewModal> createState() => _FilePreviewModalState();
}

class _FilePreviewModalState extends State<FilePreviewModal> {
  bool _isLoading = true;
  String? _error;
  String? _textContent;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    if (widget.material.materialType == StudyMaterialType.document &&
        widget.material.fileExtension == 'txt') {
      try {
        final response = await http.get(Uri.parse(widget.material.fileUrl));
        if (response.statusCode == 200) {
          setState(() {
            _textContent = response.body;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Failed to load file content';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = 'Error loading file: $e';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.material.chapter,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.material.subject} - ${widget.material.className}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: _buildPreviewContent(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent(ScrollController scrollController) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadContent(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    switch (widget.material.materialType) {
      case StudyMaterialType.image:
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: InteractiveViewer(
              child: Image.network(
                widget.material.fileUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load image',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

      case StudyMaterialType.document:
        if (widget.material.fileExtension == 'txt' && _textContent != null) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _textContent!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          );
        }
        break;

      default:
        break;
    }

    // Default fallback for unsupported file types
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _getTypeColor(widget.material.materialType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getTypeIcon(widget.material.materialType),
                size: 60,
                color: _getTypeColor(widget.material.materialType),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.material.fileName.split('/').last,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (widget.material.description != null && widget.material.description!.isNotEmpty)
              Text(
                widget.material.description!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            Text(
              'This file type cannot be previewed in the app.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                if (widget.material.fileUrl.isNotEmpty) {
                  try {
                    final url = Uri.parse(widget.material.fileUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  } catch (e) {
                    // Handle error
                  }
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Externally'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.pdf:
        return const Color(0xFFE74C3C);
      case StudyMaterialType.video:
        return const Color(0xFF4A90E2);
      case StudyMaterialType.audio:
        return const Color(0xFF58CC02);
      case StudyMaterialType.presentation:
        return const Color(0xFFFF9500);
      case StudyMaterialType.image:
        return const Color(0xFF8E44AD);
      case StudyMaterialType.document:
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF6C757D);
    }
  }

  IconData _getTypeIcon(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.pdf:
        return Icons.picture_as_pdf;
      case StudyMaterialType.video:
        return Icons.videocam;
      case StudyMaterialType.audio:
        return Icons.audiotrack;
      case StudyMaterialType.presentation:
        return Icons.slideshow;
      case StudyMaterialType.image:
        return Icons.image;
      case StudyMaterialType.document:
        return Icons.description;
      default:
        return Icons.file_present;
    }
  }
}

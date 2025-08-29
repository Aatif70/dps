import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../services/teacher_study_material_service.dart';
import 'package:dps/widgets/custom_snackbar.dart';

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

  // Upload form variables
  List<BatchData> _batches = [];
  List<SubjectData> _subjectsForUpload = [];
  BatchData? _selectedBatch;
  SubjectData? _selectedUploadSubject;
  bool _isLoadingBatches = false;
  bool _isLoadingSubjects = false;
  bool _isUploading = false;

  // Controllers
  final _chapterController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeLinkController = TextEditingController();
  String _uploadType = 'File';
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadStudyMaterials();
  }

  @override
  void dispose() {
    _chapterController.dispose();
    _descriptionController.dispose();
    _youtubeLinkController.dispose();
    super.dispose();
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildEnhancedAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: _errorMessage != null
          ? _buildErrorWidget()
          : RefreshIndicator(
        onRefresh: _loadStudyMaterials,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildEnhancedStudyHeader(context),
              const SizedBox(height: 20),
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

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Study Materials',
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
              color: const Color(0xFFE74C3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFFE74C3C),
              size: 20,
            ),
          ),
          onPressed: _loadStudyMaterials,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedStudyHeader(BuildContext context) {
    final totalMaterials = _allStudyMaterials.length;
    final totalClasses = _allStudyMaterials.map((m) => m.className).toSet().length;
    final uniqueSubjects = _allStudyMaterials.map((m) => m.subject).toSet().length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE74C3C).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Study Journey',
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
                  '$totalMaterials Resources',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$uniqueSubjects subjects • $totalClasses classes',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
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
              Icons.school_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
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
      return SizedBox(
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
              // const Divider(),
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

                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showFilePreview(material),
                      icon: Icon(material.uploadType == 'YTLink' ? Icons.play_arrow : Icons.visibility),
                      label: Text(material.uploadType == 'YTLink' ? 'Open' : 'Preview'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.black87,
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

  void _showFilePreview(StudyMaterial material) {
    if (material.uploadType == 'YTLink') {
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
        _showErrorMessage('Could not open the link');
      }
    } catch (e) {
      _showErrorMessage('Invalid URL format');
    }
  }

  void _showUploadDialog(BuildContext context) {
    print('=== SHOWING UPLOAD DIALOG ===');
    // Reset form data
    _selectedBatch = null;
    _selectedUploadSubject = null;
    _batches.clear();
    _subjectsForUpload.clear();
    _chapterController.clear();
    _descriptionController.clear();
    _youtubeLinkController.clear();
    _selectedFile = null;
    _uploadType = 'File';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _buildUploadForm(setModalState),
      ),
    );
  }

  Widget _buildUploadForm(StateSetter setModalState) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
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
                // Header
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

                // Chapter field
                TextFormField(
                  controller: _chapterController,
                  decoration: const InputDecoration(
                    labelText: 'Chapter *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book),
                  ),
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Class dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.class_, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Class *',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            if (_isLoadingBatches)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),
                      if (_batches.isEmpty && !_isLoadingBatches)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: ElevatedButton.icon(
                            onPressed: () => _loadBatches(setModalState),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load Classes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        )
                      else if (_batches.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: DropdownButtonFormField<BatchData>(
                            value: _selectedBatch,
                            decoration: const InputDecoration(
                              hintText: 'Select Class',
                              border: OutlineInputBorder(),
                            ),
                            items: _batches.map((batch) {
                              return DropdownMenuItem<BatchData>(
                                value: batch,
                                child: Text(batch.batchName),
                              );
                            }).toList(),
                            onChanged: (BatchData? newValue) {
                              print('=== CLASS SELECTION CHANGED ===');
                              print('Selected Class: ${newValue?.batchName}');
                              print('ClassMasterId: ${newValue?.classMasterId}');

                              setModalState(() {
                                _selectedBatch = newValue;
                               _selectedUploadSubject = null;
                                _subjectsForUpload.clear();
                              });
                              if (newValue != null) {
                                _loadSubjects(newValue.classMasterId, setModalState);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subject dropdown
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.subject, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Subject *',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const Spacer(),
                            if (_isLoadingSubjects)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),
                      if (_selectedBatch == null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'Please select a class first',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else if (_subjectsForUpload.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: DropdownButtonFormField<SubjectData>(
                            value: _selectedUploadSubject,
                            decoration: const InputDecoration(
                              hintText: 'Select Subject',
                              border: OutlineInputBorder(),
                            ),
                            items: _subjectsForUpload.map((subject) {
                              return DropdownMenuItem<SubjectData>(
                                value: subject,
                                child: Text(subject.subjectName),
                              );
                            }).toList(),
                            onChanged: (SubjectData? newValue) {
                              print('=== SUBJECT SELECTION CHANGED ===');
                              print('Selected Subject: ${newValue?.subjectName}');
                              print('SubjectId: ${newValue?.subjectId}');

                              setModalState(() {
                                _selectedUploadSubject = newValue;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Upload Type Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Type *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('File'),
                              value: 'File',
                              groupValue: _uploadType,
                              onChanged: (value) {
                                print('=== UPLOAD TYPE CHANGED ===');
                                print('Selected Type: $value');
                                setModalState(() {
                                  _uploadType = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('YouTube Link'),
                              value: 'YTLink',
                              groupValue: _uploadType,
                              onChanged: (value) {
                                print('=== UPLOAD TYPE CHANGED ===');
                                print('Selected Type: $value');
                                setModalState(() {
                                  _uploadType = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Conditional content based on upload type
                if (_uploadType == 'YTLink') ...[
                  // YouTube Link field
                  TextFormField(
                    controller: _youtubeLinkController,
                    decoration: const InputDecoration(
                      labelText: 'YouTube Link',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                      hintText: 'https://www.youtube.com/watch?v=...',
                    ),
                  ),
                ] else ...[
                  // File upload section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _selectedFile != null ? Icons.check_circle : Icons.cloud_upload,
                          size: 48,
                          color: _selectedFile != null ? Colors.green : const Color(0xFFE74C3C),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedFile != null
                              ? 'File Selected: ${_selectedFile!.path.split('/').last}'
                              : 'Drag and drop files here',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_selectedFile == null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'or',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _pickFile(setModalState),
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Browse Files'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFFE74C3C),
                              side: const BorderSide(color: Color(0xFFE74C3C)),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _pickFile(setModalState),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Change File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),

                // Upload button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : () => _uploadMaterial(setModalState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isUploading
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Uploading...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                        : const Text(
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

  Future<void> _loadBatches(StateSetter setModalState) async {
    print('=== LOADING BATCHES ===');
    setModalState(() {
      _isLoadingBatches = true;
    });

    try {
      final batches = await TeacherStudyMaterialService.getBatches();
      print('=== BATCHES LOADED ===');
      print('Number of batches: ${batches.length}');

      setModalState(() {
        _batches = batches;
        _isLoadingBatches = false;
      });
    } catch (e) {
      print('=== LOAD BATCHES ERROR ===');
      print('Error: $e');
      setModalState(() {
        _isLoadingBatches = false;
      });
    }
  }

  Future<void> _loadSubjects(int classMasterId, StateSetter setModalState) async {
    print('=== LOADING SUBJECTS ===');
    print('ClassMasterId: $classMasterId');

    setModalState(() {
      _isLoadingSubjects = true;
    });

    try {
      final subjects = await TeacherStudyMaterialService.getSubjects(classMasterId);
      print('=== SUBJECTS LOADED ===');
      print('Number of subjects: ${subjects.length}');

      setModalState(() {
        _subjectsForUpload = subjects;
        _isLoadingSubjects = false;
      });
    } catch (e) {
      print('=== LOAD SUBJECTS ERROR ===');
      print('Error: $e');
      setModalState(() {
        _isLoadingSubjects = false;
      });
    }
  }

  Future<void> _pickFile(StateSetter setModalState) async {
    print('=== PICKING FILE ===');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        print('=== FILE PICKED ===');
        print('File path: ${result.files.single.path}');
        print('File name: ${result.files.single.name}');
        print('File size: ${result.files.single.size}');

        setModalState(() {
          _selectedFile = File(result.files.single.path!);
        });
      } else {
        print('=== FILE PICKER CANCELLED ===');
      }
    } catch (e) {
      print('=== FILE PICKER ERROR ===');
      print('Error: $e');
    }
  }

  Future<void> _uploadMaterial(StateSetter setModalState) async {
    print('=== STARTING UPLOAD MATERIAL ===');

    // Validation
    if (_chapterController.text.isEmpty) {
      _showErrorMessage('Chapter is required');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      _showErrorMessage('Description is required');
      return;
    }
    if (_selectedBatch == null) {
      _showErrorMessage('Please select a class');
      return;
    }
    if (_selectedUploadSubject == null) {
      _showErrorMessage('Please select a subject');
      return;
    }
    if (_uploadType == 'YTLink' && _youtubeLinkController.text.isEmpty) {
      _showErrorMessage('YouTube link is required');
      return;
    }
    if (_uploadType == 'File' && _selectedFile == null) {
      _showErrorMessage('Please select a file');
      return;
    }

    print('=== VALIDATION PASSED ===');

    setModalState(() {
      _isUploading = true;
    });

    try {
      final success = await TeacherStudyMaterialService.addStudyMaterial(
        classMasterId: _selectedBatch!.classMasterId,
        subjectId: _selectedUploadSubject!.subjectId,
        chapter: _chapterController.text.trim(),
        description: _descriptionController.text.trim(),
        uploadType: _uploadType,
        youtubeLink: _uploadType == 'YTLink' ? _youtubeLinkController.text.trim() : null,
        file: _uploadType == 'File' ? _selectedFile : null,
      );

      setModalState(() {
        _isUploading = false;
      });

      if (success) {
        print('=== UPLOAD SUCCESSFUL ===');
        Navigator.pop(context);
        CustomSnackbar.showSuccess(context, message: 'Study material uploaded successfully!');
        // Reload the materials list
        _loadStudyMaterials();
      } else {
        print('=== UPLOAD FAILED ===');
        _showErrorMessage('Failed to upload study material. Please try again.');
      }
    } catch (e) {
      print('=== UPLOAD ERROR ===');
      print('Error: $e');
      setModalState(() {
        _isUploading = false;
      });
      _showErrorMessage('An error occurred while uploading. Please try again.');
    }
  }

  void _showErrorMessage(String message) {
    CustomSnackbar.showError(context, message: message);
  }

  Color _getTypeColor(StudyMaterialType type) {
    switch (type) {
      case StudyMaterialType.pdf:
        return const Color(0xFFE74C3C);
      case StudyMaterialType.video:
        return const Color(0xFF4A90E2);
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
}

// FilePreviewModal widget
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
                  return SizedBox(
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
                  return SizedBox(
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

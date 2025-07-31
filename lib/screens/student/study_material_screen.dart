import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/services/study_material_service.dart' as study_service;
import 'package:dps/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';


class StudyMaterialScreen extends StatefulWidget {
  const StudyMaterialScreen({super.key});

  @override
  State<StudyMaterialScreen> createState() => _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends State<StudyMaterialScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _selectedSubject = 'All';
  String _selectedMaterialType = 'All';
  bool _showExtraNotes = false;

  // Real data from API
  List<study_service.ApiStudyMaterialRecord> _apiMaterials = [];
  List<study_service.StudyMaterial> _studyMaterials = [];
  bool _isLoading = true;

  // Subject list for filtering (will be populated from API data)
  List<String> _subjects = ['All'];

  // Material type filters
  final List<String> _materialTypes = [
    'All',
    'PDF',
    'Video',
    'Audio',
  ];

  int _studyStreak = 9;
  int _totalDownloads = 28;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _loadStudyMaterials();
  }

  Future<void> _loadStudyMaterials() async {
    print('=== STUDY MATERIAL SCREEN DEBUG START ===');
    setState(() {
      _isLoading = true;
    });

    try {
      print('Study Material Screen - Calling StudyMaterialService.getStudyMaterials()');
      final apiMaterials = await study_service.StudyMaterialService.getStudyMaterials();
      print('Study Material Screen - Received ${apiMaterials.length} study material records');

      // Convert to legacy format for compatibility with existing UI
      final studyMaterials = apiMaterials.map((material) => material.toLegacyStudyMaterial()).toList();
      print('Study Material Screen - Converted to ${studyMaterials.length} legacy study materials');

      // Extract unique subjects from API data
      final subjects = {'All'};
      for (var material in apiMaterials) {
        if (material.subject.isNotEmpty) {
          subjects.add(material.subject);
        }
      }

      setState(() {
        _apiMaterials = apiMaterials;
        _studyMaterials = studyMaterials;
        _subjects = subjects.toList();
        _isLoading = false;
      });

      // Start fade animation after data is loaded
      Future.delayed(const Duration(milliseconds: 200), () {
        _fadeController.forward();
      });

      print('Study Material Screen - State updated successfully');
      print('=== STUDY MATERIAL SCREEN DEBUG END ===');
    } catch (e, stackTrace) {
      print('Study Material Screen - Error occurred: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        CustomSnackbar.showError(
          context,
          message: 'Failed to load study materials. Please try again.',
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildEnhancedAppBar(context),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filteredMaterials = _getFilteredMaterials();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: RefreshIndicator(
        onRefresh: _loadStudyMaterials,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Enhanced Study Progress Header
                _buildEnhancedStudyHeader(context),
                const SizedBox(height: 20),
                // Enhanced Search Bar
                _buildEnhancedSearchBar(context),
                const SizedBox(height: 20),
                // Filter Tabs
                _buildEnhancedFilterTabs(context),
                const SizedBox(height: 20),
                // Materials List
                _buildEnhancedMaterialsList(context, filteredMaterials),
              ],
            ),
          ),
        ),
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
                      'Your Study Journey 📚',
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
                  '${_getTotalMaterials()} Resources',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'From ${_getUniqueSubjectsCount()} subjects',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                // Study Streak Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFF9500),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_studyStreak Day Study Streak! 🔥',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Study Progress Indicator
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

  Widget _buildEnhancedSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search materials, chapters, subjects...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF718096),
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  color: Color(0xFF718096),
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              hintStyle: const TextStyle(
                color: Color(0xFF718096),
                fontSize: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFilterTabs(BuildContext context) {
    return Column(
      children: [
        // Subject Filter
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              final subject = _subjects[index];
              final isSelected = subject == _selectedSubject;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSubject = subject;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                      colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                    )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFFE74C3C).withOpacity(0.3)
                            : Colors.grey.shade100,
                        blurRadius: isSelected ? 12 : 8,
                        offset: Offset(0, isSelected ? 6 : 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      subject,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF2D3748),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Material Type Filter
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _materialTypes.length,
            itemBuilder: (context, index) {
              final type = _materialTypes[index];
              final isSelected = type == _selectedMaterialType;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMaterialType = type;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4A90E2).withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4A90E2)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        size: 16,
                        color: isSelected
                            ? const Color(0xFF4A90E2)
                            : const Color(0xFF718096),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF4A90E2)
                              : const Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedMaterialsList(BuildContext context, List<study_service.StudyMaterial> materials) {
    if (materials.isEmpty) {
      return _buildEmptyState(context);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: materials.map((material) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildEnhancedMaterialCard(material),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedMaterialCard(study_service.StudyMaterial material) {
    final subjectColor = _getSubjectColor(material.subject);

    // Find the corresponding API record for additional details
    final apiRecord = _apiMaterials.firstWhere(
          (api) => api.studyMaterialId.toString() == material.id.replaceAll('SM-', ''),
      orElse: () => study_service.ApiStudyMaterialRecord(
        studyMaterialId: 0,
        classMasterId: 0,
        subjectId: 0,
        className: '',
        subject: material.subject,
        empName: material.teacherName,
        uploadType: 'File',
        fileName: '',
        chapter: material.title,
        description: material.description,
        isActive: true,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: subjectColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  subjectColor.withOpacity(0.1),
                  subjectColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                _buildEnhancedMaterialTypeIcon(material.type, subjectColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              material.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          if (apiRecord.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF58CC02),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: subjectColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              material.subject,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: subjectColor,
                              ),
                            ),
                          ),
                          if (apiRecord.className.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A90E2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Class ${apiRecord.className}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A90E2),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Teacher Info and Stats
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: subjectColor.withOpacity(0.1),
                      child: Text(
                        material.teacherAvatar,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: subjectColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material.teacherName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            apiRecord.uploadType,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatChip(
                      Icons.insert_drive_file_rounded,
                      apiRecord.uploadType,
                      const Color(0xFF718096),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewMaterial(material, apiRecord),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: subjectColor),
                          foregroundColor: subjectColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text(
                          'View',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadMaterial(material, apiRecord),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: subjectColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text(
                          'Download',
                          style: TextStyle(fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildEnhancedMaterialTypeIcon(study_service.MaterialType type, Color color) {
    IconData icon; // Declare the variable

    // Initialize the icon based on type
    switch (type) {
      case study_service.MaterialType.pdf:
        icon = Icons.picture_as_pdf_rounded;
        break;
      case study_service.MaterialType.video:
        icon = Icons.play_circle_fill_rounded;
        break;
      case study_service.MaterialType.audio:
        icon = Icons.headphones_rounded;
        break;
      default:
        icon = Icons.insert_drive_file_rounded; // Default fallback
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }


  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Color(0xFFE74C3C),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No materials found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Try different search terms or browse all subjects',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  List<study_service.StudyMaterial> _getFilteredMaterials() {
    var filtered = _studyMaterials.where((material) {
      // Subject filter
      if (_selectedSubject != 'All' && material.subject != _selectedSubject) {
        return false;
      }

      // Material type filter
      if (_selectedMaterialType != 'All') {
        final typeMatch = _selectedMaterialType.toLowerCase();
        final materialType = material.type.toString().split('.').last;
        if (materialType != typeMatch.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();

    return filtered;
  }

  int _getTotalMaterials() {
    return _studyMaterials.length;
  }

  int _getUniqueSubjectsCount() {
    return _subjects.length - 1; // Subtract 1 for 'All'
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'maths':
        return const Color(0xFF4A90E2);
      case 'science':
        return const Color(0xFF58CC02);
      case 'english':
        return const Color(0xFFE74C3C);
      case 'history':
        return const Color(0xFF8E44AD);
      case 'geography':
        return const Color(0xFFFF9500);
      case 'computer science':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF718096);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'video':
        return Icons.play_circle_outline_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      default:
        return Icons.filter_list_rounded;
    }
  }

  // Action Methods
  void _viewMaterial(study_service.StudyMaterial material, study_service.ApiStudyMaterialRecord apiRecord) {
    HapticFeedback.lightImpact();
    print('Viewing material: ${apiRecord.chapter} (ID: ${apiRecord.studyMaterialId})');
    print('File path: ${apiRecord.fileName}');

    CustomSnackbar.showInfo(
      context,
      message: 'Opening ${apiRecord.chapter}...',
    );
  }

  void _downloadMaterial(study_service.StudyMaterial material, study_service.ApiStudyMaterialRecord apiRecord) {
    HapticFeedback.lightImpact();
    print('Downloading material: ${apiRecord.chapter} (ID: ${apiRecord.studyMaterialId})');
    print('File path: ${apiRecord.fileName}');

    CustomSnackbar.showSuccess(
      context,
      message: 'Downloading ${apiRecord.chapter}...',
    );
  }
}

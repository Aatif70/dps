import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
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

  // Enhanced mock data for study materials
  final List<StudyMaterial> _studyMaterials = [
    StudyMaterial(
      id: 'SM-2024-001',
      title: 'Linear Equations and Inequalities',
      description: 'Comprehensive guide to solving linear equations with step-by-step examples and practice problems',
      subject: 'Mathematics',
      type: MaterialType.pdf,
      teacherName: 'Mr. Rajesh Kumar',
      teacherAvatar: 'RK',
      uploadedOn: DateTime.now().subtract(const Duration(days: 2)),
      fileSize: '3.2 MB',
      downloadCount: 127,
      isNew: true,
      tags: ['algebra', 'equations', 'grade-10'],
      difficulty: DifficultyLevel.intermediate,
    ),
    StudyMaterial(
      id: 'SM-2024-002',
      title: 'Photosynthesis Process Explained',
      description: 'Detailed explanation of photosynthesis with diagrams, chemical equations, and real-world applications',
      subject: 'Science',
      type: MaterialType.video,
      teacherName: 'Mrs. Priya Singh',
      teacherAvatar: 'PS',
      uploadedOn: DateTime.now().subtract(const Duration(days: 1)),
      fileSize: '45.8 MB',
      duration: '12:34',
      downloadCount: 89,
      isNew: true,
      tags: ['biology', 'plants', 'photosynthesis'],
      difficulty: DifficultyLevel.beginner,
    ),
    StudyMaterial(
      id: 'SM-2024-003',
      title: 'Essay Writing Masterclass',
      description: 'Learn the art of essay writing with structure, techniques, and examples from award-winning essays',
      subject: 'English',
      type: MaterialType.pdf,
      teacherName: 'Mrs. Anjali Sharma',
      teacherAvatar: 'AS',
      uploadedOn: DateTime.now().subtract(const Duration(days: 4)),
      fileSize: '2.1 MB',
      downloadCount: 156,
      tags: ['writing', 'essays', 'composition'],
      difficulty: DifficultyLevel.advanced,
    ),
    StudyMaterial(
      id: 'SM-2024-004',
      title: 'World War II Documentary',
      description: 'Educational documentary covering key events, battles, and outcomes of World War II',
      subject: 'History',
      type: MaterialType.video,
      teacherName: 'Mr. Suresh Patel',
      teacherAvatar: 'SP',
      uploadedOn: DateTime.now().subtract(const Duration(days: 6)),
      fileSize: '128.5 MB',
      duration: '28:15',
      downloadCount: 67,
      tags: ['world-war', 'history', 'documentary'],
      difficulty: DifficultyLevel.intermediate,
    ),
    StudyMaterial(
      id: 'SM-2024-005',
      title: 'Python Programming Basics',
      description: 'Introduction to Python programming with syntax, examples, and hands-on coding exercises',
      subject: 'Computer Science',
      type: MaterialType.pdf,
      teacherName: 'Ms. Riya Agarwal',
      teacherAvatar: 'RA',
      uploadedOn: DateTime.now().subtract(const Duration(days: 3)),
      fileSize: '4.7 MB',
      downloadCount: 203,
      isPopular: true,
      tags: ['programming', 'python', 'coding'],
      difficulty: DifficultyLevel.beginner,
    ),
    StudyMaterial(
      id: 'SM-2024-006',
      title: 'Geometry Theorems Audio Guide',
      description: 'Audio explanation of important geometry theorems with proof techniques and applications',
      subject: 'Mathematics',
      type: MaterialType.audio,
      teacherName: 'Mr. Rajesh Kumar',
      teacherAvatar: 'RK',
      uploadedOn: DateTime.now().subtract(const Duration(days: 8)),
      fileSize: '18.3 MB',
      duration: '22:47',
      downloadCount: 84,
      tags: ['geometry', 'theorems', 'proofs'],
      difficulty: DifficultyLevel.advanced,
    ),
  ];

  // Extra notes and books
  final List<StudyMaterial> _extraResources = [
    StudyMaterial(
      id: 'ER-2024-001',
      title: 'NCERT Solutions Class 10 - Complete',
      description: 'Complete NCERT solutions for all subjects with detailed explanations and answers',
      subject: 'All Subjects',
      type: MaterialType.pdf,
      teacherName: 'School Library',
      teacherAvatar: 'SL',
      uploadedOn: DateTime.now().subtract(const Duration(days: 15)),
      fileSize: '25.6 MB',
      downloadCount: 345,
      isPopular: true,
      tags: ['ncert', 'solutions', 'textbook'],
      difficulty: DifficultyLevel.intermediate,
    ),
    StudyMaterial(
      id: 'ER-2024-002',
      title: 'Reference Book: Advanced Mathematics',
      description: 'Additional reference material for advanced mathematics topics and competitive exam preparation',
      subject: 'Mathematics',
      type: MaterialType.pdf,
      teacherName: 'School Library',
      teacherAvatar: 'SL',
      uploadedOn: DateTime.now().subtract(const Duration(days: 20)),
      fileSize: '12.4 MB',
      downloadCount: 178,
      tags: ['reference', 'advanced', 'competitive'],
      difficulty: DifficultyLevel.advanced,
    ),
  ];

  // Subject list for filtering
  final List<String> _subjects = [
    'All',
    'Mathematics',
    'Science',
    'English',
    'History',
    'Computer Science',
    'Geography',
  ];

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

    // Start fade animation
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMaterials = _getFilteredMaterials();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
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

              // Materials List - No longer in Expanded widget
              _buildEnhancedMaterialsList(context, filteredMaterials),
            ],
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
              Icons.filter_list_rounded,
              color: Color(0xFFE74C3C),
              size: 20,
            ),
          ),
          onPressed: () {
            _showAdvancedFilters(context);
          },
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
                  '$_totalDownloads downloads this month',
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
              hintText: 'Search materials, notes, books...',
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

          // Search Type Toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF718096),
                  size: 18,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Search in:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                _buildSearchToggle('Materials', !_showExtraNotes),
                const SizedBox(width: 12),
                _buildSearchToggle('Extra Notes', _showExtraNotes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchToggle(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showExtraNotes = label == 'Extra Notes';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE74C3C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE74C3C) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF718096),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFilterTabs(BuildContext context) {
    return Column(
      children: [
        // Subject Filter - Make sure it scrolls horizontally
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

        // Material Type Filter - Make sure it scrolls horizontally
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

  Widget _buildEnhancedMaterialsList(BuildContext context, List<StudyMaterial> materials) {
    if (materials.isEmpty) {
      return _buildEmptyState(context);
    }

    // Use Column instead of ListView since we're already in a SingleChildScrollView
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: materials.map((material) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 100),
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildEnhancedMaterialCard(material),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEnhancedMaterialCard(StudyMaterial material) {
    final subjectColor = _getSubjectColor(material.subject);

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
                          if (material.isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF58CC02),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (material.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9500),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'POPULAR',
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(material.difficulty).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getDifficultyText(material.difficulty),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(material.difficulty),
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

                // Tags
                if (material.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: material.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

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
                            _getTimeAgo(material.uploadedOn),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatChip(
                      Icons.download_rounded,
                      material.downloadCount.toString(),
                      const Color(0xFF58CC02),
                    ),
                    const SizedBox(width: 8),
                    if (material.duration != null)
                      _buildStatChip(
                        Icons.play_circle_outline_rounded,
                        material.duration!,
                        const Color(0xFF4A90E2),
                      )
                    else
                      _buildStatChip(
                        Icons.insert_drive_file_rounded,
                        material.fileSize,
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
                        onPressed: () => _viewMaterial(material),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: subjectColor),
                          foregroundColor: subjectColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(Icons.visibility_rounded, size: 16),
                        label: const Text(
                          'View',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadMaterial(material),
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

  Widget _buildEnhancedMaterialTypeIcon(MaterialType type, Color color) {
    IconData icon;
    switch (type) {
      case MaterialType.pdf:
        icon = Icons.picture_as_pdf_rounded;
        break;
      case MaterialType.video:
        icon = Icons.play_circle_fill_rounded;
        break;
      case MaterialType.audio:
        icon = Icons.headphones_rounded;
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
            Text(
              _showExtraNotes
                  ? 'Try searching in regular materials or adjust your filters'
                  : 'Try different search terms or browse all subjects',
              style: const TextStyle(
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
  List<StudyMaterial> _getFilteredMaterials() {
    final materials = _showExtraNotes ? _extraResources : _studyMaterials;

    var filtered = materials.where((material) {
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

      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return material.title.toLowerCase().contains(searchTerm) ||
            material.description.toLowerCase().contains(searchTerm) ||
            material.tags.any((tag) => tag.toLowerCase().contains(searchTerm));
      }

      return true;
    }).toList();

    // Sort by newest first
    filtered.sort((a, b) => b.uploadedOn.compareTo(a.uploadedOn));

    return filtered;
  }

  int _getTotalMaterials() {
    return _showExtraNotes ? _extraResources.length : _studyMaterials.length;
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
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

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return const Color(0xFF58CC02);
      case DifficultyLevel.intermediate:
        return const Color(0xFFFF9500);
      case DifficultyLevel.advanced:
        return const Color(0xFFE74C3C);
    }
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return 'BEGINNER';
      case DifficultyLevel.intermediate:
        return 'INTERMEDIATE';
      case DifficultyLevel.advanced:
        return 'ADVANCED';
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

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 8) {
      return DateFormat('d MMM').format(dateTime);
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else {
      return 'just now';
    }
  }

  // Action Methods
  void _viewMaterial(StudyMaterial material) {
    // Implement view functionality
    HapticFeedback.lightImpact();
  }

  void _downloadMaterial(StudyMaterial material) {
    // Implement download functionality
    HapticFeedback.lightImpact();
  }

  void _showAdvancedFilters(BuildContext context) {
    // Show advanced filter options
  }
}

// Enhanced Data Models
enum MaterialType { pdf, video, audio }
enum DifficultyLevel { beginner, intermediate, advanced }

class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final String subject;
  final MaterialType type;
  final String teacherName;
  final String teacherAvatar;
  final DateTime uploadedOn;
  final String fileSize;
  final String? duration;
  final int downloadCount;
  final bool isNew;
  final bool isPopular;
  final List<String> tags;
  final DifficultyLevel difficulty;

  const StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.teacherName,
    required this.teacherAvatar,
    required this.uploadedOn,
    required this.fileSize,
    this.duration,
    required this.downloadCount,
    this.isNew = false,
    this.isPopular = false,
    this.tags = const [],
    this.difficulty = DifficultyLevel.intermediate,
  });
}

import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class StudyMaterialScreen extends StatefulWidget {
  const StudyMaterialScreen({super.key});

  @override
  State<StudyMaterialScreen> createState() => _StudyMaterialScreenState();
}

class _StudyMaterialScreenState extends State<StudyMaterialScreen> {
  // Current selected subject filter
  String _selectedSubject = 'All';
  
  // Mock data for study materials
  final List<StudyMaterial> _studyMaterials = [
    StudyMaterial(
      id: 'SM-2023-001',
      title: 'Mathematics - Algebra Basics',
      description: 'Introduction to algebraic expressions, variables, and equations',
      subject: 'Mathematics',
      type: MaterialType.pdf,
      uploadedBy: 'Mr. Rajesh Kumar',
      uploadedOn: DateTime.now().subtract(const Duration(days: 5)),
      fileSize: '2.5 MB',
      downloadCount: 45,
    ),
    StudyMaterial(
      id: 'SM-2023-002',
      title: 'Science - Photosynthesis',
      description: 'Comprehensive notes on photosynthesis process with diagrams',
      subject: 'Science',
      type: MaterialType.pdf,
      uploadedBy: 'Mrs. Priya Singh',
      uploadedOn: DateTime.now().subtract(const Duration(days: 3)),
      fileSize: '3.2 MB',
      downloadCount: 38,
    ),
    StudyMaterial(
      id: 'SM-2023-003',
      title: 'English - Grammar Rules',
      description: 'Complete guide to English grammar with examples',
      subject: 'English',
      type: MaterialType.pdf,
      uploadedBy: 'Mrs. Anjali Sharma',
      uploadedOn: DateTime.now().subtract(const Duration(days: 10)),
      fileSize: '1.8 MB',
      downloadCount: 60,
    ),
    StudyMaterial(
      id: 'SM-2023-004',
      title: 'History - Mughal Empire',
      description: 'Detailed timeline and important events of the Mughal Empire',
      subject: 'History',
      type: MaterialType.pdf,
      uploadedBy: 'Mr. Suresh Patel',
      uploadedOn: DateTime.now().subtract(const Duration(days: 7)),
      fileSize: '4.1 MB',
      downloadCount: 28,
    ),
    StudyMaterial(
      id: 'SM-2023-005',
      title: 'Science Experiment - Plant Growth',
      description: 'Video demonstration of the plant growth experiment',
      subject: 'Science',
      type: MaterialType.video,
      uploadedBy: 'Mrs. Priya Singh',
      uploadedOn: DateTime.now().subtract(const Duration(days: 2)),
      fileSize: '18.5 MB',
      duration: '8:24',
      downloadCount: 32,
    ),
    StudyMaterial(
      id: 'SM-2023-006',
      title: 'Computer Science - HTML Basics',
      description: 'Introduction to HTML with code examples',
      subject: 'Computer Science',
      type: MaterialType.pdf,
      uploadedBy: 'Ms. Riya Agarwal',
      uploadedOn: DateTime.now().subtract(const Duration(days: 4)),
      fileSize: '2.3 MB',
      downloadCount: 41,
    ),
    StudyMaterial(
      id: 'SM-2023-007',
      title: 'Mathematics - Geometry Formulas',
      description: 'Collection of important geometry formulas and theorems',
      subject: 'Mathematics',
      type: MaterialType.pdf,
      uploadedBy: 'Mr. Rajesh Kumar',
      uploadedOn: DateTime.now().subtract(const Duration(days: 6)),
      fileSize: '1.6 MB',
      downloadCount: 53,
    ),
    StudyMaterial(
      id: 'SM-2023-008',
      title: 'English - Essay Writing Tips',
      description: 'Audio lesson on how to write effective essays',
      subject: 'English',
      type: MaterialType.audio,
      uploadedBy: 'Mrs. Anjali Sharma',
      uploadedOn: DateTime.now().subtract(const Duration(days: 8)),
      fileSize: '12.7 MB',
      duration: '15:38',
      downloadCount: 25,
    ),
  ];

  // List of available subjects for filtering
  final List<String> _subjects = [
    'All',
    'Mathematics',
    'Science',
    'English',
    'History',
    'Computer Science',
    'Geography',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter study materials based on selected subject
    final filteredMaterials = _selectedSubject == 'All'
        ? _studyMaterials
        : _studyMaterials.where((material) => material.subject == _selectedSubject).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(AppStrings.studyMaterial),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSubjectFilter(),
          _buildRecentlyAdded(),
          Expanded(
            child: _buildMaterialsList(filteredMaterials),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _subjects.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          final isSelected = subject == _selectedSubject;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubject = subject;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE74C3C) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                subject,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentlyAdded() {
    // Get latest 3 materials
    final recentMaterials = List.from(_studyMaterials)
      ..sort((a, b) => b.uploadedOn.compareTo(a.uploadedOn));
    final latestMaterial = recentMaterials.first;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recently Added',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMaterialTypeIcon(latestMaterial.type, size: 45),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      latestMaterial.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latestMaterial.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          latestMaterial.subject,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getSubjectColor(latestMaterial.subject),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Added ${_getTimeAgo(latestMaterial.uploadedOn)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded),
                color: const Color(0xFFE74C3C),
                onPressed: () {
                  // Download functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(List<StudyMaterial> materials) {
    if (materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No study materials found for $_selectedSubject',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        return _buildMaterialCard(materials[index]);
      },
    );
  }

  Widget _buildMaterialCard(StudyMaterial material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // View material details
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildMaterialTypeIcon(material.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getSubjectColor(material.subject).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              material.subject,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _getSubjectColor(material.subject),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.download,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${material.downloadCount}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (material.duration != null) ...[
                            Icon(
                              Icons.timer,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              material.duration!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            material.fileSize,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20),
                  color: const Color(0xFFE74C3C),
                  onPressed: () {
                    // Download functionality
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialTypeIcon(MaterialType type, {double size = 35}) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (type) {
      case MaterialType.pdf:
        icon = Icons.picture_as_pdf;
        color = const Color(0xFFE74C3C);
        bgColor = const Color(0xFFE74C3C).withOpacity(0.1);
        break;
      case MaterialType.video:
        icon = Icons.play_circle_fill;
        color = const Color(0xFF4A90E2);
        bgColor = const Color(0xFF4A90E2).withOpacity(0.1);
        break;
      case MaterialType.audio:
        icon = Icons.headphones;
        color = const Color(0xFF58CC02);
        bgColor = const Color(0xFF58CC02).withOpacity(0.1);
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.6,
      ),
    );
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
        return const Color(0xFF00BCD4);
      default:
        return const Color(0xFF718096);
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
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }
}

enum MaterialType { pdf, video, audio }

class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final String subject;
  final MaterialType type;
  final String uploadedBy;
  final DateTime uploadedOn;
  final String fileSize;
  final String? duration;
  final int downloadCount;

  StudyMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.uploadedBy,
    required this.uploadedOn,
    required this.fileSize,
    this.duration,
    required this.downloadCount,
  });
} 
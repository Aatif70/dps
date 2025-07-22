import 'package:flutter/material.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:intl/intl.dart';

class TeacherStudyMaterialScreen extends StatefulWidget {
  const TeacherStudyMaterialScreen({super.key});

  @override
  State<TeacherStudyMaterialScreen> createState() => _TeacherStudyMaterialScreenState();
}

class _TeacherStudyMaterialScreenState extends State<TeacherStudyMaterialScreen> {
  String _selectedSubject = 'All';
  String _selectedClass = 'All';
  
  // Mock data for study materials
  final List<StudyMaterial> _studyMaterials = [
    StudyMaterial(
      id: 'SM-2023-001',
      title: 'Mathematics - Algebra Basics',
      description: 'Introduction to algebraic expressions, variables, and equations',
      subject: 'Mathematics',
      classAssigned: 'Class 10-A',
      type: MaterialType.pdf,
      uploadedBy: 'Dr. Rajesh Kumar',
      uploadedOn: DateTime.now().subtract(const Duration(days: 5)),
      fileSize: '2.5 MB',
      downloadCount: 45,
    ),
    StudyMaterial(
      id: 'SM-2023-002',
      title: 'Science - Photosynthesis',
      description: 'Comprehensive notes on photosynthesis process with diagrams',
      subject: 'Science',
      classAssigned: 'Class 11-A',
      type: MaterialType.pdf,
      uploadedBy: 'Dr. Rajesh Kumar',
      uploadedOn: DateTime.now().subtract(const Duration(days: 3)),
      fileSize: '3.2 MB',
      downloadCount: 38,
    ),
    StudyMaterial(
      id: 'SM-2023-003',
      title: 'English - Grammar Rules',
      description: 'Complete guide to English grammar with examples',
      subject: 'English',
      classAssigned: 'Class 10-B',
      type: MaterialType.pdf,
      uploadedBy: 'Dr. Rajesh Kumar',
      uploadedOn: DateTime.now().subtract(const Duration(days: 10)),
      fileSize: '1.8 MB',
      downloadCount: 60,
    ),
    StudyMaterial(
      id: 'SM-2023-004',
      title: 'Physics - Newton\'s Laws Video',
      description: 'Video explanation of Newton\'s Laws of Motion with examples',
      subject: 'Physics',
      classAssigned: 'Class 11-A',
      type: MaterialType.video,
      uploadedBy: 'Dr. Rajesh Kumar',
      uploadedOn: DateTime.now().subtract(const Duration(days: 7)),
      fileSize: '45 MB',
      duration: '12:35',
      downloadCount: 52,
    ),
    StudyMaterial(
      id: 'SM-2023-005',
      title: 'Mathematics - Quadratic Equations',
      description: 'Detailed explanation of quadratic equations and their solutions',
      subject: 'Mathematics',
      classAssigned: 'Class 10-A',
      type: MaterialType.pdf,
      uploadedBy: 'Dr. Rajesh Kumar',
      uploadedOn: DateTime.now().subtract(const Duration(days: 2)),
      fileSize: '1.5 MB',
      downloadCount: 28,
    ),
  ];

  // List of available subjects for filtering
  final List<String> _subjects = [
    'All',
    'Mathematics',
    'Science',
    'English',
    'Physics',
    'Computer Science',
    'Geography',
  ];

  // List of available classes for filtering
  final List<String> _classes = [
    'All',
    'Class 10-A',
    'Class 10-B',
    'Class 11-A',
    'Class 11-B',
    'Class 12-A',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter study materials based on selected subject and class
    final filteredMaterials = _studyMaterials.where((material) {
      final subjectMatch = _selectedSubject == 'All' || material.subject == _selectedSubject;
      final classMatch = _selectedClass == 'All' || material.classAssigned == _selectedClass;
      return subjectMatch && classMatch;
    }).toList();

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
          _buildFilters(),
          _buildUploadStats(),
          Expanded(
            child: _buildMaterialsList(filteredMaterials),
          ),
        ],
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
    // Calculate statistics
    final totalMaterials = _studyMaterials.length;
    final totalDownloads = _studyMaterials.fold<int>(
      0,
      (sum, material) => sum + material.downloadCount,
    );
    
    // Get materials uploaded this month
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final materialsThisMonth = _studyMaterials.where(
      (material) => material.uploadedOn.isAfter(thisMonth),
    ).length;

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
            'This Month',
            materialsThisMonth.toString(),
            const Color(0xFF58CC02),
            Icons.calendar_today_rounded,
          ),
          _buildStatItem(
            'Downloads',
            totalDownloads.toString(),
            const Color(0xFF4A90E2),
            Icons.download_rounded,
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

  Widget _buildMaterialsList(List<StudyMaterial> materials) {
    if (materials.isEmpty) {
      return Center(
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // View material details
        },
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
                      color: _getTypeColor(material.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getTypeIcon(material.type),
                        color: _getTypeColor(material.type),
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
                          material.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          material.description,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
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
                            const SizedBox(width: 8),
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
                                material.classAssigned,
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
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeAgo(material.uploadedOn),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.download,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        material.downloadCount.toString(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        material.fileSize,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      if (material.duration != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          material.duration!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Edit material
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
                      onPressed: () {
                        // Share material
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
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
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: _subjects
                            .where((subject) => subject != 'All')
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                        ),
                        items: _classes
                            .where((cls) => cls != 'All')
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Material Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ['PDF Document', 'Video', 'Audio', 'Presentation']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: Color(0xFFE74C3C),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Drag and drop files here',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'or',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Browse files
                        },
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Browse Files'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE74C3C),
                          side: const BorderSide(color: Color(0xFFE74C3C)),
                        ),
                      ),
                    ],
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
                          content: Text('Study material uploaded successfully!'),
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

  Color _getTypeColor(MaterialType type) {
    switch (type) {
      case MaterialType.pdf:
        return const Color(0xFFE74C3C);
      case MaterialType.video:
        return const Color(0xFF4A90E2);
      case MaterialType.audio:
        return const Color(0xFF58CC02);
      case MaterialType.presentation:
        return const Color(0xFFFF9500);
    }
  }

  IconData _getTypeIcon(MaterialType type) {
    switch (type) {
      case MaterialType.pdf:
        return Icons.picture_as_pdf;
      case MaterialType.video:
        return Icons.videocam;
      case MaterialType.audio:
        return Icons.audiotrack;
      case MaterialType.presentation:
        return Icons.slideshow;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
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

enum MaterialType { pdf, video, audio, presentation }

class StudyMaterial {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String classAssigned;
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
    required this.classAssigned,
    required this.type,
    required this.uploadedBy,
    required this.uploadedOn,
    required this.fileSize,
    this.duration,
    required this.downloadCount,
  });
} 
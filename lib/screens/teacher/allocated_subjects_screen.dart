import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/widgets/custom_snackbar.dart';
import '../../services/allocated_subjects_service.dart';


class TeacherAllocatedSubjectsScreen extends StatefulWidget {
  const TeacherAllocatedSubjectsScreen({super.key});

  @override
  State<TeacherAllocatedSubjectsScreen> createState() => _TeacherAllocatedSubjectsScreenState();
}

class _TeacherAllocatedSubjectsScreenState extends State<TeacherAllocatedSubjectsScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<AllocatedSubject> _allocatedSubjects = [];
  bool _isLoading = true;

  // Group subjects by class for better organization
  Map<String, List<AllocatedSubject>> _groupedSubjects = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _fetchAllocatedSubjects();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllocatedSubjects() async {
    setState(() => _isLoading = true);

    try {
      final subjects = await AllocatedSubjectsService.getAllocatedSubjects();

      // Group subjects by class
      _groupSubjectsByClass(subjects);

      setState(() {
        _allocatedSubjects = subjects;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      print('Error loading allocated subjects: $e');
      setState(() => _isLoading = false);

      CustomSnackbar.showError(context, message: 'Failed to load allocated subjects');
    }
  }

  void _groupSubjectsByClass(List<AllocatedSubject> subjects) {
    _groupedSubjects.clear();
    for (var subject in subjects) {
      if (!_groupedSubjects.containsKey(subject.className)) {
        _groupedSubjects[subject.className] = [];
      }
      _groupedSubjects[subject.className]!.add(subject);
    }
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _fetchAllocatedSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        AppStrings.allocatedSubjects,
        style: const TextStyle(
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
              color: const Color(0xFF58CC02).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF58CC02),
              size: 20,
            ),
          ),
          onPressed: _refreshData,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF58CC02)),
        ),
      );
    }

    if (_allocatedSubjects.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF58CC02),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                _buildSummaryCard(),
                Expanded(child: _buildSubjectsList()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02).withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_outlined,
              size: 64,
              color: Color(0xFF58CC02),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Subjects Allocated',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You haven\'t been allocated any subjects yet.\nCheck back later or contact administration.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalSubjects = _allocatedSubjects.length;
    final uniqueSubjects = _allocatedSubjects.map((s) => s.subject).toSet().length;
    final totalClasses = _groupedSubjects.keys.length;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teaching Assignment',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Academic Overview 📚',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('$totalSubjects', 'Total\nAssignments', Colors.white),
              _buildSummaryItem('$uniqueSubjects', 'Unique\nSubjects', Colors.white),
              _buildSummaryItem('$totalClasses', 'Classes\nTeaching', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha:0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectsList() {
    final sortedClassNames = _groupedSubjects.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sortedClassNames.length,
      itemBuilder: (context, index) {
        final className = sortedClassNames[index];
        final subjects = _groupedSubjects[className]!;

        return _buildClassSection(className, subjects);
      },
    );
  }

  Widget _buildClassSection(String className, List<AllocatedSubject> subjects) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getClassColor(className).withValues(alpha:0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getClassColor(className).withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.class_rounded,
                    color: _getClassColor(className),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class $className',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getClassColor(className),
                        ),
                      ),
                      Text(
                        '${subjects.length} subject${subjects.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subjects List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.shade100,
              height: 1,
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              return _buildSubjectTile(subjects[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(AllocatedSubject subject) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getSubjectColor(subject.subject).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getSubjectIcon(subject.subject),
              color: _getSubjectColor(subject.subject),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject.subjectType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getSubjectColor(subject.subject).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getSubjectColor(subject.subject).withValues(alpha:0.3),
              ),
            ),
            child: Text(
              subject.subjectType,
              style: TextStyle(
                color: _getSubjectColor(subject.subject),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getClassColor(String className) {
    switch (className) {
      case '1st':
        return const Color(0xFF4A90E2);
      case '2nd':
        return const Color(0xFF58CC02);
      case '3rd':
        return const Color(0xFFFF9500);
      case '4th':
        return const Color(0xFFE74C3C);
      case '5th':
        return const Color(0xFF8E44AD);
      default:
        return const Color(0xFF2ECC71);
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
      case 'marathi':
        return const Color(0xFFE74C3C);
      case 'gk':
        return const Color(0xFF9B59B6);
      case 'reading':
        return const Color(0xFF34495E);
      case 'p.t.':
        return const Color(0xFF16A085);
      case 'study hours':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'mathematics':
      case 'maths':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'english':
        return Icons.menu_book_rounded;
      case 'physics':
        return Icons.flash_on_rounded;
      case 'marathi':
        return Icons.language_rounded;
      case 'gk':
        return Icons.lightbulb_rounded;
      case 'reading':
        return Icons.auto_stories_rounded;
      case 'p.t.':
        return Icons.sports_soccer_rounded;
      case 'study hours':
        return Icons.schedule_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}

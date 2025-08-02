import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/services/homework_service.dart';
import 'package:dps/widgets/custom_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dps/constants/api_constants.dart';
import 'package:photo_view/photo_view.dart';


class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _cardFadeAnimation;

  // Real data from API
  List<StudentHomeworkRecord> _homeworkRecords = [];
  bool _isLoading = true;

  // Date range selection
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  // Grouped data
  Map<String, List<StudentHomeworkRecord>> _groupedByDate = {};
  Map<String, int> _subjectCounts = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHomeworkData();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _headerAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _cardAnimationController.forward();
  }

  Future<void> _loadHomeworkData() async {
    print('=== HOMEWORK SCREEN DEBUG START ===');
    setState(() {
      _isLoading = true;
    });

    try {
      print('Homework Screen - Calling HomeworkService.getStudentHomework()');
      print('Date range: ${_fromDate.toIso8601String()} to ${_toDate.toIso8601String()}');

      final homeworkRecords = await HomeworkService.getStudentHomework(
        fromDate: _fromDate,
        toDate: _toDate,
      );

      print('Homework Screen - Received ${homeworkRecords.length} homework records');

      // Group data by date and calculate subject counts
      _groupDataByDate(homeworkRecords);
      _calculateSubjectCounts(homeworkRecords);

      setState(() {
        _homeworkRecords = homeworkRecords;
        _isLoading = false;
      });

      print('Homework Screen - State updated successfully');
      print('=== HOMEWORK SCREEN DEBUG END ===');
    } catch (e, stackTrace) {
      print('Homework Screen - Error occurred: $e');
      print('Stack trace: $stackTrace');

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        CustomSnackbar.showError(
          context,
          message: 'Failed to load homework data. Please try again.',
        );
      }
    }
  }

  // Add this method to handle document viewing
  Future<void> _viewDocument(String docPath, String subject) async {
    if (docPath.isEmpty || docPath == '/StudyMaterial/HomeWork/') {
      CustomSnackbar.showError(
        context,
        message: 'No document attached to this homework',
      );
      return;
    }

    try {
      final fullUrl = '${ApiConstants.baseUrl}$docPath';
      print('Opening document: $fullUrl');

      // Check file extension to determine how to handle it
      final extension = docPath.toLowerCase().split('.').last;

      if (['png', 'jpg', 'jpeg', 'gif', 'bmp'].contains(extension)) {
        // Show image in modal
        _showImageModal(fullUrl, subject);
      } else if (['pdf'].contains(extension)) {
        // Open PDF externally
        await _openUrlExternally(fullUrl);
      } else if (['txt', 'doc', 'docx'].contains(extension)) {
        // For text files, try to open externally or show in modal
        await _openUrlExternally(fullUrl);
      } else {
        // For other file types, try to open externally
        await _openUrlExternally(fullUrl);
      }
    } catch (e) {
      print('Error viewing document: $e');
      CustomSnackbar.showError(
        context,
        message: 'Unable to open document. Please try again.',
      );
    }
  }

// Method to show image in modal
  void _showImageModal(String imageUrl, String subject) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$subject - Attachment',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Image
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: PhotoView(
                      imageProvider: NetworkImage(imageUrl),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.black,
                      ),
                      minScale: PhotoViewComputedScale.contained * 0.8,
                      maxScale: PhotoViewComputedScale.covered * 2.0,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Unable to load image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Footer with download button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openUrlExternally(imageUrl),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Open in Browser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

// Method to open URL externally
  Future<void> _openUrlExternally(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          message: 'Unable to open document',
        );
      }
    }
  }

// Helper method to get file type icon
  IconData _getFileTypeIcon(String docPath) {
    if (docPath.isEmpty || docPath == '/StudyMaterial/HomeWork/') {
      return Icons.attach_file_rounded;
    }

    final extension = docPath.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'gif':
      case 'bmp':
        return Icons.image_rounded;
      case 'txt':
        return Icons.text_snippet_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }


  void _groupDataByDate(List<StudentHomeworkRecord> records) {
    _groupedByDate.clear();
    for (var record in records) {
      final dateKey = DateFormat('yyyy-MM-dd').format(record.date);
      if (!_groupedByDate.containsKey(dateKey)) {
        _groupedByDate[dateKey] = [];
      }
      _groupedByDate[dateKey]!.add(record);
    }
  }

  void _calculateSubjectCounts(List<StudentHomeworkRecord> records) {
    _subjectCounts.clear();
    for (var record in records) {
      final subject = record.subject;
      _subjectCounts[subject] = (_subjectCounts[subject] ?? 0) + 1;
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: RefreshIndicator(
        onRefresh: _loadHomeworkData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selector
              AnimatedBuilder(
                animation: _headerSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _headerSlideAnimation.value),
                    child: _buildDateRangeSelector(),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Summary Statistics
              AnimatedBuilder(
                animation: _cardFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cardFadeAnimation.value,
                    child: _buildSummaryStats(),
                  );
                },
              ),

              const SizedBox(height: 25),

              // Subject Overview
              if (_subjectCounts.isNotEmpty)
                AnimatedBuilder(
                  animation: _cardFadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _cardFadeAnimation.value,
                      child: _buildSubjectOverview(),
                    );
                  },
                ),

              const SizedBox(height: 25),

              // Homework Timeline
              AnimatedBuilder(
                animation: _cardFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cardFadeAnimation.value,
                    child: _buildHomeworkTimeline(),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'My Homework',
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
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          onPressed: _loadHomeworkData,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF4A90E2),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Select Date Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDateSelector(
                  'From Date',
                  _fromDate,
                      (date) {
                    setState(() {
                      _fromDate = date;
                      if (_toDate.isBefore(_fromDate)) {
                        _toDate = _fromDate;
                      }
                    });
                    _loadHomeworkData();
                  },
                ),
              ),
              // const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF4A90E2),
                  size: 16,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateSelector(
                  'To Date',
                  _toDate,
                      (date) {
                    setState(() {
                      _toDate = date;
                    });
                    _loadHomeworkData();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4A90E2).withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF4A90E2).withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF718096),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalAssignments = _homeworkRecords.length;
    final uniqueSubjects = _subjectCounts.keys.length;
    final daysWithHomework = _groupedByDate.keys.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF58CC02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withOpacity(0.3),
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
                      Icons.assignment_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Homework Overview 📚',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Spacer(),
                    _buildStatItem('$totalAssignments', 'Assignments', Colors.white),
                    const SizedBox(width: 20),
                    _buildStatItem('$uniqueSubjects', 'Subjects', Colors.white),
                    const SizedBox(width: 45),
                    _buildStatItem('$daysWithHomework', 'Days', Colors.white),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
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
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              const Icon(
                Icons.subject_rounded,
                color: Color(0xFF4A90E2),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Subject Distribution',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _subjectCounts.entries.map((entry) {
              return _buildSubjectChip(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectChip(String subject, int count) {
    final subjectColor = SubjectHelper.getSubjectColor(subject);
    final subjectIcon = SubjectHelper.getSubjectIcon(subject);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: subjectColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: subjectColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            subjectIcon,
            color: subjectColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            subject,
            style: TextStyle(
              color: subjectColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: subjectColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkTimeline() {
    if (_homeworkRecords.isEmpty) {
      return _buildEmptyState();
    }

    final sortedDates = _groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                const Icon(
                  Icons.timeline_rounded,
                  color: Color(0xFF4A90E2),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Homework Timeline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateKey = sortedDates[index];
              final homeworkForDate = _groupedByDate[dateKey]!;
              return _buildDateSection(dateKey, homeworkForDate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String dateKey, List<StudentHomeworkRecord> homework) {
    final date = DateTime.parse(dateKey);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFF4A90E2).withOpacity(0.1) : Colors.grey.shade50,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFF4A90E2) : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isToday ? const Color(0xFF4A90E2) : const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      '${homework.length} assignment${homework.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: homework.length,
          itemBuilder: (context, index) {
            return _buildHomeworkCard(homework[index], index == homework.length - 1);
          },
        ),
      ],
    );
  }

  Widget _buildHomeworkCard(StudentHomeworkRecord homework, bool isLast) {
    final subjectColor = SubjectHelper.getSubjectColor(homework.subject);
    final subjectIcon = SubjectHelper.getSubjectIcon(homework.subject);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: subjectColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: subjectColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  subjectIcon,
                  color: subjectColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homework.subject,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: subjectColor,
                      ),
                    ),
                    Text(
                      'Class: ${homework.className} - ${homework.batch}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              if (homework.doc != null && homework.doc!.isNotEmpty)
                GestureDetector(
                  onTap: () => _viewDocument(homework.doc!, homework.subject),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getFileTypeIcon(homework.doc!),
                          color: const Color(0xFF58CC02),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'View',
                          style: TextStyle(
                            color: Color(0xFF58CC02),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              homework.homework,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF2D3748),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: Colors.grey.shade600,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  homework.employee,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'Div: ${homework.division}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_rounded,
              size: 48,
              color: Color(0xFF4A90E2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Homework Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No homework assignments found for the selected date range. Try selecting a different date range.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

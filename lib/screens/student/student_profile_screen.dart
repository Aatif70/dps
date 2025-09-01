import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/services/student_profile_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:dps/widgets/custom_snackbar.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  StudentDetail? _studentDetail;
  List<DocumentCategory> _documentCategories = [];

  @override
  void initState() {
    super.initState();
    _initializeFadeAnimation();
    _loadStudentData();
  }

  void _initializeFadeAnimation() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _startFadeAnimation();
  }

  void _startFadeAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeAnimationController.forward();
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      debugPrint('=== LOADING STUDENT PROFILE DATA ===');

      // Load student details
      final studentDetailResponse = await StudentProfileService.getStudentDetails();
      if (studentDetailResponse != null) {
        _studentDetail = studentDetailResponse.data;
        debugPrint('=== STUDENT DETAILS LOADED ===');
        debugPrint('Student: ${_studentDetail!.studentName}');
      }

      // Load student documents
      final documentsResponse = await StudentProfileService.getStudentDocuments();
      if (documentsResponse != null) {
        _documentCategories = documentsResponse.data;
        debugPrint('=== STUDENT DOCUMENTS LOADED ===');
        debugPrint('Categories: ${_documentCategories.length}');
      }

      setState(() {
        _isLoading = false;
        _hasError = false;
      });

    } catch (e) {
      debugPrint('=== ERROR LOADING STUDENT DATA ===');
      debugPrint('Error: $e');

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load student data: $e';
      });
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildEnhancedAppBar(context),
      body: _isLoading
          ? _buildLoadingWidget()
          : _hasError
          ? _buildErrorWidget()
          : AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEnhancedHeader(context),
                        const SizedBox(height: 25),
                        _buildQuickStats(context),
                        const SizedBox(height: 25),
                        _buildPersonalInformation(context),
                        const SizedBox(height: 25),
                        _buildDocumentsSection(context),
                        const SizedBox(height: 25),
                        _buildLogoutButton(context),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStudentData,
        backgroundColor: const Color(0xFF4A90E2),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading student profile...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadStudentData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'My Profile',
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
              color: const Color(0xFF4A90E2).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          onPressed: _loadStudentData,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'student_avatar',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    backgroundImage: _studentDetail?.photo.isNotEmpty == true
                        ? NetworkImage(_studentDetail!.photoUrl)
                        : null,
                    onBackgroundImageError: _studentDetail?.photo.isNotEmpty == true
                        ? (exception, stackTrace) {
                            debugPrint('Image loading failed for student profile: ${_studentDetail?.photoUrl}');
                          }
                        : null,
                    child: _studentDetail?.photo.isEmpty == true
                        ? const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF718096),
                      size: 32,
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _studentDetail?.studentName ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _studentDetail?.className ?? 'Class Information',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'PRN: ${_studentDetail?.prn ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final totalDocuments = _documentCategories
        .fold(0, (sum, category) => sum + category.documents.length);
    final uploadedDocuments = _documentCategories
        .fold(0, (sum, category) =>
    sum + category.documents.where((doc) => doc.isUploaded).length);
    final pendingDocuments = totalDocuments - uploadedDocuments;

    final stats = [
      StatData(
        title: 'Admission Year',
        value: _studentDetail?.admissionYear.toString() ?? '0',
        color: const Color(0xFF4A90E2),
        icon: Icons.school_rounded,
        subtitle: 'Academic year',
      ),
      StatData(
        title: 'Category',
        value: _studentDetail?.category ?? 'N/A',
        color: const Color(0xFF58CC02),
        icon: Icons.category_rounded,
        subtitle: 'Student category',
      ),
      StatData(
        title: 'Documents',
        value: '$uploadedDocuments/$totalDocuments',
        color: const Color(0xFFFF9500),
        icon: Icons.description_rounded,
        subtitle: 'Uploaded',
      ),
      StatData(
        title: 'Pending',
        value: pendingDocuments.toString(),
        color: const Color(0xFFE74C3C),
        icon: Icons.pending_actions_rounded,
        subtitle: 'Documents',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          return _buildEnhancedStatCard(stats[index]);
        },
      ),
    );
  }

  Widget _buildEnhancedStatCard(StatData stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: stat.color.withValues(alpha:0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stat.color.withValues(alpha:0.1),
                      stat.color.withValues(alpha:0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  stat.icon,
                  color: stat.color,
                  size: 24,
                ),
              ),
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: stat.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            stat.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            stat.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation(BuildContext context) {
    if (_studentDetail == null) return Container();

    final infoItems = [
      ProfileInfoItem(
        icon: Icons.email_outlined,
        title: 'Email Address',
        value: _studentDetail!.email,
      ),
      ProfileInfoItem(
        icon: Icons.phone_outlined,
        title: 'Student Mobile',
        value: _studentDetail!.studentMobile,
      ),
      ProfileInfoItem(
        icon: Icons.phone_android_outlined,
        title: 'Parent Mobile',
        value: _studentDetail!.parentMobile,
      ),
      ProfileInfoItem(
        icon: Icons.location_on_outlined,
        title: 'Address',
        value: _studentDetail!.address,
      ),
      ProfileInfoItem(
        icon: Icons.group_outlined,
        title: 'Caste',
        value: _studentDetail!.caste.isEmpty ? 'N/A' : _studentDetail!.caste,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 24),
          ...infoItems.map((item) => _buildInfoItem(context, item)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, ProfileInfoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: const Color(0xFF4A90E2),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Documents',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_documentCategories.length} Categories',
                    style: const TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_documentCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No documents found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _documentCategories.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color(0xFFE2E8F0),
              ),
              itemBuilder: (context, index) {
                return _buildDocumentCategory(_documentCategories[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCategory(DocumentCategory category) {
    return ExpansionTile(
      title: Text(
        category.category,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        '${category.documents.length} documents',
        style: const TextStyle(
          color: Color(0xFF718096),
          fontSize: 12,
        ),
      ),
      children: category.documents.map((document) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: document.isUploaded
                  ? const Color(0xFF58CC02).withValues(alpha:0.1)
                  : const Color(0xFFE74C3C).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              document.isUploaded
                  ? Icons.check_circle_outline
                  : Icons.upload_file_outlined,
              color: document.isUploaded
                  ? const Color(0xFF58CC02)
                  : const Color(0xFFE74C3C),
              size: 20,
            ),
          ),
          title: Text(
            document.docType,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            document.isUploaded ? 'Uploaded' : 'Pending',
            style: TextStyle(
              color: document.isUploaded
                  ? const Color(0xFF58CC02)
                  : const Color(0xFFE74C3C),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: document.isUploaded
              ? IconButton(
            icon: const Icon(Icons.visibility_outlined),
            onPressed: () {
              _showDocumentViewer(document);
            },
          )
              : const Icon(Icons.upload_outlined, color: Color(0xFF718096)),
        );
      }).toList(),
    );
  }

  void _showDocumentViewer(Document document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentViewerModal(document: document),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                    (route) => false,
                arguments: 'student',
              );
            }
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53E3E),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

// Data model for statistics
class StatData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final String subtitle;

  const StatData({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.subtitle,
  });
}

// Data model for profile information
class ProfileInfoItem {
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });
}

// Document Viewer Modal
class DocumentViewerModal extends StatefulWidget {
  final Document document;

  const DocumentViewerModal({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<DocumentViewerModal> createState() => _DocumentViewerModalState();
}

class _DocumentViewerModalState extends State<DocumentViewerModal> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkDocumentAccessibility();
  }

  Future<void> _checkDocumentAccessibility() async {
    try {
      final url = widget.document.fullDocumentPath;
      if (url.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Document path is empty';
          _isLoading = false;
        });
        return;
      }

      // Try to make a HEAD request to check if the document exists
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Document not found (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error accessing document: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildModalHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingWidget()
                : _hasError
                    ? _buildErrorWidget()
                    : _buildDocumentViewer(),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.document.docType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Document Viewer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading document...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load document',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _checkDocumentAccessibility,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openDocumentInBrowser(),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentViewer() {
    final url = widget.document.fullDocumentPath;
    final fileExtension = _getFileExtension(url);

    if (_isImageFile(fileExtension)) {
      return _buildImageViewer(url);
    } else if (_isPdfFile(fileExtension)) {
      return _buildPdfViewer(url);
    } else {
      return _buildGenericViewer(url);
    }
  }

  Widget _buildImageViewer(String url) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer(String url) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFF4A90E2),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PDF Document',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PDF Viewer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This document is a PDF file',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _openDocumentInBrowser(),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open in Browser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenericViewer(String url) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF58CC02).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description,
                  color: Color(0xFF58CC02),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Document File',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.description,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Document Viewer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This document cannot be previewed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _openDocumentInBrowser(),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open in Browser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final extension = path.split('.').last.toLowerCase();
      return extension;
    } catch (e) {
      return '';
    }
  }

  bool _isImageFile(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  bool _isPdfFile(String extension) {
    return extension == 'pdf';
  }

  Future<void> _openDocumentInBrowser() async {
    final url = widget.document.fullDocumentPath;
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          CustomSnackbar.showError(context, message: 'Could not open document in browser');
        }
      } catch (e) {
        CustomSnackbar.showError(context, message: 'Error opening document: $e');
      }
    }
  }
}

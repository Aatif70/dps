import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dps/widgets/event_calendar_widget.dart';
import 'package:dps/widgets/gallery_preview_widget.dart';
import 'package:dps/services/student_profile_service.dart';


class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  String _fullName = '';
  String _photoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadFullName();
    _loadStudentPhoto();
    // Initialize animation controller for fade effect
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    // Setup fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));
    // Start animation
    _fadeAnimationController.forward();
  }

  Future<void> _loadFullName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('FullName') ?? 'cant get name';
    });
  }

  Future<void> _loadStudentPhoto() async {
    try {
      final details = await StudentProfileService.getStudentDetails();
      if (!mounted) return;
      setState(() {
        _photoUrl = (details?.data.photo.isNotEmpty == true) ? details!.data.photoUrl : '';
      });
    } catch (_) {
      // ignore errors, fallback will handle
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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildEnhancedHeader(context),
                const SizedBox(height: 25),

                // EVENT CALENDAR - NEW ADDITION
                const EventCalendarWidget(),
                const SizedBox(height: 25),

                // Your Learning Hub
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Your Learning Hub',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Feature Grid
                _buildEnhancedFeatureGrid(context),
                const SizedBox(height: 30),
                // Others
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Others',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Feature Grid 2
                _buildEnhancedFeatureGrid2(context),


                const SizedBox(height: 30),
                // GALLERY PREVIEW - NEW ADDITION
                const GalleryPreviewWidget(),
                const SizedBox(height: 30),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.studentProfile);
      },
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back! 👋',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha:0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fullName,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 12),

                    ],
                  ),
                ),

                // Avatar with Online Indicator
                Stack(
                  children: [
                    Hero(
                      tag: 'student_avatar',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
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
                          backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                          onBackgroundImageError: _photoUrl.isNotEmpty
                              ? (exception, stackTrace) {
                                  debugPrint('Image loading failed for student dashboard: $_photoUrl');
                                }
                              : null,
                          child: _photoUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.blueGrey,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF58CC02),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFeatureGrid(BuildContext context) {
    final features = [

      FeatureData(
        title: AppStrings.studyMaterial,
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFE74C3C),
        // value: '45',
        // subtitle: 'Resources',
        route: AppRoutes.studentStudyMaterial,
      ),

      // FeatureData(
      //   title: AppStrings.examination,
      //   icon: Icons.school_rounded,
      //   color: const Color(0xFF2ECC71),
      //   // value: '5',
      //   // subtitle: 'Days to go',
      //   route: AppRoutes.studentExamination,
      // ),

      FeatureData(
        title: AppStrings.homework,
        icon: Icons.assignment_rounded,
        color: const Color(0xFF58CC02),
        // value: '3',
        // subtitle: 'Pending',
        route: AppRoutes.studentHomework,
      ),

      FeatureData(
        title: AppStrings.attendance,
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFF4A90E2),
        // value: '85%',
        // subtitle: 'This month',
        route: AppRoutes.studentAttendance,
      ),

      FeatureData(
        title: AppStrings.timetable,
        icon: Icons.calendar_month,
        color: Colors.cyan,
        // value: '85%',
        // subtitle: 'This month',
        route: AppRoutes.studenttimetable,
      ),

      FeatureData(
        title: AppStrings.studentmarks,
        icon: Icons.assessment_rounded,
        color: Colors.amberAccent,
        // value: '85%',
        // subtitle: 'This month',
        route: AppRoutes.studentmarks,
      ),


    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return _buildEnhancedFeatureCard(context, features[index]);
        },
      ),
    );
  }

  Widget _buildEnhancedFeatureGrid2(BuildContext context) {
    final features = [



      FeatureData(
        title: AppStrings.leave,
        icon: Icons.event_busy_rounded,
        color: const Color(0xFF8E44AD),
        // value: '18',
        // subtitle: 'Days left',
        route: AppRoutes.studentLeave,
      ),

      FeatureData(
        title: AppStrings.fees,
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFFFF9500),
        // value: '₹12,500',
        // subtitle: 'Left',
        route: AppRoutes.studentFees,
      ),

    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return _buildEnhancedFeatureCard(context, features[index]);
        },
      ),
    );
  }

  Widget _buildEnhancedFeatureCard(BuildContext context, FeatureData feature) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, feature.route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: feature.color.withValues(alpha:0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Container with Gradient
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      feature.color.withValues(alpha:0.1),
                      feature.color.withValues(alpha:0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  feature.icon,
                  color: feature.color,
                  size: 28,
                ),
              ),

              const SizedBox(height: 22),

              // Title
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),

              // const Spacer(),

              // Value and Subtitle
              // Row(
              //   children: [
              //     Text(
              //       feature.value,
              //       style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              //         color: feature.color,
              //         fontWeight: FontWeight.bold,
              //         fontSize: 20,
              //       ),
              //     ),
              //     const SizedBox(width: 8),
              //     Expanded(
              //       child: Text(
              //         feature.subtitle,
              //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //           color: const Color(0xFF718096),
              //           fontSize: 12,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureData {
  final String title;
  final IconData icon;
  final Color color;
  // final String value;
  // final String subtitle;
  final String route;

  const FeatureData({
    required this.title,
    required this.icon,
    required this.color,
    // required this.value,
    // required this.subtitle,
    required this.route,
  });
}

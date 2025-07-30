import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

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


                // Section Title
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
              color: const Color(0xFF4A90E2).withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Priya Sharma',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Streak Counter
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                              '7 Day Streak! 🔥',
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
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Text(
                            'PS',
                            style: TextStyle(
                              color: Color(0xFF4A90E2),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
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



  Widget _buildMiniProgress(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFeatureGrid(BuildContext context) {
    final features = [
      FeatureData(
        title: AppStrings.attendance,
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFF4A90E2),
        value: '85%',
        subtitle: 'This month',
        route: AppRoutes.studentAttendance,
      ),
      FeatureData(
        title: AppStrings.fees,
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFFFF9500),
        value: '₹12,500',
        subtitle: 'Left',
        route: AppRoutes.studentFees,
      ),
      FeatureData(
        title: AppStrings.homework,
        icon: Icons.assignment_rounded,
        color: const Color(0xFF58CC02),
        value: '3',
        subtitle: 'Pending',
        route: AppRoutes.studentHomework,
      ),
      FeatureData(
        title: AppStrings.leave,
        icon: Icons.event_busy_rounded,
        color: const Color(0xFF8E44AD),
        value: '8',
        subtitle: 'Days left',
        route: AppRoutes.studentLeave,
      ),
      FeatureData(
        title: AppStrings.studyMaterial,
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFE74C3C),
        value: '45',
        subtitle: 'Resources',
        route: AppRoutes.studentStudyMaterial,
      ),
      FeatureData(
        title: AppStrings.examination,
        icon: Icons.school_rounded,
        color: const Color(0xFF2ECC71),
        value: '5',
        subtitle: 'Days to go',
        route: AppRoutes.studentExamination,
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
          childAspectRatio: 0.85,
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
              color: feature.color.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container with Gradient
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      feature.color.withOpacity(0.1),
                      feature.color.withOpacity(0.05),
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

              const SizedBox(height: 16),

              // Title
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),

              const Spacer(),

              // Value and Subtitle
              Row(
                children: [
                  Text(
                    feature.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: feature.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF718096),
                        fontSize: 12,
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
}

class FeatureData {
  final String title;
  final IconData icon;
  final Color color;
  final String value;
  final String subtitle;
  final String route;

  const FeatureData({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.subtitle,
    required this.route,
  });
}

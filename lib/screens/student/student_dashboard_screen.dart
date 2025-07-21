import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/theme/app_theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math' as math;

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _streakAnimationController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _progressScaleAnimation;
  late Animation<double> _streakPulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _streakAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Setup animations
    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _progressScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.elasticOut,
    ));

    _streakPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _streakAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _headerAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _progressAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _cardsAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _progressAnimationController.dispose();
    _cardsAnimationController.dispose();
    _streakAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Header
              AnimatedBuilder(
                animation: _headerSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _headerSlideAnimation.value),
                    child: _buildEnhancedHeader(context),
                  );
                },
              ),

              const SizedBox(height: 25),

              // Animated Progress Section
              AnimatedBuilder(
                animation: _progressScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _progressScaleAnimation.value,
                    child: _buildEnhancedProgressSection(context),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Section Title with Animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _cardsAnimationController,
                    curve: const Interval(0.0, 0.1, curve: Curves.easeIn),
                  )),
                  child: Text(
                    'Your Learning Hub',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Enhanced Feature Grid with Staggered Animation
              _buildEnhancedFeatureGrid(context),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
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

                    // Enhanced Streak Counter
                    AnimatedBuilder(
                      animation: _streakPulseAnimation,
                      builder: (context, child) {
                        return Container(
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
                              Transform.scale(
                                scale: _streakPulseAnimation.value,
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFFF9500),
                                  size: 18,
                                ),
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
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Enhanced Avatar with Online Indicator
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
    );
  }

  Widget _buildEnhancedProgressSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
        child: Row(
          children: [
            // Enhanced Circular Progress
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 0.78),
              duration: const Duration(milliseconds: 2000),
              builder: (context, value, child) {
                return CircularPercentIndicator(
                  radius: 50.0,
                  lineWidth: 10.0,
                  percent: value,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${(value * 100).toInt()}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      const Text(
                        "Overall",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                  progressColor: const Color(0xFF4A90E2),
                  backgroundColor: const Color(0xFFE2E8F0),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 2000,
                );
              },
            ),

            const SizedBox(width: 25),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Academic\n'
                            'Progress ',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.trending_up_rounded,
                        color: Color(0xFF58CC02),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Excellent work! You\'re ahead of 78% of your classmates.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF718096),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress Indicators
                  Row(
                    children: [
                      _buildMiniProgress('Attendance', 0.85, const Color(0xFF4A90E2)),
                      const SizedBox(width: 16),
                      _buildMiniProgress('Assignments', 0.92, const Color(0xFF58CC02)),
                    ],
                  ),
                ],
              ),
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
        subtitle: 'Pending',
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
          return AnimatedBuilder(
            animation: _cardsAnimationController,
            builder: (context, child) {
              final interval = Interval(
                (index * 0.1).clamp(0.0, 1.0),
                ((index * 0.1) + 0.6).clamp(0.0, 1.0),
                curve: Curves.easeOutBack,
              );

              final scaleAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _cardsAnimationController,
                curve: interval,
              ));

              return Transform.scale(
                scale: scaleAnimation.value,
                child: _buildEnhancedFeatureCard(
                  context,
                  features[index],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedFeatureCard(BuildContext context, FeatureData feature) {
    return GestureDetector(
      onTap: () {
        // Add haptic feedback
        Navigator.pushNamed(context, feature.route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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

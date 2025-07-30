import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_strings.dart';
import '../constants/app_routes.dart';
import '../theme/app_theme.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _backgroundAnimationController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerOpacityAnimation;
  late Animation<Offset> _backgroundFloatAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Setup animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
    ));

    _headerSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeIn,
    ));

    _backgroundFloatAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations sequence
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _logoAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _headerAnimationController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _cardsAnimationController.forward();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Animated Logo Section
                  _buildAnimatedLogo(),



                  const SizedBox(height: 60),

                  // Animated Role Cards
                  Expanded(
                    child: _buildAnimatedRoleCards(context),
                  ),

                  // Footer
                  _buildFooter(context),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundFloatAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFF8F9FA),
                const Color(0xFFE3F2FD).withOpacity(0.3),
                const Color(0xFFF8F9FA),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Floating Circles
              Positioned(
                top: 100 + (_backgroundFloatAnimation.value.dy * 20),
                right: 50,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 200 + (_backgroundFloatAnimation.value.dy * -30),
                left: 30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF58CC02).withOpacity(0.08),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_logoScaleAnimation, _logoRotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Transform.rotate(
              angle: _logoRotationAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A90E2).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedRoleCards(BuildContext context) {
    final roles = [
      RoleData(
        title: AppStrings.student,
        description: AppStrings.studentDescription,
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.school_rounded,
        route: 'student',
        features: ['Attendance Tracking', 'Homework Management', 'Fee Payments', 'Study Materials'],
      ),
      RoleData(
        title: AppStrings.teacher,
        description: AppStrings.teacherDescription,
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        icon: Icons.assignment_rounded,
        route: 'teacher',
        features: ['Class Management', 'Student Progress', 'Assignment Creation', 'Analytics'],
      ),
    ];

    return Column(
      children: roles.asMap().entries.map((entry) {
        final index = entry.key;
        final role = entry.value;

        return AnimatedBuilder(
          animation: _cardsAnimationController,
          builder: (context, child) {
            final interval = Interval(
              index * 0.3,
              (index * 0.3) + 0.7,
              curve: Curves.easeOutBack,
            );

            final scaleAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _cardsAnimationController,
              curve: interval,
            ));

            final slideAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _cardsAnimationController,
              curve: interval,
            ));

            return Padding(
              padding: EdgeInsets.only(bottom: index == 0 ? 24 : 0),
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: SlideTransition(
                  position: slideAnimation,
                  child: _buildEnhancedRoleCard(context, role),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedRoleCard(BuildContext context, RoleData role) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.lightImpact();
            },
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.login,
              );
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: role.gradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: role.gradient.colors.first.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: role.gradient.colors.first.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Enhanced Icon Container
                        Hero(
                          tag: 'role_icon_${role.route}',
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              role.icon,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    role.title,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFF9500),
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                role.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Features Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: role.features.take(2).map((feature) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return AnimatedBuilder(
      animation: _cardsAnimationController,
      builder: (context, child) {
        final opacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _cardsAnimationController,
          curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
        ));

        return Opacity(
          opacity: opacityAnimation.value,
          child: Center(
            child: Column(
              children: [
                Text(
                  'Ready to transform your learning journey?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: Color(0xFF58CC02),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Secure & Private',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF58CC02),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RoleData {
  final String title;
  final String description;
  final LinearGradient gradient;
  final IconData icon;
  final String route;
  final List<String> features;

  const RoleData({
    required this.title,
    required this.description,
    required this.gradient,
    required this.icon,
    required this.route,
    required this.features,
  });
}

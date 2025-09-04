import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../constants/app_strings.dart';
import '../constants/app_routes.dart';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _textAnimationController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Floating animation controller
    _floatingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Text animation controller
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Setup animations
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
    ));

    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingAnimationController,
      curve: Curves.easeInOut,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mainAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 800));
    _textAnimationController.forward();

    // Navigate after animations complete
    Timer(const Duration(seconds: 3), () async {
      await _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('Uid') ?? '';
      final role = prefs.getString('Role') ?? '';
      final rememberMe = prefs.getBool('RememberMe') ?? false;
      final sessionTemporary = prefs.getBool('SessionTemporary') ?? false;

      debugPrint('=== SPLASH SESSION CHECK ===');
      debugPrint('Stored Uid: ' + (uid.isEmpty ? 'EMPTY' : 'PRESENT'));
      debugPrint('Stored Role: ' + (role.isEmpty ? 'EMPTY' : role));

      if (!mounted) return;

      if (uid.isEmpty || role.isEmpty) {
        debugPrint('No active session found. Navigating to login.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      // If Remember Me is off and session marked temporary, clear on app start
      if (!rememberMe && sessionTemporary) {
        debugPrint('Temporary session detected and Remember Me OFF. Clearing session.');
        await prefs.clear();
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      // Active session: route by role
      switch (role.toLowerCase()) {
        case 'admin':
          debugPrint('Active session for ADMIN. Navigating to admin dashboard.');
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;
        case 'teacher':
          debugPrint('Active session for TEACHER. Navigating to teacher dashboard.');
          Navigator.pushReplacementNamed(context, AppRoutes.teacherDashboard);
          break;
        case 'student':
          debugPrint('Active session for STUDENT. Navigating to student dashboard.');
          Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
          break;
        default:
          debugPrint('Unknown role. Defaulting to login.');
          Navigator.pushReplacementNamed(context, AppRoutes.login);
          break;
      }
    } catch (e) {
      debugPrint('Error during session check: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _floatingAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background with subtle gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFAFAFA),
                  Color(0xFFF5F7FA),
                  Color(0xFFE8F4FD),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Floating background elements
          _buildFloatingElements(),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section with glassmorphism effect
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _scaleAnimation,
                    _fadeAnimation,
                    _floatingAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: _buildLogoContainer(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App name and subtitle
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _slideAnimation,
                    _textFadeAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Column(
                          children: [
                            _buildAppTitle(),
                            const SizedBox(height: 8),
                            _buildAppSubtitle(),
                            const SizedBox(height: 32),
                            _buildFeatureTags(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textFadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textFadeAnimation.value,
                  child: _buildLoadingIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Floating circles
        Positioned(
          top: 120,
          right: 60,
          child: AnimatedBuilder(
            animation: _floatingAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _floatingAnimation.value * 0.5,
                  _floatingAnimation.value * 0.3,
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF58CC02).withValues(alpha:0.1),
                    border: Border.all(
                      color: const Color(0xFF58CC02).withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 200,
          left: 40,
          child: AnimatedBuilder(
            animation: _floatingAnimationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -_floatingAnimation.value * 0.3,
                  _floatingAnimation.value * 0.4,
                ),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4A90E2).withValues(alpha:0.08),
                    border: Border.all(
                      color: const Color(0xFF4A90E2).withValues(alpha:0.15),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogoContainer() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha:0.9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90E2).withValues(alpha:0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha:0.8),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha:0.2),
                  Colors.white.withValues(alpha:0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Center(
              child: Icon(
                Icons.school_rounded,
                size: 50,
                color: Color(0xFF4A90E2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color(0xFF4A90E2),
          Color(0xFF58CC02),
        ],
      ).createShader(bounds),
      child: const Text(
        'AES',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Widget _buildAppSubtitle() {
    return Text(
      AppStrings.splashSubtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
        letterSpacing: 0.5,
        height: 1.4,
      ),
    );
  }

  Widget _buildFeatureTags() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTag('Students', Icons.person_rounded, const Color(0xFF58CC02)),
        const SizedBox(width: 12),
        _buildTag('Teachers', Icons.school_rounded, const Color(0xFF4A90E2)),
        const SizedBox(width: 12),
        _buildTag('Admins', Icons.admin_panel_settings_rounded, const Color(0xFF8E44AD)),
      ],
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha:0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4A90E2),
                Color(0xFF58CC02),
              ],
            ),
          ),
          child: LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation(
              Colors.white.withValues(alpha:0.3),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading your experience...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B).withValues(alpha:0.8),
          ),
        ),
      ],
    );
  }
}

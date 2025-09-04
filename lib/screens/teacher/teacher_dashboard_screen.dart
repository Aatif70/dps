import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:AES/constants/app_routes.dart';
import 'package:AES/constants/app_strings.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  String _fullName = '';

  Future<void> _loadFullName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('FullName') ?? 'Teacher';
    });
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'T';

    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return 'T';
  }


  Future<void> _refreshPage() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    super.initState();
    _loadFullName();
    // No initial animations needed
  }

  @override
  void dispose() {
    // No animation controllers to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      floatingActionButton: _buildEnhancedFAB(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPage,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (no animation)
                _buildEnhancedHeader(context),

                const SizedBox(height: 12),

                // Feature Grid (no animation)
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
       Navigator.pushNamed(context, AppRoutes.teacherprofile);
     },
    child: Container(
   margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(25),
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
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    '${AppStrings.welcome}! 👨‍🏫',
    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    color: Colors.white.withValues(alpha:0.9),
    fontSize: 16,
    ),
    ),
    const SizedBox(height: 8),
      Text(
        _fullName.isEmpty ? 'Loading...' : _fullName,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),

      const SizedBox(height: 4),


    // Static Achievement Badge (no animation)

    ],
    ),
    ),
    // Enhanced Avatar with Status
    Stack(
    children: [
    Hero(
    tag: 'teacher_avatar',
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
      child: Text(
        _getInitials(_fullName),
        style: TextStyle(
          color: const Color(0xFF58CC02),
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
    color: const Color(0xFF4A90E2),
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
    )
   );

  }

  Widget _buildEnhancedScheduleItem(
      BuildContext context, {
        required String time,
        required String subject,
        required String classRoom,
        required String studentsCount,
        required IconData icon,
        required Color color,
        bool isNext = false,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? color.withValues(alpha:0.05) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: isNext ? Border.all(color: color.withValues(alpha:0.2)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha:0.1),
                  color.withValues(alpha:0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        subject,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isNext) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  classRoom,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF718096),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  studentsCount,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF718096),
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (isNext)
                Icon(
                  Icons.play_circle_filled_rounded,
                  color: color,
                  size: 16,
                ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedFeatureGrid(BuildContext context) {
    final features = [
      TeacherFeatureData(
        title: 'Attendance Hub',
        icon: Icons.dashboard_rounded,
        color: const  Color(0xFF58CC02),
        subtitle: 'Overview',
        route: AppRoutes.teacherAttendanceHub,
        description: 'View your attendance & manage classes',
      ),
      TeacherFeatureData(
        title: 'Mark Attendance',
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFF4A90E2),
        subtitle: 'Classes',
        route: AppRoutes.teacherAttendance,
        description: 'Mark & view class attendance',
      ),

      TeacherFeatureData(
        title: AppStrings.leave,
        icon: Icons.event_busy_rounded,
        color: const Color(0xFF8E44AD),
        subtitle: 'Requests',
        route: AppRoutes.teacherLeave,
        description: 'Manage leave requests',
      ),
      TeacherFeatureData(
        title: AppStrings.homework,
        icon: Icons.assignment_rounded,
        color: const Color(0xFF58CC02),
        subtitle: 'Active',
        route: AppRoutes.teacherHomework,
        description: 'Create & grade assignments',
      ),
      TeacherFeatureData(
        title: AppStrings.studyMaterial,
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFE74C3C),
        subtitle: 'Resources',
        route: AppRoutes.teacherStudyMaterial,
        description: 'Upload & share materials',
      ),
      TeacherFeatureData(
        title: AppStrings.allocatedSubjects,
        icon: Icons.school_rounded,
        color: const Color(0xFF2ECC71),
        subtitle: 'Subjects',
        route: AppRoutes.teacherAllocatedSubjects,
        description: 'View assigned subjects',
      ),
    ];

    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double aspectRatio = screenWidth < 360 ? 0.65 : 0.75;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: aspectRatio,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return _buildEnhancedFeatureCard(
            context,
            features[index],
          );
        },
      ),
    );
  }

  Widget _buildEnhancedFeatureCard(BuildContext context, TeacherFeatureData feature) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
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

              const SizedBox(height: 16),

              // Title
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),

              const SizedBox(height: 6),
              // Subtitle
              Text(
                feature.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF718096),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),
              // Description (adaptive lines to prevent overflow)
              LayoutBuilder(
                builder: (ctx, constraints) {
                  final bool compact = constraints.maxHeight < 150;
                  return Text(
                    feature.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }



  Widget _buildInsightCard(BuildContext context, {required String title, required String value, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: color.withValues(alpha:0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58CC02).withValues(alpha:0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => _buildEnhancedQuickActionsSheet(context),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildEnhancedQuickActionsSheet(BuildContext context) {
    final quickActions = [
      QuickActionData(
        icon: Icons.dashboard_rounded,
        label: 'Attendance Hub',
        color: const Color(0xFF4A90E2),
        route: AppRoutes.teacherAttendanceHub,
      ),
      QuickActionData(
        icon: Icons.calendar_today_rounded,
        label: 'Mark Attendance',
        color: const Color(0xFF4A90E2),
        route: AppRoutes.teacherAttendance,
      ),
      QuickActionData(
        icon: Icons.assignment_rounded,
        label: 'Create Assignment',
        color: const Color(0xFF58CC02),
        route: AppRoutes.teacherHomework,
      ),
      QuickActionData(
        icon: Icons.menu_book_rounded,
        label: 'Upload Study Material',
        color: const Color(0xFFE74C3C),
        route: AppRoutes.teacherStudyMaterial,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),

          const SizedBox(height: 24),

          ...quickActions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildEnhancedQuickActionButton(context, action),
          )).toList(),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEnhancedQuickActionButton(BuildContext context, QuickActionData action) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, action.route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: action.color.withValues(alpha:0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.color.withValues(alpha:0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    action.color.withValues(alpha:0.1),
                    action.color.withValues(alpha:0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                action.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: action.color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class TeacherFeatureData {
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;
  final String route;
  final String description;

  const TeacherFeatureData({
    required this.title,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.route,
    required this.description,
  });
}

class QuickActionData {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

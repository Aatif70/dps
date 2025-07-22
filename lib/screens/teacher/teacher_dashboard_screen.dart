import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  Future<void> _refreshPage() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    super.initState();
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
                const SizedBox(height: 25),
                // Today's Schedule (no animation)
                _buildEnhancedTodaySchedule(context),
                const SizedBox(height: 25),
                // Analytics Dashboard (keep animation inside graph only)
                _buildEnhancedAnalytics(context),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Teaching Hub',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
    return Container(
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
            color: const Color(0xFF58CC02).withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dr. Rajesh Kumar',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mathematics & Physics',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Static Achievement Badge (no animation)
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
                            Icons.stars_rounded,
                            color: Color(0xFFFF9500),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Top Educator ⭐',
                            style: TextStyle(
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
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Text(
                          'RK',
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
    );
  }

  Widget _buildEnhancedTodaySchedule(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Schedule',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF58CC02).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: const Color(0xFF58CC02),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.today,
                        style: TextStyle(
                          color: const Color(0xFF58CC02),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildEnhancedScheduleItem(
              context,
              time: '09:00 AM',
              subject: 'Mathematics',
              classRoom: 'Class 10-A',
              studentsCount: '32 students',
              icon: Icons.calculate_rounded,
              color: const Color(0xFF4A90E2),
              isNext: true,
            ),
            const SizedBox(height: 16),
            _buildEnhancedScheduleItem(
              context,
              time: '11:00 AM',
              subject: 'Physics',
              classRoom: 'Class 11-A',
              studentsCount: '28 students',
              icon: Icons.science_rounded,
              color: const Color(0xFF8E44AD),
            ),
            const SizedBox(height: 16),
            _buildEnhancedScheduleItem(
              context,
              time: '02:00 PM',
              subject: 'Mathematics',
              classRoom: 'Class 10-B',
              studentsCount: '30 students',
              icon: Icons.calculate_rounded,
              color: const Color(0xFF4A90E2),
            ),
          ],
        ),
      ),
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
        color: isNext ? color.withOpacity(0.05) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: isNext ? Border.all(color: color.withOpacity(0.2)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
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

  Widget _buildEnhancedAnalytics(BuildContext context) {
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
            // Progress Ring
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 0.87),
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
                          color: Color(0xFF58CC02),
                        ),
                      ),
                      const Text(
                        "Efficiency",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                  progressColor: const Color(0xFF58CC02),
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
                        ' Analytics',
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
                    'Great progress! Your students are performing excellently.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF718096),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mini Stats
                  Row(
                    children: [
                      _buildMiniStat('Classes', '5', const Color(0xFF58CC02)),
                      const SizedBox(width: 16),
                      _buildMiniStat('Students', '95', const Color(0xFF4A90E2)),
                      const SizedBox(width: 16),
                      _buildMiniStat('Pending', '23', const Color(0xFFFF9500)),
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
        title: AppStrings.attendance,
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFF4A90E2),
        value: '94%',
        subtitle: 'Average',
        route: AppRoutes.teacherAttendance,
        description: 'Mark & view class attendance',
      ),
      TeacherFeatureData(
        title: AppStrings.homework,
        icon: Icons.assignment_rounded,
        color: const Color(0xFF58CC02),
        value: '15',
        subtitle: 'Active',
        route: AppRoutes.teacherHomework,
        description: 'Create & grade assignments',
      ),
      TeacherFeatureData(
        title: AppStrings.leave,
        icon: Icons.event_busy_rounded,
        color: const Color(0xFF8E44AD),
        value: '8',
        subtitle: 'Requests',
        route: AppRoutes.teacherLeave,
        description: 'Manage leave requests',
      ),
      TeacherFeatureData(
        title: AppStrings.studyMaterial,
        icon: Icons.menu_book_rounded,
        color: const Color(0xFFE74C3C),
        value: '67',
        subtitle: 'Resources',
        route: AppRoutes.teacherStudyMaterial,
        description: 'Upload & share materials',
      ),
      TeacherFeatureData(
        title: AppStrings.allocatedSubjects,
        icon: Icons.school_rounded,
        color: const Color(0xFF2ECC71),
        value: '2',
        subtitle: 'Subjects',
        route: AppRoutes.teacherAllocatedSubjects,
        description: 'View assigned subjects',
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
              // Icon Container
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
            color: const Color(0xFF58CC02).withOpacity(0.3),
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
          color: action.color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: action.color.withOpacity(0.1),
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
                    action.color.withOpacity(0.1),
                    action.color.withOpacity(0.05),
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
  final String value;
  final String subtitle;
  final String route;
  final String description;

  const TeacherFeatureData({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
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

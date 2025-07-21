import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/screens/auth/login_screen.dart';
import 'package:dps/screens/role_selection_screen.dart';
import 'package:dps/screens/splash_screen.dart';
import 'package:dps/screens/student/student_dashboard_screen.dart';
import 'package:dps/screens/teacher/teacher_dashboard_screen.dart';
import 'package:dps/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.roleSelection: (context) => const RoleSelectionScreen(),
        AppRoutes.studentDashboard: (context) => const StudentDashboardScreen(),
        AppRoutes.teacherDashboard: (context) => const TeacherDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == AppRoutes.login) {
          final String role = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => LoginScreen(role: role),
          );
        }
        // Add other routes with arguments as needed
        
        return null;
      },
    );
  }
}

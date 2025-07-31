import 'package:dps/screens/teacher/allocated_subjects_screen.dart';
import 'package:dps/screens/teacher/homework_screen.dart';
import 'package:dps/screens/teacher/leave_screen.dart';
import 'package:dps/screens/teacher/study_material_screen.dart';
import 'package:dps/screens/teacher/teacher_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:dps/constants/app_routes.dart';
import 'package:dps/constants/app_strings.dart';
import 'package:dps/screens/auth/login_screen.dart';
import 'package:dps/screens/role_selection_screen.dart';
import 'package:dps/screens/splash_screen.dart';
import 'package:dps/screens/student/attendance_screen.dart';
import 'package:dps/screens/teacher/attendance_screen.dart';
import 'package:dps/screens/student/examination_screen.dart';
import 'package:dps/screens/student/fees_screen.dart';
import 'package:dps/screens/student/homework_screen.dart';
import 'package:dps/screens/student/leave_screen.dart';
import 'package:dps/screens/student/student_dashboard_screen.dart';
import 'package:dps/screens/student/student_profile_screen.dart';
import 'package:dps/screens/student/study_material_screen.dart';
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
        // Main routes
        AppRoutes.splash: (context) => const SplashScreen(),
        // AppRoutes.roleSelection: (context) => const RoleSelectionScreen(),
        
        // Student routes
        AppRoutes.studentDashboard: (context) => const StudentDashboardScreen(),
        AppRoutes.studentAttendance: (context) => const AttendanceScreen(),
        AppRoutes.studentFees: (context) => const FeesScreen(),
        AppRoutes.studentHomework: (context) => const HomeworkScreen(),
        AppRoutes.studentLeave: (context) => const LeaveScreen(),
        AppRoutes.studentStudyMaterial: (context) => const StudyMaterialScreen(),
        AppRoutes.studentExamination: (context) => const ExaminationScreen(),
        AppRoutes.studentProfile: (context) => const StudentProfileScreen(),
        
        // Teacher routes
        AppRoutes.teacherDashboard: (context) => const TeacherDashboardScreen(),
        AppRoutes.teacherAttendance: (context) => const TeacherAttendanceScreen(),
        AppRoutes.teacherHomework: (context) => const TeacherHomeworkScreen(),
        AppRoutes.teacherLeave: (context) => const TeacherLeaveScreen(),
        AppRoutes.teacherStudyMaterial: (context) => const TeacherStudyMaterialScreen(),
        AppRoutes.teacherAllocatedSubjects: (context) => const TeacherAllocatedSubjectsScreen(),
      AppRoutes.teacherprofile: (context) => const TeacherProfileScreen(),

      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == AppRoutes.login) {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          );
        }
        // Add other routes with arguments as needed
        
        return null;
      },
    );
  }
}

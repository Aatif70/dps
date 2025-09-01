import 'package:dps/screens/student/timetable_screen.dart';
import 'package:dps/screens/teacher/allocated_subjects_screen.dart';
import 'package:dps/screens/admin/admin_dashboard_screen.dart';
import 'package:dps/screens/admin/admin_students_screen.dart';
import 'package:dps/screens/admin/admin_fees_receipts_screen.dart';
import 'package:dps/screens/admin/admin_concession_receipts_screen.dart';
import 'package:dps/screens/admin/admin_payment_vouchers_screen.dart';
import 'package:dps/screens/admin/admin_fees_hub_screen.dart';
import 'package:dps/screens/admin/admin_student_details_screen.dart';
import 'package:dps/screens/admin/admin_classes_hub_screen.dart';
import 'package:dps/screens/admin/admin_class_masters_screen.dart';
import 'package:dps/screens/admin/admin_batches_screen.dart';
import 'package:dps/screens/admin/admin_divisions_screen.dart';
import 'package:dps/screens/admin/admin_employee_list_screen.dart';
import 'package:dps/screens/admin/admin_employees_hub_screen.dart';
import 'package:dps/screens/admin/admin_employee_attendance_hub_screen.dart';
import 'package:dps/screens/admin/admin_employee_attendance_list_screen.dart';
import 'package:dps/screens/admin/admin_add_employee_attendance_screen.dart';
import 'package:dps/screens/admin/admin_update_employee_attendance_screen.dart';
import 'package:dps/screens/admin/admin_employee_attendance_report_screen.dart';
import 'package:dps/screens/admin/admin_employee_details_screen.dart';
import 'package:dps/screens/admin/admin_attendance_hub_screen.dart';
import 'package:dps/screens/admin/admin_student_attendance_screen.dart';
import 'package:dps/screens/admin/admin_student_attendance_by_date_screen.dart';
import 'package:dps/screens/admin/admin_student_caste_screen.dart';
import 'package:dps/screens/admin/admin_student_income_screen.dart';
import 'package:dps/screens/admin/admin_student_bank_screen.dart';
import 'package:dps/screens/admin/admin_student_guardian_screen.dart';
import 'package:dps/screens/admin/admin_student_documents_screen.dart';
import 'package:dps/screens/admin/admin_student_fees_details_screen.dart';
import 'package:dps/screens/admin/admin_student_personal_screen.dart';
import 'package:dps/screens/admin/admin_student_previous_school_screen.dart';
import 'package:dps/screens/admin/admin_student_sms_details_screen.dart';
import 'package:dps/screens/admin/admin_timetable_screen.dart';
import 'package:dps/screens/admin/admin_students_hub_screen.dart';
import 'package:dps/screens/admin/admin_registered_students_list_screen.dart';
import 'package:dps/screens/admin/admin_registered_student_details_screen.dart';
import 'package:dps/screens/admin/admin_admission_allotment_screen.dart';
import 'package:dps/screens/admin/admin_admitted_students_list_screen.dart';
import 'package:dps/screens/admin/admin_exams_list_screen.dart';
import 'package:dps/screens/admin/admin_exam_marks_screen.dart';
import 'package:dps/screens/admin/admin_homework_list_screen.dart';
import 'package:dps/screens/admin/admin_fees_student_search_screen.dart';
import 'package:dps/screens/admin/admin_fees_student_details_screen.dart';
import 'package:dps/screens/admin/admin_fees_class_summary_screen.dart';
import 'package:dps/screens/admin/admin_class_create_screen.dart';
import 'package:dps/screens/admin/admin_class_edit_screen.dart';
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
import 'package:dps/screens/student/marks_screen.dart';
import 'package:dps/screens/student/student_results_hub_screen.dart';
import 'package:dps/screens/student/student_exam_results_screen.dart';
import 'package:dps/screens/teacher/teacher_dashboard_screen.dart';
import 'package:dps/services/student_exam_service.dart';
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
        AppRoutes.studentmarks: (context) => const StudentResultsHubScreen(),
        AppRoutes.studentExamResults: (context) {
          final exam = ModalRoute.of(context)!.settings.arguments as StudentExamItem;
          return StudentExamResultsScreen(exam: exam);
        },
        AppRoutes.studentExamination: (context) => const ExaminationScreen(),
        AppRoutes.studentProfile: (context) => const StudentProfileScreen(),
        AppRoutes.studenttimetable: (context) => const TimetableScreen(),

        // Teacher routes
        AppRoutes.teacherDashboard: (context) => const TeacherDashboardScreen(),
        AppRoutes.teacherAttendance: (context) => const TeacherAttendanceScreen(),
        AppRoutes.teacherHomework: (context) => const TeacherHomeworkScreen(),
        AppRoutes.teacherLeave: (context) => const TeacherLeaveScreen(),
        AppRoutes.teacherStudyMaterial: (context) => const TeacherStudyMaterialScreen(),
        AppRoutes.teacherAllocatedSubjects: (context) => const TeacherAllocatedSubjectsScreen(),
        AppRoutes.teacherprofile: (context) => const TeacherProfileScreen(),

        // Admin routes
        AppRoutes.adminDashboard: (context) => const AdminDashboardScreen(),
        AppRoutes.adminStudents: (context) => const AdminStudentsScreen(),
        AppRoutes.adminStudentsHub: (context) => const AdminStudentsHubScreen(),
        AppRoutes.adminFeesHub: (context) => const AdminFeesHubScreen(),
        AppRoutes.adminStudentDetails: (context) => const AdminStudentDetailsScreen(),
        AppRoutes.adminClassesHub: (context) => const AdminClassesHubScreen(),
        AppRoutes.adminClassMasters: (context) => const AdminClassMastersScreen(),
        AppRoutes.adminAddClass: (context) => const AdminClassCreateScreen(),
        AppRoutes.adminEditClass: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AdminClassEditScreen(
            classMasterId: args['ClassMasterId'] as int,
            className: args['ClassName'] as String,
            rollNoPrefix: args['RollNoPreFix'] as String,
            courseYear: args['CourseYear'] as int,
          );
        },
        AppRoutes.adminBatches: (context) => const AdminBatchesScreen(),
        AppRoutes.adminDivisions: (context) => const AdminDivisionsScreen(),
        AppRoutes.adminStudentCaste: (context) => const AdminStudentCasteScreen(),
        AppRoutes.adminStudentIncome: (context) => const AdminStudentIncomeScreen(),
        AppRoutes.adminStudentBank: (context) => const AdminStudentBankScreen(),
        AppRoutes.adminStudentGuardian: (context) => const AdminStudentGuardianScreen(),
        AppRoutes.adminStudentDocuments: (context) => const AdminStudentDocumentsScreen(),
        AppRoutes.adminStudentFeesDetails: (context) => const AdminStudentFeesDetailsScreen(),
        AppRoutes.adminStudentPersonal: (context) => const AdminStudentPersonalScreen(),
        AppRoutes.adminStudentPreviousSchool: (context) => const AdminStudentPreviousSchoolScreen(),
        AppRoutes.adminStudentSmsDetails: (context) => const AdminStudentSmsDetailsScreen(),
        AppRoutes.adminFeesReceipts: (context) => const AdminFeesReceiptsScreen(),
        AppRoutes.adminConcessionReceipts: (context) => const AdminConcessionReceiptsScreen(),
        AppRoutes.adminPaymentVouchers: (context) => const AdminPaymentVouchersScreen(),
        AppRoutes.adminFeesStudentSearch: (context) => const AdminFeesStudentSearchScreen(),
        AppRoutes.adminFeesStudentDetails: (context) => const AdminFeesStudentDetailsScreen(),
        AppRoutes.adminFeesClassSummary: (context) => const AdminFeesClassSummaryScreen(),
        AppRoutes.adminTimetable: (context) => const AdminTimetableScreen(),
        AppRoutes.adminEmployees: (context) => const AdminEmployeeListScreen(),
        AppRoutes.adminEmployeesHub: (context) => const AdminEmployeesHubScreen(),
        AppRoutes.adminEmployeeAttendanceHub: (context) => const AdminEmployeeAttendanceHubScreen(),
        AppRoutes.adminEmployeeAttendanceList: (context) => const AdminEmployeeAttendanceListScreen(),
        AppRoutes.adminAddEmployeeAttendance: (context) => const AdminAddEmployeeAttendanceScreen(),
        AppRoutes.adminUpdateEmployeeAttendance: (context) => const AdminUpdateEmployeeAttendanceScreen(),
        AppRoutes.adminEmployeeAttendanceReport: (context) => const AdminEmployeeAttendanceReportScreen(),
        AppRoutes.adminEmployeeDetails: (context) => const AdminEmployeeDetailsScreen(),
        AppRoutes.adminAttendanceHub: (context) => const AdminAttendanceHubScreen(),
        AppRoutes.adminStudentAttendance: (context) => const AdminStudentAttendanceScreen(),
        AppRoutes.adminStudentAttendanceByDate: (context) => const AdminStudentAttendanceByDateScreen(),

        // Admissions
        AppRoutes.adminRegisteredStudents: (context) => const AdminRegisteredStudentsListScreen(),
        AppRoutes.adminRegisteredStudentDetails: (context) => const AdminRegisteredStudentDetailsScreen(),
        AppRoutes.adminAdmissionAllotment: (context) => const AdminAdmissionAllotmentScreen(),
        AppRoutes.adminAdmittedStudents: (context) => const AdminAdmittedStudentsListScreen(),
        AppRoutes.adminExams: (context) => const AdminExamsListScreen(),
        AppRoutes.adminExamMarks: (context) => const AdminExamMarksScreen(),
        AppRoutes.adminHomeworkList: (context) => const AdminHomeworkListScreen(),

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

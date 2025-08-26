class AppRoutes {
  // Main Flow
  static const String splash = '/splash';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  
  // Student Routes
  static const String studentDashboard = '/student/dashboard';
  static const String studentAttendance = '/student/attendance';
  static const String studentFees = '/student/fees';
  static const String studentHomework = '/student/homework';
  static const String studentLeave = '/student/leave';
  static const String studentStudyMaterial = '/student/study-material';
  static const String studentExamination = '/student/examination';
  static const String studentProfile = '/student/profile';
  static const String studenttimetable = '/student/timetable';
  static const String studentmarks = '/student/marks';
  
  // Teacher Routes
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherHomework = '/teacher/homework';
  static const String teacherLeave = '/teacher/leave';
  static const String teacherStudyMaterial = '/teacher/study-material';
  static const String teacherAllocatedSubjects = '/teacher/allocated-subjects';
  static const String teacherprofile = '/teacher/profile';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStudents = '/admin/students';
  static const String adminStudentsHub = '/admin/students/hub';
  static const String adminFeesHub = '/admin/fees';
  static const String adminFeesReceipts = '/admin/fees/receipts';
  static const String adminConcessionReceipts = '/admin/fees/concession-receipts';
  static const String adminPaymentVouchers = '/admin/fees/payment-vouchers';
  static const String adminFeesStudentSearch = '/admin/fees/search-student';
  static const String adminFeesStudentDetails = '/admin/fees/student-details';
  static const String adminFeesClassSummary = '/admin/fees/class-summary';
  static const String adminStudentDetails = '/admin/students/details';
  static const String adminStudentCaste = '/admin/students/caste';
  static const String adminStudentIncome = '/admin/students/income';
  static const String adminStudentBank = '/admin/students/bank';
  static const String adminStudentGuardian = '/admin/students/guardian';
  static const String adminStudentDocuments = '/admin/students/documents';
  static const String adminStudentPersonal = '/admin/students/personal';
  static const String adminStudentPreviousSchool = '/admin/students/previous-school';
  static const String adminStudentSmsDetails = '/admin/students/sms-details';
  static const String adminStudentFeesDetails = '/admin/students/fees-details';
  static const String adminClassesHub = '/admin/classes';
  static const String adminClassMasters = '/admin/classes/class-masters';
  static const String adminBatches = '/admin/classes/batches';
  static const String adminDivisions = '/admin/classes/divisions';
  static const String adminTimetable = '/admin/timetable';
  // Attendance
  static const String adminAttendanceHub = '/admin/attendance';
  static const String adminStudentAttendance = '/admin/attendance/student';
  static const String adminStudentAttendanceByDate = '/admin/attendance/student-by-date';
  // Employees
  static const String adminEmployees = '/admin/employees/list';
  static const String adminEmployeesHub = '/admin/employees';
  static const String adminEmployeeAttendanceHub = '/admin/employees/attendance';
  static const String adminEmployeeAttendanceList = '/admin/employees/attendance/list';
  static const String adminAddEmployeeAttendance = '/admin/employees/attendance/add';
  static const String adminUpdateEmployeeAttendance = '/admin/employees/attendance/update';
  static const String adminEmployeeAttendanceReport = '/admin/employees/attendance/report';
  static const String adminEmployeeDetails = '/admin/employees/details';

} 
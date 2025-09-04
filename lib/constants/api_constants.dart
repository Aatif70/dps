class ApiConstants {
  static const String baseUrl = 'https://as.mokshasolutions.com/';
  // static const String baseUrl = 'http://192.168.1.15:8025';
  static const String login = '/api/User/Login';

  // ------------- STUDENT -------------
  static const String eventCalendar = '/api/User/EventCalendar';
  static const String paidfees = '/api/User/PaidFees';
  static const String remainingFees = '/api/User/RemainingFees';
  static const String studentLeave = '/api/User/StudentLeave';
  static const String addLeaveMobile = '/api/User/AddLeaveMobile';
  static const String studentHomework = '/api/User/StudentHomeWork';
  static const String studentStudyMaterial = '/api/OnlineExam/StudentStudyMaterial';
  static const String studentAttendance = '/api/User/StudentAttendance';
  static const String studentTimetable = '/api/User/StdTimeTable';
  static const String searchStudentDetail = '/api/user/SearchStudentDetail';
  static const String studentDocuments = '/api/user/StudentDocuments';
  static const String studentFeesDetails = '/api/User/FeesDetails';
  static const String studentExamList = '/api/OnlineExam/StudentExam';
  static const String studentExamMarks = '/api/User/StudentExamMarks';
  static const String searchStudent = '/api/User/SearchStudent';
  static const String studentPersonalDetail = '/api/user/StudentPersonalDetail';
  static const String guardianDetail = '/api/user/GuardianDetail';
  static const String previousSchool = '/api/user/PreviousSchool';
  static const String bankDetail = '/api/user/BankDetail';
  static const String incomeDetail = '/api/user/IncomeDetail';
  static const String casteReligionDetail = '/api/user/CasteReligionDetail';



  // ------------- TEACHER HOMEWORK -------------
  static const String homeworkList = '/api/user/HomeworkList';
  static const String homeworkAdd = '/api/user/HomeworkAdd';
  static const String courseList = '/api/User/CourseList';
  static const String batches = '/api/User/Batches';
  static const String divisionList = '/api/user/DivisionList';
  static const String subjectList = '/api/user/SubjectList';

// ------------- TEACHER ALLOCATED SUBJECTS -------------
  static const String teacherAllocatedSubject = '/api/user/TeacherAllocatedSubject';

// ------------- TEACHER LEAVE -------------
  static const String leaveList = '/api/user/LeaveList';
  static const String approveOrRejectLeave = '/api/User/ApproveOrRejectLeave';

  // ------------- TEACHER STUDY MATERIAL -------------
  static const String teacherStudyMaterial = '/api/OnlineExam/TeacherStudyMaterial';
  static const String getClassByEmpId = '/api/User/GetClassByEmpId';
  static const String batchByEmpId = '/api/User/BatchByEmpId';
  static const String subByEmpId = '/api/User/SubByEmpId';
  static const String studyMaterialAdd = '/api/OnlineExam/StudyMaterialAdd';

  // ------------- TEACHER ATTENDANCE -------------
  static const String attendanceEmpIndex = '/api/user/AttendanceEmpIndex';
  static const String studentDetails = '/api/user/StudentDetails';
  static const String employeeAttendance = '/api/Employee/EmployeeAttendance';



  // ------------- ADMIN  -------------
  static const String dashboardcounter = '/api/user/DashboardCounter';
  static const String last10feesreceipt = '/api/user/Last10FeesReceipt';
  static const String last10concessionfeesreceipt = '/api/user/Last10ConcessionFeesReceipt';
  static const String last10paymentvouchers = '/api/user/Last10PaymentVouchers';
  static const String employeesList = '/api/User/EmployeesList';
  static const String employeeAttendanceList = '/api/User/EmployeeAttendanceList';
  static const String addEmpAttendance = '/api/User/AddEmpAttendance';
  static const String updateEmpAttendance = '/api/User/UpdateEmpAttendance';
  static const String empAttendanceReport = '/api/User/EmpAttendanceReport';
  static const String employeeCount = '/api/Employee/EmpCount';
  static const String studentCount = '/api/Students/StudentCount';
  static const String classWiseFeeSummary = '/api/Fees/classwisefeesummary';

  // ------------- ADMIN ADMISSIONS -------------
  static const String registeredStudents = '/api/Register/GetRegisteredStd';
  static const String divisionsByClass = '/api/Students/DivByClass';
  static const String classwiseSubjects = '/api/Register/GetclasswiseSubject';
  static const String practicalBatchesByDivision = '/api/Register/GetPracticalBatchCP';
  static const String createAdmission = '/api/Register/CreateAdmission';
  static const String admittedStudentsByClass = '/api/Register/GetAdmittedStudent';

  // ------------- ADMIN INTERNAL EXAMS -------------
  static const String internalExams = '/api/InternalExam/GetExams';
  static const String internalExamMarks = '/api/InternalExam/ExamMarks';

  // ------------- ADMIN CLASSES -------------
  static const String classMasters = '/api/User/ClassMasters';
  static const String adminBatches = '/api/User/Batches';
  static const String adminDivisions = '/api/User/Divisions';
  static const String createClass = '/api/Master/CreateClass';
  static const String updateClass = '/api/Master/UpdateClass';

  // ------------- ADMIN HOMEWORK -------------
  static const String adminHomeworkList = '/api/HomeWork/HomeWorkList';
  // Base to access homework files (resolved relative to baseUrl)
  static const String homeworkFilesBase = baseUrl + '/StudyMaterial/HomeWork';


}

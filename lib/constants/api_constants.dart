class ApiConstants {
  // static const String baseUrl = 'https://school.gurumishrihmc.edu.in/api/User';
  static const String baseUrl = 'http://192.168.1.24:8025';
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

  // ------------- TEACHER HOMEWORK -------------
  static const String homeworkList = '/api/user/HomeworkList';
  static const String homeworkAdd = '/api/user/HomeworkAdd';
  static const String courseList = '/api/User/CourseList';
  static const String batches = '/api/User/Batches';
  static const String divisionList = '/api/user/DivisionList';
  static const String subjectList = '/api/user/SubjectList';


}

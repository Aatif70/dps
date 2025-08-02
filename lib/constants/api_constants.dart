class ApiConstants {
  // static const String baseUrl = 'https://school.gurumishrihmc.edu.in/api/User';
  static const String baseUrl = 'http://192.168.1.24:8025';
  static const String login = '/api/User/Login';

  // ------------- STUDENT -------------

  // EVENT CALENDAR
  static const String eventCalendar = '/api/User/EventCalendar';

  // FEE
  static const String paidfees = '/api/User/PaidFees';
  static const String remainingFees = '/api/User/RemainingFees';

  // LEAVE
  static const String studentLeave = '/api/User/StudentLeave';
  static const String addLeaveMobile = '/api/User/AddLeaveMobile';

  // HOMEWORK
  static const String studentHomework = '/api/User/StudentHomeWork';

  // Study Material Management
  static const String studentStudyMaterial = '/api/OnlineExam/StudentStudyMaterial';

  // Student Attendance
  static const String studentAttendance = '/api/User/StudentAttendance';

  // Student Timetable
  static const String studentTimetable = '/api/User/StdTimeTable';

  static const String searchStudentDetail = '/api/user/SearchStudentDetail';
  static const String studentDocuments = '/api/user/StudentDocuments';
}

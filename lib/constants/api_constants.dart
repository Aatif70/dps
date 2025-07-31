class ApiConstants {
  // static const String baseUrl = 'https://school.gurumishrihmc.edu.in/api/User';
  static const String baseUrl = 'http://192.168.1.14:8025';
  static const String login = '/api/User/Login';

  // ------------- STUDENT -------------
  // FEE
  static const String paidfees = '/api/User/PaidFees';
  static const String remainingFees = '/api/User/RemainingFees';

  // LEAVE
  static const String studentLeave = '/api/User/StudentLeave';
  static const String addLeaveMobile = '/api/User/AddLeaveMobile';
}

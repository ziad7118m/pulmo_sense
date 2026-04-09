class Endpoints {
  // Diagnosis
  static const String analyzeRecord = '/api/diagnosis/record';
  static const String analyzeAudio = '/api/diagnosis/audio';
  static const String analyzeXray = '/api/diagnosis/xray';
  static const String diagnoses = '/api/diagnoses';
  static const String diagnosesLatest = '/api/diagnoses/latest';

  // Auth
  static const String login = '/api/Authentication/login';
  static const String patientRegister = '/api/Authentication/register/patient';
  static const String doctorRegister = '/api/Authentication/register/doctor';
  static const String sendOtp = '/api/Authentication/send-otp';
  static const String verifyOtp = '/api/Authentication/verify-otp';
  static const String refresh = '/api/Authentication/refresh-token';
  static const String logout = '/api/Authentication/logout';
  static const String me = '/api/Authentication/me';
  static const String forgotPassword = '/api/Authentication/forgot-password';
  static const String resetPassword = '/api/Authentication/reset-password';

  static const String verifyResetCode = verifyOtp;

  // Admin users
  static const String allUsers = '/api/Admin/all-users';
  static const String pendingUsers = '/api/Admin/pending-users';
  static String approveUser(String id) => '/api/Admin/approve/$id';
  static String rejectUser(String id) => '/api/Admin/reject/$id';
  static String disableUser(String id) => '/api/Admin/disable/$id';
  static String enableUser(String id) => '/api/Admin/enable/$id';
  static String deleteUser(String id) => '/api/Admin/delete/$id';
  static String restoreUser(String id) => '/api/Admin/restore/$id';

  // Profiles
  static const String myProfile = '/api/users/me/profile';
  static const String userProfile = '/api/users';
  static const String medicalProfiles = '/api/medical-profiles';

  // Posts / articles
  static const String articles = '/api/Posts';
  static const String articleMine = '/api/Posts';
  static const String articleFavourites = '/api/Favorite';
  static const String articleSaved = '/api/Favorite';

  // Doctor access / QR
  static const String doctorPatientResolve = '/api/doctors/patient-access/resolve';
  static const String qrResolve = '/api/qr/resolve';
}

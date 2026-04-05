class Endpoints {
  // Diagnosis
  static const String analyzeRecord = '/api/diagnosis/record';
  static const String analyzeAudio = '/api/diagnosis/audio';
  static const String analyzeXray = '/api/diagnosis/xray';
  static const String diagnoses = '/api/diagnoses';
  static const String diagnosesLatest = '/api/diagnoses/latest';

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String verifyResetCode = '/api/auth/verify-reset-code';
  static const String resetPassword = '/api/auth/reset-password';

  // Admin users
  static const String adminUsers = '/api/admin/users';
  static String approveUser(String id) => '/api/admin/users/$id/approve';
  static String rejectUser(String id) => '/api/admin/users/$id/reject';
  static String disableUser(String id) => '/api/admin/users/$id/disable';
  static String enableUser(String id) => '/api/admin/users/$id/enable';
  static String deleteUser(String id) => '/api/admin/users/$id';

  // Profiles
  static const String myProfile = '/api/users/me/profile';
  static const String userProfile = '/api/users';
  static const String medicalProfiles = '/api/medical-profiles';

  // Articles
  static const String articles = '/api/articles';
  static const String articleMine = '/api/articles/mine';
  static const String articleFavourites = '/api/articles/favourites';
  static const String articleSaved = '/api/articles/saved';

  // Doctor access / QR
  static const String doctorPatientResolve = '/api/doctors/patient-access/resolve';
  static const String qrResolve = '/api/qr/resolve';
}

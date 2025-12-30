import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Android
  static String get androidApiKey => dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? 'YOUR_ANDROID_API_KEY';
  static String get androidAppId => dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '1:818518045990:android:8cf94322a372283fdabde7';
  static String get messagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? 'YOUR_MESSAGING_SENDER_ID';
  static String get projectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? 'YOUR_PROJECT_ID';
  static String get storageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'YOUR_PROJECT_ID.appspot.com';

  // iOS
  static String get iosApiKey => dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'YOUR_IOS_API_KEY';
  static String get iosAppId => dotenv.env['FIREBASE_IOS_APP_ID'] ?? 'YOUR_IOS_APP_ID';
  static String get iosBundleId => dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? 'com.example.busTracker';

  // Windows
  static String get windowsApiKey => dotenv.env['FIREBASE_WINDOWS_API_KEY'] ?? 'YOUR_WINDOWS_API_KEY';
  static String get windowsAppId => dotenv.env['FIREBASE_WINDOWS_APP_ID'] ?? 'YOUR_WINDOWS_APP_ID';

  // Linux
  static String get linuxApiKey => dotenv.env['FIREBASE_LINUX_API_KEY'] ?? 'YOUR_LINUX_API_KEY';
  static String get linuxAppId => dotenv.env['FIREBASE_LINUX_APP_ID'] ?? 'YOUR_LINUX_APP_ID';

  // macOS
  static String get macosApiKey => dotenv.env['FIREBASE_MACOS_API_KEY'] ?? 'YOUR_MACOS_API_KEY';
  static String get macosAppId => dotenv.env['FIREBASE_MACOS_APP_ID'] ?? 'YOUR_MACOS_APP_ID';

  // Demo/Test Settings
  static String get demoBusNumber => dotenv.env['DEMO_BUS_NUMBER'] ?? '154';
  static String get demoStudentEmail => dotenv.env['DEMO_STUDENT_EMAIL'] ?? 'student@example.com';
  static String get demoAdminEmail => dotenv.env['DEMO_ADMIN_EMAIL'] ?? 'admin@example.com';

  // App Settings
  static String get appName => dotenv.env['APP_NAME'] ?? 'Bus Tracker';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
}

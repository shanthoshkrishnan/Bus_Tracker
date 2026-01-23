# 🚌 LO BUS - Smart Bus Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A comprehensive real-time bus tracking and management solution built with Flutter and Firebase, enabling students to track buses, drivers to manage routes, and administrators to oversee the entire fleet.

---

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Firebase Setup](#firebase-setup)
- [Google Maps Setup](#google-maps-setup)
- [User Roles & Permissions](#user-roles--permissions)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## ✨ Features

### For Students 🎓
- 📍 **Real-time Bus Tracking** - Track your assigned bus on interactive Google Maps with live GPS updates
- 🔔 **Smart Notifications** - Get notified when your bus is approaching your stop
- 🗺️ **Route Visualization** - View complete bus routes with all stops and timings
- 👤 **Profile Management** - Manage your personal details, home location, and bus assignments
- 🔍 **Search Functionality** - Quickly find buses, routes, and driver information
- 📊 **Bus Status** - Real-time bus capacity, delays, and estimated arrival times (ETA)

### For Drivers 🚗
- 📲 **Automatic Location Broadcasting** - Your GPS location updates every 5-10 seconds automatically
- 👥 **Passenger Management** - View list of assigned students and their boarding/drop-off points
- 🗓️ **Route Details** - Access complete route information with all stops and timings
- 🔄 **Status Updates** - Update bus status (departed, in-transit, arrived, delayed) with one tap
- 📞 **Quick Contact** - Direct access to admin and student contact information

### For Administrators 👨‍💼
- 🚌 **Bus Fleet Management** - Add, edit, remove buses; manage capacity and maintenance schedules
- 👨‍✈️ **Driver Management** - Manage driver profiles, assignments, and performance tracking
- 🗺️ **Route Management** - Create and update routes with GPS coordinates and estimated timings
- 👨‍🎓 **Student Assignments** - Assign students to specific buses and routes efficiently
- 📊 **Analytics Dashboard** - Monitor fleet performance, usage statistics, and system health
- 🔐 **Access Control** - Role-based permissions and comprehensive security management

---

## 🛠 Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | Flutter 3.8.1+ (Dart 3.0+) |
| **UI** | Material Design 3, Custom widgets |
| **Authentication** | Firebase Authentication (Email/Password) |
| **Database** | Cloud Firestore (User data, buses, drivers)<br/>Firebase Realtime Database (Live location tracking) |
| **Notifications** | Firebase Cloud Messaging (FCM) |
| **Maps** | Google Maps Flutter, Geolocator |
| **State Management** | Provider pattern (Built-in) |
| **Backend Functions** | Firebase Cloud Functions (Node.js) |

---

## 📋 Prerequisites

Before starting, ensure you have:

1. **Flutter SDK** (3.8.1 or higher)
   ```bash
   flutter --version
   ```
   Download: https://flutter.dev/docs/get-started/install

2. **Android Studio** or **VS Code** with Flutter extensions

3. **Firebase CLI** (for deployment)
   ```bash
   npm install -g firebase-tools
   ```

4. **Google Cloud Account** (for Google Maps API - free tier available)

5. **Firebase Project** (free Spark plan works for development)

6. **Node.js** 14+ (for Firebase Functions)

7. **Git** for version control

---

## 🚀 Quick Start

Get the app running in 5 minutes:

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/bus_tracker.git
cd bus_tracker

# 2. Install dependencies
flutter pub get

# 3. Create .env file (see Configuration section)
echo "GOOGLE_MAPS_API_KEY=your_api_key_here" > .env

# 4. Run on connected device or emulator
flutter run
```

**First-time setup?** Continue reading for detailed configuration.

---

## 🔧 Installation

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/bus_tracker.git
cd bus_tracker
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

This installs all required packages from `pubspec.yaml`:
- `firebase_core` (^3.15.2) - Firebase initialization
- `firebase_auth` (^5.3.2) - User authentication
- `cloud_firestore` (^5.6.0) - Database for user/bus data
- `firebase_database` (^11.3.10) - Real-time location tracking
- `google_maps_flutter` (^2.5.0) - Map integration
- `geolocator` (^11.0.0) - GPS location services
- `intl` (^0.20.0) - Date/time formatting
- `flutter_dotenv` - Environment variable management

### Step 3: Verify Setup

```bash
flutter doctor
```

Ensure all checks pass (✓). Fix any issues before proceeding:
- ✓ Flutter installed
- ✓ Android toolchain / Xcode (for iOS)
- ✓ Connected device or emulator
- ✓ VS Code or Android Studio with Flutter plugin

---

## ⚙️ Configuration

### 1. Environment Variables

Create `.env` file in project root:

```env
# Google Maps API Key (required)
GOOGLE_MAPS_API_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# Firebase Project ID (optional - already in firebase_options.dart)
FIREBASE_PROJECT_ID=bus-tracker-af190
```

**Important:** The `.env` file is already in `.gitignore` - never commit it to version control!

### 2. Android Configuration

**Edit `android/app/src/main/AndroidManifest.xml`:**

```xml
<manifest>
    <application>
        <!-- Add Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
        
        <!-- Rest of application config -->
    </application>
    
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
</manifest>
```

### 3. iOS Configuration (if building for iOS)

**Edit `ios/Runner/AppDelegate.swift`:**

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Edit `ios/Runner/Info.plist`:**

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby buses</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need background location for real-time tracking</string>
```

### 4. Windows Developer Mode (Windows only)

Flutter requires Developer Mode on Windows for symlink support:

```powershell
# Open Developer Settings
start ms-settings:developers
```

Toggle on **"Developer Mode"** → Click "Yes" on confirmation dialog.

---

## 🏃 Running the App

### Run on Emulator/Device

```bash
# List all connected devices
flutter devices

# Run on default device
flutter run

# Run on specific device
flutter run -d <device_id>

# Run with hot reload (development)
flutter run --debug

# Run in release mode (production)
flutter run --release
```

### Platform-Specific Commands

```bash
# Android
flutter run -d android

# iOS (Mac only)
flutter run -d ios

# Chrome (web)
flutter run -d chrome

# Windows
flutter run -d windows
```

### Build Release Binaries

```bash
# Android APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (for Play Store)
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# iOS (Mac only)
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode

# Windows
flutter build windows --release
```

---

## 📁 Project Structure

```
bus_tracker/
├── lib/
│   ├── config/
│   │   └── env_config.dart           # Environment configuration
│   │
│   ├── models/                        # Data models
│   │   ├── bus_model.dart             # Bus entity model
│   │   └── location_model.dart        # Location tracking models
│   │       ├── BusLocation            # Real-time bus location
│   │       ├── DriverLocation         # Driver GPS tracking
│   │       ├── BusRoute               # Route with stops
│   │       ├── StudentBusAssignment   # Student-bus mapping
│   │       └── RouteTable             # Route management
│   │
│   ├── services/                      # Business logic layer
│   │   ├── firebase_service.dart      # Firebase CRUD operations
│   │   ├── location_service.dart      # GPS & location handling
│   │   ├── location_tracking_service.dart  # Real-time tracking
│   │   ├── driver_sync_service.dart   # Driver data synchronization
│   │   └── bus_setup_service.dart     # Bus initialization
│   │
│   ├── pages/                         # UI screens
│   │   ├── login_page.dart            # User authentication
│   │   ├── register_page.dart         # New user registration
│   │   ├── forgot_password_page.dart  # Password reset
│   │   ├── home_page.dart             # Main bus tracking map
│   │   ├── student_page.dart          # Student dashboard
│   │   ├── driver_page.dart           # Driver control panel
│   │   ├── admin_page.dart            # Admin dashboard
│   │   ├── profile_page.dart          # User profile management
│   │   ├── bus_management_page.dart   # Bus CRUD operations
│   │   ├── driver_management_page.dart # Driver management
│   │   ├── route_management_page.dart # Route creation/editing
│   │   └── bus_seat_selection_page.dart # Seat booking
│   │
│   ├── widgets/                       # Reusable components
│   │   ├── bus_card.dart              # Bus list item widget
│   │   └── bus_details_popup.dart     # Bus info modal
│   │
│   ├── firebase_options.dart          # Auto-generated Firebase config
│   └── main.dart                      # App entry point
│
├── functions/                         # Firebase Cloud Functions
│   ├── index.js                       # Functions entry point
│   └── sync-drivers.js                # Driver sync function
│
├── android/                           # Android-specific files
├── ios/                               # iOS-specific files
├── windows/                           # Windows-specific files
├── linux/                             # Linux-specific files
├── macos/                             # macOS-specific files
├── web/                               # Web-specific files
│
├── assets/                            # Static resources
│   └── images/                        # Image files
│
├── .env                               # Environment variables (create this)
├── .gitignore                         # Git ignore rules
├── firebase.json                      # Firebase config
├── firestore.rules                    # Firestore security rules
├── firestore.indexes.json             # Firestore indexes
├── pubspec.yaml                       # Flutter dependencies
├── README.md                          # This file
├── README_FRONTEND.md                 # Frontend documentation
└── README_BACKEND.md                  # Backend documentation
```

---

## 🔥 Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"**
3. Enter project name: `bus-tracker` (or your choice)
4. Disable Google Analytics (optional for development)
5. Click **"Create project"**

### 2. Register Android App

1. In Firebase project, click **"Add app"** → **Android** icon
2. Enter Android package name: `com.example.bus_tracker`
   - Find in `android/app/build.gradle` → `applicationId`
3. Click **"Register app"**
4. Download `google-services.json`
5. Place file in `android/app/google-services.json`
6. Click **"Next"** → **"Continue to console"**

### 3. Register iOS App (Optional)

1. Click **"Add app"** → **iOS** icon
2. Enter iOS bundle ID from `ios/Runner/Info.plist`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/GoogleService-Info.plist`

### 4. Enable Firebase Authentication

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable **"Email/Password"** provider
5. Click **"Save"**

### 5. Create Firestore Database

1. Go to **Firestore Database** in left sidebar
2. Click **"Create database"**
3. Select **"Start in production mode"** (we'll add rules next)
4. Choose database location (closest to your users)
5. Click **"Enable"**

**Deploy Security Rules:**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize Firebase in project (if not already done)
firebase init

# Deploy Firestore rules
firebase deploy --only firestore:rules
```

### 6. Create Realtime Database

1. Go to **Realtime Database** in left sidebar
2. Click **"Create Database"**
3. Select **"Start in locked mode"**
4. Choose database location
5. Click **"Enable"**

**Database Rules:** See [README_BACKEND.md](README_BACKEND.md) for detailed rules.

### 7. Set Admin User (Important!)

After registering your first user, set admin privileges:

```javascript
// In set-admin-claim.js (already in project root)
const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const uid = 'YOUR_USER_UID_HERE'; // Get from Firebase Console → Authentication
admin.auth().setCustomUserClaims(uid, { admin: true })
  .then(() => {
    console.log('✅ Admin claim set successfully');
  });
```

Run it:
```bash
node set-admin-claim.js
```

---

## 🗺 Google Maps Setup

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click project dropdown → **"New Project"**
3. Enter project name: `bus-tracker-maps`
4. Click **"Create"**

### 2. Enable Required APIs

In Google Cloud Console, enable these APIs:

1. **Maps SDK for Android** (required)
2. **Maps SDK for iOS** (if building for iOS)
3. **Maps JavaScript API** (optional for web)
4. **Places API** (optional for location search)
5. **Geolocation API** (optional)

**How to enable:**
- Use search bar at top
- Search for API name (e.g., "Maps SDK for Android")
- Click on API → Click **"Enable"**

### 3. Create API Key

1. Go to **Credentials** (left sidebar)
2. Click **"+ CREATE CREDENTIALS"**
3. Select **"API Key"**
4. Copy the generated key (starts with `AIzaSy...`)
5. Click **"Restrict Key"** (recommended for security)

**Restrict the API Key:**

**For Android:**
- Application restrictions → **"Android apps"**
- Add package name: `com.example.bus_tracker`
- Add SHA-1 certificate fingerprint (optional but recommended)

**Get SHA-1 fingerprint:**
```bash
cd android
./gradlew signingReport
# Copy SHA-1 from debug variant
```

**For iOS:**
- Application restrictions → **"iOS apps"**
- Add bundle ID from `Info.plist`

**API restrictions:**
- Select **"Restrict key"**
- Check only the APIs you enabled (Maps SDK for Android, etc.)

### 4. Configure API Key in App

Update `.env` file:
```env
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Update `AndroidManifest.xml` (already shown in Configuration section).

---

## 👥 User Roles & Permissions

### Student Role 🎓
- **Permissions:**
  - View assigned buses on map
  - Receive push notifications
  - View profile and update details
  - View route information
- **Cannot:**
  - Update bus locations
  - Access admin features
  - Modify driver data

### Driver Role 🚗
- **Permissions:**
  - Update real-time bus location
  - Update bus status (departed, in-transit, etc.)
  - View assigned route and students
  - Update own profile
- **Cannot:**
  - Create/delete buses or routes
  - Access admin dashboard
  - Assign students to buses

### Admin Role 👨‍💼
- **Permissions:**
  - Full access to all features
  - Create/edit/delete buses, routes, drivers
  - Assign students to buses
  - View all real-time locations
  - Access analytics dashboard
- **How to set:**
  ```bash
  node set-admin-claim.js USER_UID
  ```

**Default role for new registrations:** Student

---

## 🔒 Security & Privacy

### Data Security
- All sensitive data encrypted in transit (HTTPS/WSS)
- Firebase Authentication with email verification
- Firestore security rules enforce role-based access
- API keys restricted by package name and SHA-1

### Privacy
- Location data only tracked while using app (except for drivers)
- Users can delete their account and data
- No third-party data sharing
- GDPR compliant (with proper implementation)

---

## 🧪 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Run specific test file
flutter test test/services/firebase_service_test.dart
```

### Manual Testing Checklist

- [ ] User registration with valid email
- [ ] Login with correct credentials
- [ ] Password reset flow
- [ ] Profile creation and updates
- [ ] Bus location updates (as driver)
- [ ] Real-time map tracking (as student)
- [ ] Bus assignment functionality (as admin)
- [ ] Route creation (as admin)
- [ ] Notifications received
- [ ] Offline functionality
- [ ] App doesn't crash on network loss

---

## 🐛 Troubleshooting

### Common Issues

**1. Firebase duplicate app error**
```
✅ Fixed in main.dart with Firebase.apps.isEmpty check
```

**2. Google Maps not showing**
```
Solution:
- Verify API key in AndroidManifest.xml is correct
- Check Maps SDK for Android is enabled in Google Cloud
- Check if device has internet connection
- Verify package name matches in Google Cloud restrictions
```

**3. Location permission denied**
```
Solution:
- Grant location permissions in device Settings → Apps → Bus Tracker → Permissions
- For iOS, check Info.plist has location usage descriptions
- Restart app after granting permissions
```

**4. Build failed on Windows**
```
Solution:
- Enable Developer Mode: start ms-settings:developers
- Run: flutter clean && flutter pub get
- Restart IDE
```

**5. Firebase not initialized error**
```
Solution:
- Ensure google-services.json is in android/app/
- Run: flutter clean && flutter pub get
- Check firebase_options.dart exists
```

**6. "LatLng import conflict" error**
```
✅ Already fixed - removed latlong2 package, using google_maps_flutter only
```

### Enable Debug Logging

Add this to `main.dart` for verbose logging:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable detailed logging
  debugPrint('🚀 App starting...');
  
  // ... rest of initialization
}
```

---

## 📊 Performance Tips

- Location updates throttled to 5-10 seconds to save battery
- Map markers update efficiently using StreamBuilder
- Images cached locally with `cached_network_image`
- Firestore queries use composite indexes for fast retrieval
- Realtime Database used for high-frequency location updates (cheaper than Firestore)

---

## 🤝 Contributing

Contributions welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch: `git checkout -b feature/AmazingFeature`
3. Commit changes: `git commit -m 'Add AmazingFeature'`
4. Push to branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

### Code Style Guidelines
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter format .` before committing
- Add comments for complex logic
- Write unit tests for new features
- Update documentation

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for scalable backend infrastructure
- Google Maps for mapping services
- All contributors and beta testers

---

## 📞 Support & Contact

- **Issues:** [GitHub Issues](https://github.com/yourusername/bus_tracker/issues)
- **Email:** shanthosh.krishnan@outlook.com


---

## 🗺️ Roadmap

- [ ] Push notification enhancements with customizable alerts
- [ ] Offline mode with local database caching
- [ ] In-app chat between students and drivers
- [ ] QR code-based attendance tracking
- [ ] Advanced analytics dashboard with charts
- [ ] Multi-language support (i18n)
- [ ] Dark mode theme
- [ ] Web admin panel
- [ ] Route optimization with AI
- [ ] Integration with school management systems

---

## 📚 Additional Documentation

- **[README_FRONTEND.md](README_FRONTEND.md)** - Frontend architecture, UI components, and state management
- **[README_BACKEND.md](README_BACKEND.md)** - Backend services, Firebase structure, and API reference

---

**Made with ❤️ using Flutter & Firebase**

**Version:** 1.0.0  
**Last Updated:** January 23, 2026

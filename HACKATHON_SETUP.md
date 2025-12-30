# 🚀 HACKATHON SETUP GUIDE

> Complete step-by-step guide for setting up and running the Panimalar Smart Bus Management System for the hackathon.

**Last Updated**: December 30, 2025  
**Status**: 🔥 Ready for Submission

---

## 📋 Quick Setup (5 Minutes)

If you just want to see the app running quickly:

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/bus_tracker.git
cd bus_tracker

# 2. Copy environment template
cp .env.example .env

# 3. Fill in Firebase credentials in .env
# (See "Get Firebase Credentials" section below)

# 4. Install dependencies
flutter pub get

# 5. Run the app
flutter run

# 6. Login with demo credentials:
# Email: student@example.com
# Password: student@123
```

---

## 🔥 FIREBASE SETUP (10 Minutes)

### Step 1: Create Firebase Project

1. Go to **[Firebase Console](https://console.firebase.google.com)**
2. Click **"Create Project"**
3. Enter name: `bus-tracker-panimalar`
4. Enable Google Analytics (optional)
5. Click **"Create Project"**
6. Wait for project to be created (~5 minutes)

### Step 2: Get API Credentials

**For Android:**
1. Project Settings → **Your apps** → Android icon
2. If no Android app exists:
   - Click **"Add App"** → Android
   - Enter package name: `com.example.bus_tracker`
   - Download `google-services.json`
   - Save to: `android/app/google-services.json`
3. Copy these values to `.env`:
   ```
   FIREBASE_ANDROID_API_KEY=<Copy from google-services.json - api_key->current_key>
   FIREBASE_ANDROID_APP_ID=<mobileSdkAppId>
   FIREBASE_MESSAGING_SENDER_ID=<sender_id>
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
   ```

**For iOS:**
1. Still in Your apps → Click **"Add App"** → iOS
2. Bundle ID: `com.example.busTracker`
3. Download `GoogleService-Info.plist`
4. Save to: `ios/Runner/GoogleService-Info.plist`
5. Copy to `.env`:
   ```
   FIREBASE_IOS_API_KEY=<Copy from GoogleService-Info.plist - API_KEY>
   FIREBASE_IOS_APP_ID=<GOOGLE_APP_ID>
   ```

### Step 3: Enable Firebase Services

In Firebase Console:

1. **Firestore Database**
   - Left sidebar → **"Firestore Database"**
   - Click **"Create Database"**
   - Select location: **Asia (Mumbai)** or **Asia Pacific (Singapore)**
   - Start in **Production mode**
   - Click **"Create"**

2. **Authentication**
   - Left sidebar → **"Authentication"**
   - Click **"Get Started"**
   - Enable **"Email/Password"** (Click toggle)
   - Enable **"Anonymous"** (for testing)

3. **Cloud Messaging**
   - Left sidebar → **"Cloud Messaging"**
   - Copy **Server API Key** to `.env` as `FCM_API_KEY`

4. **Storage** (for future use)
   - Left sidebar → **"Storage"**
   - Click **"Get Started"**
   - Use default settings
   - Click **"Done"**

### Step 4: Update Firestore Rules

**IMPORTANT**: Default rules deny all access. We must update them.

1. Firestore Database → **"Rules"** tab
2. Replace with rules from: [FIRESTORE_PERMISSION_FIX_QUICK.md](FIRESTORE_PERMISSION_FIX_QUICK.md)
3. Click **"Publish"**

The rules should allow:
- ✅ Authenticated users to read routes
- ✅ Authenticated users to read/write their own notifications
- ✅ Admins to write demo data
- ✅ Users to access their own profiles

---

## 🛠️ LOCAL SETUP (10 Minutes)

### Step 1: Install Dependencies

```bash
# Install Flutter packages
flutter pub get

# Install flutter_dotenv (used for environment variables)
# Already added to pubspec.yaml, installed above
```

### Step 2: Setup Environment Variables

```bash
# Copy template to actual .env file
cp .env.example .env

# Open .env in your editor
nano .env    # or
code .env    # or
vim .env     # or use any editor
```

### Step 3: Fill in .env File

Copy values from Firebase Console:

```env
# Firebase Android (from google-services.json)
FIREBASE_ANDROID_API_KEY=YOUR_ANDROID_API_KEY
FIREBASE_ANDROID_APP_ID=1:818518045990:android:8cf94322a372283fdabde7
FIREBASE_MESSAGING_SENDER_ID=818518045990
FIREBASE_PROJECT_ID=bus-tracker-panimalar
FIREBASE_STORAGE_BUCKET=bus-tracker-panimalar.appspot.com

# Firebase iOS (from GoogleService-Info.plist)
FIREBASE_IOS_API_KEY=YOUR_IOS_API_KEY
FIREBASE_IOS_APP_ID=1:818518045990:ios:xxxxxxxxxxxx
FIREBASE_IOS_BUNDLE_ID=com.example.busTracker

# Windows/Linux/macOS (for future expansion)
FIREBASE_WINDOWS_API_KEY=YOUR_KEY
FIREBASE_LINUX_API_KEY=YOUR_KEY
FIREBASE_MACOS_API_KEY=YOUR_KEY

# Demo Settings (Use these for testing)
DEMO_BUS_NUMBER=154
DEMO_STUDENT_EMAIL=student@example.com
DEMO_ADMIN_EMAIL=admin@example.com

# App Settings
APP_NAME=Bus Tracker
ENVIRONMENT=development
```

### Step 4: Verify Setup

```bash
# Check if Flutter and Dart are installed
flutter --version
dart --version

# Check connected devices
flutter devices

# Clean project
flutter clean

# Get packages again
flutter pub get
```

---

## 👥 CREATE TEST USERS (5 Minutes)

### Step 1: Create Users in Firebase Console

1. Firebase Console → **Authentication** → **Users** tab
2. Click **"Create user"**

#### Student User
```
Email: student@example.com
Password: student@123
```

#### Admin User
```
Email: admin@example.com
Password: admin@123
```

#### Driver User
```
Email: driver@example.com
Password: driver@123
```

### Step 2: Set Admin Custom Claims

**For admin user only:**

1. Still in Authentication → Users
2. Find **admin@example.com**
3. Click the three dots → **"Edit custom claims"**
4. Enter JSON:
   ```json
   {
     "admin": true
   }
   ```
5. Click **"Save"**

> This gives the user admin permissions in the app and Firebase rules

---

## 📱 RUN THE APP (5 Minutes)

### Android Device

```bash
# Build and run on connected Android device
flutter run

# Or specify device ID
flutter devices                  # See available devices
flutter run -d <device-id>
```

### iOS Simulator

```bash
# Start iOS simulator
open -a Simulator

# Run app on iOS
flutter run -d ios
```

### Web Browser (Testing only)

```bash
flutter run -d chrome
```

### Build APK/IPA

```bash
# Android APK
flutter build apk --release

# iOS IPA (requires Mac)
flutter build ios --release
```

---

## 🎮 TEST THE APP

### 1. Login as Student

1. Launch app
2. Email: `student@example.com`
3. Password: `student@123`
4. Select role: **Student**
5. Tap **"Complete Profile"**
6. Fill in:
   - First Name, Last Name
   - Phone Number
   - Home Location (Urapakkam)
7. Tap **"Save"** → Location is now saved

### 2. View Home Page

1. You're back at home page
2. Scroll down to see "🔔 Bus Notifications"
3. If no buses nearby, create demo data (next step)

### 3. Create Demo Data (Admin Only)

1. Logout
2. Login as: `admin@example.com` / `admin@123`
3. Select role: **Admin**
4. Scroll to "💼 Admin Controls"
5. Tap **"Demo Data"** button
6. This creates:
   - Bus #154, #125, #123, #115
   - Routes (Morning/Evening)
   - Locations near Urapakkam

### 4. View Bus on Map

1. Go back to home page
2. You should see buses nearby
3. Tap bus card to see details
4. Tap **"View on Map"** to see location
5. Bus marker shows on map

### 5. Test Notifications

1. In Firebase Console → Firestore → **notifications** collection
2. Click **"Add document"**
3. Set fields:
   ```
   userId: (copy your user ID from Firebase Auth)
   busNumber: "154"
   message: "Bus #154 is approaching. 2.5 km away"
   type: "bus_approaching"
   read: false
   createdAt: (server timestamp)
   ```
4. Refresh app → See notification in home page
5. Swipe left on notification to dismiss

---

## 🔐 SECURITY SETUP

### 1. Verify .env is NOT Committed

```bash
# Check if .env is in gitignore
cat .gitignore | grep .env

# Should show:
# .env
# .env.local
# .env.*.secret

# Verify .env is not tracked
git status

# Should NOT show .env in the list
```

### 2. Store Credentials Safely

**Never commit .env to GitHub!**

Instead:
1. Each developer has their own `.env` file (local only)
2. Share `.env.example` as template
3. Use GitHub Secrets for CI/CD

### 3. Test Admin Custom Claims

```dart
// In your code, check if user is admin:
final token = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
print(token?.claims?['admin']); // Should be true for admin user
```

---

## 🧪 VERIFICATION CHECKLIST

### Before Submission

- [ ] App builds without errors
  ```bash
  flutter build apk --release
  ```

- [ ] All test users created
  - [ ] student@example.com
  - [ ] admin@example.com
  - [ ] driver@example.com

- [ ] Admin has custom claim `{"admin": true}`

- [ ] Firestore rules are published

- [ ] Demo data created (buses, routes)

- [ ] Notification appears in app

- [ ] Maps show bus location

- [ ] .env file is NOT in git
  ```bash
  git status  # Should NOT show .env
  ```

- [ ] .env.example is in git
  ```bash
  git status  # Should show .env.example
  ```

- [ ] No sensitive data in code
  ```bash
  grep -r "firebase_key" lib/
  grep -r "api_key" lib/
  # Should return nothing
  ```

- [ ] Documentation is complete
  - [ ] README.md ✅
  - [ ] HACKATHON_PROGRESS.md ✅
  - [ ] FIRESTORE_PERMISSION_FIX_QUICK.md ✅
  - [ ] HACKATHON_SETUP.md (this file) ✅

---

## 🐛 TROUBLESHOOTING

### App Crashes on Startup

**Problem**: `PlatformException(firebase_core, ...)`

**Solution**:
1. Verify `.env` file exists: `ls .env`
2. Check Firebase credentials are correct in `.env`
3. Verify `google-services.json` in `android/app/`
4. Run: `flutter clean && flutter pub get && flutter run`

### Permission Denied Error

**Problem**: `PERMISSION_DENIED: Missing or insufficient permissions`

**Solution**:
1. Check Firestore rules are published
2. Firebase Console → Firestore → Rules → Check "Publish" button
3. Verify user is authenticated
4. Check rules allow the operation

### Location Not Updating

**Problem**: Map doesn't show bus location

**Solution**:
1. Grant location permission in app settings
2. For Android: Settings → Apps → Bus Tracker → Permissions → Location
3. For iOS: Settings → Bus Tracker → Location → "Always"
4. Restart app and try again

### Notification Not Appearing

**Problem**: Added notification to Firestore but doesn't show in app

**Solution**:
1. Verify `userId` is correct (from Firebase Auth)
2. Check `read` field is `false`
3. Refresh app (pull down on home page)
4. Check Firestore rules allow the read

### Cannot Create Admin

**Problem**: Custom claim not working

**Solution**:
1. Logout and login again (refreshes claims)
2. Check claim is set correctly in Firebase Console
3. Verify rule checks claim: `request.auth.token.admin == true`

### APK Size Too Large

**Problem**: APK is > 100MB

**Solution**:
```bash
# Build release APK with split-per-abi
flutter build apk --split-per-abi --release

# Check file sizes
ls -lh build/app/outputs/apk/release/
```

---

## 📊 ARCHITECTURE OVERVIEW

### Data Flow

```
User (App)
    ↓
Firebase Auth (Email/Password)
    ↓
Firestore Database
    ├── users/
    ├── buses/
    ├── routes/
    ├── notifications/
    └── demo_data/
    ↓
Firebase Cloud Messaging
    ↓
Push Notification (Phone)
```

### Collections Structure

```
users/
  └── {userId}
      ├── email
      ├── role (student/driver/admin)
      ├── firstName
      ├── lastName
      ├── homeLocation
      └── lastKnownLatitude

buses/
  └── {busId}
      ├── busNumber
      ├── vehicleNumber
      ├── driverId
      ├── currentLatitude
      ├── currentLongitude
      └── updatedAt

notifications/
  └── {notificationId}
      ├── userId
      ├── busNumber
      ├── message
      ├── type
      ├── read
      └── createdAt

demo_data/
  └── {demoDataId}
      ├── buses (array)
      └── routes (array)
```

---

## 🎯 NEXT STEPS AFTER SETUP

1. **Test All Features**
   - Login as different roles
   - Create/edit buses and routes
   - Send test notifications
   - Verify map functionality

2. **Record Demo Video**
   - Show app startup
   - Login and profile setup
   - View buses on map
   - Receive notification
   - Admin creating demo data

3. **Prepare Presentation**
   - Problem statement
   - Solution architecture
   - Key features
   - Tech stack
   - Results/metrics

4. **Final Testing**
   - Performance on slow network
   - Error handling
   - Edge cases
   - Security verification

---

## 📝 IMPORTANT FILES

### Configuration
- `.env.example` - Template with all required variables
- `.env` - Your local credentials (NOT in git)
- `lib/config/env_config.dart` - Configuration service
- `lib/firebase_options.dart` - Firebase setup

### Documentation
- `README.md` - Main project guide
- `HACKATHON_PROGRESS.md` - Completion status
- `FIRESTORE_PERMISSION_FIX_QUICK.md` - Security rules
- `ADVANCED_ROUTE_MANAGEMENT.md` - Route guide
- `HACKATHON_SETUP.md` - This file

### Main Code
- `lib/main.dart` - App entry point
- `lib/pages/` - UI pages
- `lib/services/` - Business logic
- `lib/models/` - Data classes
- `lib/widgets/` - Reusable UI components

---

## ✅ QUICK REFERENCE

### Create User
```
Firebase Console → Authentication → Users → Create user
```

### Set Admin Claim
```
Firebase Console → Authentication → Users → Custom Claims
Input: {"admin": true}
```

### Create Bus
```
App (as Admin) → Admin Page → Create Bus
Enter: Bus Number, Vehicle Number, Route
```

### Send Notification
```
Firebase Console → Firestore → notifications → Add Document
Fields: userId, busNumber, message, type, read, createdAt
```

### View Logs
```bash
flutter logs  # Real-time app logs
adb logcat    # Android logs
```

### Reset Everything
```bash
# Delete app data
flutter clean
adb shell pm clear com.example.bus_tracker  # Android
rm -rf ~/Library/Developer/Xcode/DerivedData  # iOS

# Fresh install
flutter pub get
flutter run
```

---

## 🎓 LEARNING RESOURCES

### Firebase
- [Firebase Console](https://console.firebase.google.com)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Auth Docs](https://firebase.google.com/docs/auth)

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language](https://dart.dev/guides)
- [Flutter Packages](https://pub.dev)

### Google Maps
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Maps Platform Documentation](https://developers.google.com/maps/documentation)

---

## 📞 SUPPORT

### If Something Doesn't Work

1. **Check the logs**:
   ```bash
   flutter logs
   ```

2. **Check Firebase Console** for errors

3. **Review documentation** files:
   - `README.md` - General setup
   - `FIRESTORE_PERMISSION_FIX_QUICK.md` - Security issues
   - `ADVANCED_ROUTE_MANAGEMENT.md` - Routes

4. **Common issues** section above

---

## 🏁 SUMMARY

You now have:
- ✅ Complete Flutter app with all features
- ✅ Firebase backend configured
- ✅ Test users and demo data ready
- ✅ Secure environment-based configuration
- ✅ Complete documentation

**Ready to submit to hackathon!**

---

**Made with ❤️ for Panimalar Engineering College Hackathon**

*December 30, 2025*

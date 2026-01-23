# 📱 LO BUS - Frontend Documentation

This document covers the frontend architecture, UI components, pages, widgets, and state management patterns used in the LO BUS application.

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [UI Pages](#ui-pages)
- [Widgets & Components](#widgets--components)
- [State Management](#state-management)
- [Navigation Flow](#navigation-flow)
- [Styling & Theming](#styling--theming)
- [Form Validation](#form-validation)
- [Best Practices](#best-practices)

---

## 🏗️ Architecture Overview

### App Structure

```
Main App (MaterialApp)
  ├── _AppInitializer (handles startup sync)
  │   ├── Driver sync on startup
  │   ├── Location permission request
  │   └── Routes to LoginPage or HomePage
  │
  ├── Authentication Flow
  │   ├── LoginPage
  │   ├── RegisterPage
  │   └── ForgotPasswordPage
  │
  └── Main Application Flow (after login)
      ├── StudentPage (for students)
      ├── DriverPage (for drivers)
      └── AdminPage (for admins)
          ├── HomePage (bus tracking map)
          ├── BusManagementPage
          ├── DriverManagementPage
          └── RouteManagementPage
```

### Design Pattern

The app follows **Service-Oriented Architecture**:
- **Pages** handle UI rendering and user interaction
- **Services** handle business logic and Firebase operations
- **Models** define data structures
- **Widgets** are reusable UI components

---

## 📄 UI Pages

### 1. Login Page (`login_page.dart`)

**Purpose:** User authentication entry point

**Features:**
- Email/password login form
- Form validation (email format, password length)
- Password visibility toggle
- "Remember me" functionality
- "Forgot Password" link
- Registration redirect

**Key Widgets:**
```dart
- TextField (email input)
- TextField (password input with obscureText)
- ElevatedButton (login button)
- TextButton (forgot password, register links)
- Form + GlobalKey<FormState> (validation)
```

**Navigation:**
```dart
// On successful login
if (userRole == 'student') → StudentPage
if (userRole == 'driver') → DriverPage
if (userRole == 'admin') → AdminPage
else → HomePage (default)
```

**Validation Rules:**
- Email: Must be valid email format
- Password: Minimum 6 characters
- Both fields required

**Error Handling:**
- Invalid credentials → Show SnackBar with error message
- Network error → Show retry option
- Firebase errors → Display user-friendly messages

---

### 2. Register Page (`register_page.dart`)

**Purpose:** New user account creation

**Features:**
- Multi-field registration form
  - First Name, Last Name
  - Email (unique)
  - Phone Number
  - Password, Confirm Password
  - Role selection (Student, Driver, Admin)
- Form validation for all fields
- Password strength indicator
- Terms & conditions checkbox
- Automatic driver record creation (if role = driver)

**Key Components:**
```dart
- TextFormField (all input fields)
- DropdownButton<String> (role selection)
- Checkbox (terms acceptance)
- ElevatedButton (register button)
- Form validation with GlobalKey
```

**Flow:**
1. User fills registration form
2. Validation checks all fields
3. Firebase Authentication creates user account
4. User profile saved to Firestore `/users/{uid}`
5. If role='driver' → Create driver record in `/drivers/{uid}`
6. Auto-login and navigate to appropriate page

**Validation Rules:**
- Email: Valid format, not already registered
- Password: 8+ characters, at least one number
- Confirm Password: Must match password
- Phone: 10 digits (adjust for your region)
- All fields required

---

### 3. Forgot Password Page (`forgot_password_page.dart`)

**Purpose:** Password reset flow

**Features:**
- Email input field
- Send reset email button
- Confirmation message
- Back to login link

**Flow:**
1. User enters registered email
2. Firebase sends password reset email
3. User clicks link in email
4. Firebase handles password reset
5. User returns to login page

**Error Handling:**
- Invalid email → Show error message
- Email not registered → Generic message (security)
- Network error → Show retry option

---

### 4. Home Page (`home_page.dart`)

**Purpose:** Main bus tracking map view

**Features:**
- Google Maps integration with real-time bus markers
- Current user location marker
- Bus info cards (tap marker to view)
- Filter buses by status
- Search buses by number
- Refresh button (pull to refresh)
- Role-based marker colors:
  - Blue: Student buses
  - Green: Driver buses
  - Red: Delayed buses
  - Orange: In-transit buses

**Key Components:**
```dart
GoogleMap(
  initialCameraPosition: CameraPosition(...),
  markers: Set<Marker>.from(busMarkers),
  onMapCreated: (GoogleMapController controller) { ... },
  myLocationEnabled: true,
  myLocationButtonEnabled: true,
)

StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('bus_locations').snapshots(),
  builder: (context, snapshot) {
    // Update markers in real-time
  },
)
```

**Real-time Updates:**
- Bus locations update every 5-10 seconds
- StreamBuilder listens to Firestore changes
- Markers update automatically on data change
- Smooth marker animation with `markerId` stability

**User Interactions:**
- Tap marker → Show bus details popup
- Long press map → Show coordinates
- Pinch to zoom
- Pan to navigate

---

### 5. Student Page (`student_page.dart`)

**Purpose:** Student-specific dashboard

**Features:**
- Welcome header with profile icon
- Real-time clock (updates every second)
- Current location display (auto-updates)
- Search bar for buses/routes/drivers
- Two sections:
  1. **Your Assigned Buses** (full details)
  2. **Other Buses** (limited info)
- Google Map toggle (FAB button)
- Refresh button
- Bus status indicators (green/orange/red)

**Layout:**
```dart
CustomScrollView(
  slivers: [
    SliverAppBar(expandable header),
    SliverToBoxAdapter(search bar),
    SliverList(assigned buses),
    SliverToBoxAdapter(divider),
    SliverList(other buses),
  ],
)
```

**Bus Card Information:**
- Bus number and route name
- Driver name and contact
- Current status (departed, in-transit, arrived)
- Next stop information
- Passenger count (X/Y capacity)
- Estimated time (departure → arrival)

**Map View:**
- Toggle between list view and map view
- Shows assigned bus with highlighted marker
- Shows current location
- Real-time bus position updates

---

### 6. Driver Page (`driver_page.dart`)

**Purpose:** Driver control panel

**Features:**
- Current assigned bus information
- Route details with all stops
- Student list (assigned students)
- Location broadcasting toggle
- Bus status update buttons:
  - Departed
  - In Transit
  - Arrived
  - Delayed (with reason input)
- Passenger count update
- Emergency contact (admin)

**Location Broadcasting:**
```dart
Timer.periodic(Duration(seconds: 10), (timer) async {
  if (_isBroadcasting) {
    LatLng? location = await LocationService().getCurrentLocation();
    if (location != null) {
      await LocationTrackingService().updateBusLocation(
        BusLocation(
          busId: assignedBusId,
          currentLatitude: location.latitude,
          currentLongitude: location.longitude,
          lastUpdated: DateTime.now().toIso8601String(),
          status: currentStatus,
        ),
      );
    }
  }
});
```

**Status Update Flow:**
1. Driver selects new status
2. If "Delayed" → Show delay reason dialog
3. Update bus status in Realtime Database
4. All listening clients receive update instantly
5. Show confirmation message

---

### 7. Admin Page (`admin_page.dart`)

**Purpose:** Administrative dashboard

**Features:**
- Quick action cards:
  - 🚌 Manage Buses
  - 👨‍✈️ Manage Drivers
  - 🗺️ Manage Routes
  - 👨‍🎓 Assign Students
  - 📊 View Analytics
  - ⚙️ Settings
- System statistics overview
- Recent activity feed
- Quick search functionality

**Navigation:**
```dart
Card(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BusManagementPage()),
    );
  },
  child: Column(
    children: [
      Icon(Icons.directions_bus),
      Text('Manage Buses'),
    ],
  ),
)
```

---

### 8. Bus Management Page (`bus_management_page.dart`)

**Purpose:** CRUD operations for buses

**Features:**
- List of all buses with search/filter
- Add new bus (FAB button)
- Edit bus details
- Delete bus (with confirmation)
- Assign driver to bus
- View bus history

**Bus Form Fields:**
- Bus Number (unique identifier)
- Departure Place
- Arrival Place
- Total Capacity (number of seats)
- Assigned Driver (dropdown)
- Assigned Route (dropdown)
- Status (active/inactive)

**Operations:**
```dart
// Create
await FirebaseService().createBus(busData);

// Read
Stream<List<Bus>> buses = FirebaseService().streamBuses();

// Update
await FirebaseService().updateBus(busId, updatedData);

// Delete
await FirebaseService().deleteBus(busId);
```

**Validation:**
- Bus number must be unique
- Capacity must be positive integer
- Cannot delete bus with active assignments
- Cannot delete bus with students assigned

---

### 9. Driver Management Page (`driver_management_page.dart`)

**Purpose:** Manage driver profiles and assignments

**Features:**
- Active drivers list
- Inactive drivers list
- Add new driver
- Edit driver profile
- Assign/unassign bus
- Deactivate driver (soft delete)

**Driver Form Fields:**
- Driver Name
- Email (from user account)
- Phone Number
- License Number
- Assigned Bus (dropdown)
- Assigned Route (dropdown)
- Status (active/on-break/inactive)

**Driver Card Display:**
```dart
ListTile(
  leading: CircleAvatar(
    child: Icon(Icons.person),
  ),
  title: Text(driverName),
  subtitle: Text('Bus: $busNumber | Route: $routeName'),
  trailing: PopupMenuButton(
    items: [
      PopupMenuItem(text: 'Edit'),
      PopupMenuItem(text: 'Deactivate'),
    ],
  ),
)
```

**Automatic Sync:**
- When user with role='driver' updates profile → driver record auto-syncs
- On app startup → `DriverSyncService().syncCurrentUserDriver()` called
- Handled by `driver_sync_service.dart`

---

### 10. Route Management Page (`route_management_page.dart`)

**Purpose:** Create and manage bus routes

**Features:**
- List of all routes
- Add new route with stops
- Edit route details
- Delete route
- View route on map
- Assign buses to route

**Route Form:**
- Route Name
- Departure Location (GPS)
- Arrival Location (GPS)
- Stops (ordered list with GPS coordinates)
- Estimated Duration
- Active Status

**Stop Management:**
```dart
ListView.builder(
  itemCount: stops.length,
  itemBuilder: (context, index) {
    return ReorderableDragStartListener(
      index: index,
      child: StopCard(
        stopName: stops[index].name,
        latitude: stops[index].latitude,
        longitude: stops[index].longitude,
        order: index + 1,
        onEdit: () => editStop(index),
        onDelete: () => deleteStop(index),
      ),
    );
  },
)
```

**Adding Stop:**
1. Tap "Add Stop" button
2. Enter stop name
3. Either:
   - Enter GPS coordinates manually
   - Pick location on map
   - Use current location
4. Stop added to list

**Map Preview:**
- Shows route polyline connecting all stops
- Markers at each stop location
- Color-coded by order (green → red)

---

### 11. Profile Page (`profile_page.dart`)

**Purpose:** User profile view and edit

**Features:**
- View mode:
  - Profile picture (avatar)
  - Name, Email, Phone
  - Role badge
  - Account creation date
- Edit mode:
  - Update name, phone
  - Change password
  - Update profile picture
  - Set home location (students)
- Logout button
- Delete account option

**Edit Flow:**
1. User taps "Edit" button
2. Form fields become editable
3. User makes changes
4. Tap "Save Changes"
5. Validate inputs
6. Update Firestore user document
7. If user is driver → trigger `DriverSyncService.syncCurrentUserDriver()`
8. Show success message
9. Return to view mode

**Profile Picture Upload:**
```dart
// Using image_picker
final ImagePicker _picker = ImagePicker();
final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

if (image != null) {
  // Upload to Firebase Storage
  Reference ref = FirebaseStorage.instance
      .ref()
      .child('profile_pictures')
      .child('${user.uid}.jpg');
  
  await ref.putFile(File(image.path));
  String downloadUrl = await ref.getDownloadURL();
  
  // Update user profile
  await FirebaseService().updateUserProfile(uid, {'profilePicture': downloadUrl});
}
```

---

### 12. Bus Details Popup (`bus_details_popup.dart`)

**Purpose:** Modal showing detailed bus information

**Triggered by:** Tapping bus marker on map

**Features:**
- Bus number and route name
- Current status with color indicator
- Driver information (name, phone)
- Current location (address or coordinates)
- Passenger count with capacity indicator
- Next stop information
- Estimated arrival time
- "Track Bus" button (opens full map view)
- Call driver button

**Layout:**
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: BusDetailsContent(bus: bus),
        );
      },
    );
  },
);
```

**Information Sections:**
1. Header: Bus number, status badge
2. Driver: Name, photo, call button
3. Location: Current position, next stop
4. Capacity: Progress bar showing passengers/capacity
5. Route: List of upcoming stops
6. Actions: Track on map, set notification

---

### 13. Bus Seat Selection Page (`bus_seat_selection_page.dart`)

**Purpose:** Visual seat selection interface

**Features:**
- Grid layout showing all seats
- Seat status colors:
  - Green: Available
  - Red: Occupied
  - Blue: Selected
  - Gray: Reserved
- Tap to select/deselect seat
- Confirm booking button
- Seat legend

**Seat Grid:**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4, // 4 seats per row (2 left, aisle, 2 right)
    childAspectRatio: 1,
  ),
  itemCount: totalSeats,
  itemBuilder: (context, index) {
    if (index % 4 == 2) {
      return SizedBox.shrink(); // Aisle space
    }
    
    return GestureDetector(
      onTap: () => onSeatTap(index),
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: getSeatColor(index),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('${index + 1}')),
      ),
    );
  },
)
```

---

## 🧩 Widgets & Components

### 1. Bus Card Widget (`bus_card.dart`)

**Purpose:** Reusable card component for bus list items

**Props:**
```dart
class BusCard extends StatelessWidget {
  final String busNumber;
  final String routeName;
  final String driverName;
  final String status;
  final int currentPassengers;
  final int totalCapacity;
  final VoidCallback onTap;

  const BusCard({
    required this.busNumber,
    required this.routeName,
    required this.driverName,
    required this.status,
    required this.currentPassengers,
    required this.totalCapacity,
    required this.onTap,
  });
}
```

**Usage:**
```dart
BusCard(
  busNumber: '154',
  routeName: 'Main Street Route',
  driverName: 'John Doe',
  status: 'in-transit',
  currentPassengers: 25,
  totalCapacity: 40,
  onTap: () {
    // Navigate to bus details
  },
)
```

**Status Colors:**
```dart
Color getStatusColor(String status) {
  switch (status) {
    case 'departed':
      return Colors.blue;
    case 'in-transit':
      return Colors.orange;
    case 'arrived':
      return Colors.green;
    case 'delayed':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
```

---

### 2. Custom AppBar

**Consistent app bar across pages:**
```dart
AppBar buildCustomAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    backgroundColor: Theme.of(context).primaryColor,
    elevation: 2,
    actions: [
      IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () {
          // Navigate to notifications
        },
      ),
      IconButton(
        icon: Icon(Icons.account_circle),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        },
      ),
    ],
  );
}
```

---

### 3. Loading Indicator

**Consistent loading state:**
```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
```

**Usage:**
```dart
if (isLoading) {
  return LoadingIndicator(message: 'Loading buses...');
}
```

---

### 4. Error Widget

**Consistent error display:**
```dart
class ErrorDisplay extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 🔄 State Management

### Current Approach: StatefulWidget + StreamBuilder

**Why this approach:**
- Simple to understand and implement
- Perfect for Firebase real-time updates
- No additional dependencies
- Sufficient for current app complexity

**Pattern:**
```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Local state
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Bus>>(
        stream: FirebaseService().streamBuses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorDisplay(error: snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return LoadingIndicator();
          }

          final buses = snapshot.data!;
          return ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              return BusCard(bus: buses[index]);
            },
          );
        },
      ),
    );
  }
}
```

---

## 🧭 Navigation Flow

### Navigation Pattern

**Named Routes (in `main.dart`):**
```dart
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => LoginPage(),
    '/register': (context) => RegisterPage(),
    '/forgot-password': (context) => ForgotPasswordPage(),
    '/home': (context) => HomePage(),
    '/student': (context) => StudentPage(),
    '/driver': (context) => DriverPage(),
    '/admin': (context) => AdminPage(),
    '/profile': (context) => ProfilePage(),
  },
)
```

**Push Navigation:**
```dart
// Push new page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BusManagementPage(),
  ),
);

// Push with data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BusDetailsPage(busId: '123'),
  ),
);
```

**Named Route Navigation:**
```dart
// Navigate to named route
Navigator.pushNamed(context, '/profile');

// Replace current route
Navigator.pushReplacementNamed(context, '/home');

// Pop until root and push
Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
```

**Back Navigation:**
```dart
// Go back
Navigator.pop(context);

// Go back with data
Navigator.pop(context, resultData);
```

---

## 🎨 Styling & Theming

### Theme Configuration

**In `main.dart`:**
```dart
MaterialApp(
  theme: ThemeData(
    primaryColor: Color(0xFF8B6F47), // Brown
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF8B6F47),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    
    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
)
```

### Color Palette

```dart
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF8B6F47);
  static const Color primaryDark = Color(0xFF5D4A2E);
  static const Color primaryLight = Color(0xFFC0A378);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Bus status colors
  static const Color departed = Color(0xFF2196F3);   // Blue
  static const Color inTransit = Color(0xFFFF9800);  // Orange
  static const Color arrived = Color(0xFF4CAF50);    // Green
  static const Color delayed = Color(0xFFF44336);    // Red
}
```

---

## ✅ Form Validation

### Email Validation

```dart
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email';
  }
  
  return null;
}
```

### Password Validation

```dart
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  
  return null;
}
```

### Phone Number Validation

```dart
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }
  
  final phoneRegex = RegExp(r'^\d{10}$');
  if (!phoneRegex.hasMatch(value)) {
    return 'Enter a valid 10-digit phone number';
  }
  
  return null;
}
```

---

## 🎯 Best Practices

### 1. Always Dispose Controllers

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? _subscription;

  @override
  void dispose() {
    _controller.dispose();
    _subscription?.cancel();
    super.dispose();
  }
}
```

### 2. Use const Constructors

```dart
// Good
const Text('Hello');
const SizedBox(height: 16);

// Avoid
Text('Hello');
SizedBox(height: 16);
```

### 3. Extract Widgets

```dart
// Instead of huge build method
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        _buildHeader(),
        _buildBody(),
        _buildFooter(),
      ],
    ),
  );
}

Widget _buildHeader() {
  return Container(/* ... */);
}
```

### 4. Show Loading States

```dart
Widget build(BuildContext context) {
  if (_isLoading) {
    return LoadingIndicator();
  }

  if (_error != null) {
    return ErrorDisplay(error: _error!);
  }

  // Main content
  return MainContent();
}
```

### 5. Handle Errors Gracefully

```dart
try {
  await FirebaseService().someOperation();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Success!')),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: ${e.toString()}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## 📊 Performance Tips

1. **Use `ListView.builder` instead of `ListView`** for long lists
2. **Cache images** with `cached_network_image` package
3. **Lazy load data** with pagination
4. **Dispose streams and controllers** in `dispose()`
5. **Use `const` constructors** wherever possible
6. **Avoid rebuilding entire tree** - extract widgets
7. **Use `RepaintBoundary`** for complex custom paintings

---

**For backend documentation, see [README_BACKEND.md](README_BACKEND.md)**

---

**Last Updated:** January 23, 2026

// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'services/driver_sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables first
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Environment loaded successfully');
  } catch (e) {
    print('⚠️ Warning: Could not load .env file: $e');
  }

  // Initialize Firebase only once
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    } else {
      print('ℹ️ Firebase already initialized, skipping...');
    }
  } catch (e) {
    // Handle both initialization errors and duplicate app errors
    if (e.toString().contains('[core/duplicate-app]')) {
      print(
        'ℹ️ Firebase already initialized (duplicate app detected), using existing instance',
      );
    } else {
      print('❌ Firebase initialization error: $e');
    }
    // Don't rethrow - allow app to continue with cached Firebase instance
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LO BUS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B6F47)),
        useMaterial3: true,
      ),
      home: const _AppInitializer(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const MyHomePage(title: 'Bus Tracker Home'),
      },
    );
  }
}

// Initializer widget to sync driver on app startup
class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _syncCompleted = false;
  bool _locationPermissionHandled = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Request location permission on app startup
      await _requestLocationPermission();

      // Check if user is logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Sync driver data if user is authenticated
        await DriverSyncService().syncCurrentUserDriver();
        print('✅ Driver sync completed on app startup');
      }
    } catch (e) {
      print('⚠️ Initialization error: $e');
      // Continue anyway - don't block app startup
    } finally {
      if (mounted) {
        setState(() {
          _syncCompleted = true;
          _locationPermissionHandled = true;
        });
      }
    }
  }

  Future<bool> _requestLocationPermission() async {
    try {
      final status = await Geolocator.checkPermission();

      if (status == LocationPermission.denied) {
        final result = await Geolocator.requestPermission();

        if (result == LocationPermission.denied) {
          _showLocationPermissionDialog(true);
          return false;
        } else if (result == LocationPermission.deniedForever) {
          _showLocationPermissionDialog(false);
          return false;
        }

        print('✅ Location permission granted');
        return true;
      } else if (status == LocationPermission.deniedForever) {
        _showLocationPermissionDialog(false);
        return false;
      }

      print('✅ Location permission already granted');
      return true;
    } catch (e) {
      print('⚠️ Error requesting location permission: $e');
      return false;
    }
  }

  void _showLocationPermissionDialog(bool canRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: const Color(0xFF18181B), size: 28),
            const SizedBox(width: 12),
            const Text(
              'Location Permission',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18181B),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              canRetry
                  ? 'This app needs access to your location to show real-time bus tracking and route information.'
                  : 'You have permanently denied location permission. Please enable it in app settings to use this app.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF71717A),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          if (canRetry)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initializeApp();
              },
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(
                  color: Color(0xFF18181B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Continue anyway
              setState(() => _locationPermissionHandled = true);
            },
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_syncCompleted || !_locationPermissionHandled) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF18181B)),
              ),
              SizedBox(height: 16),
              Text(
                'Initializing Bus Tracker...',
                style: TextStyle(color: Color(0xFF71717A), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    return const LoginPage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

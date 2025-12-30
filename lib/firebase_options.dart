import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'config/env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Firebase Configuration is loaded from .env file
    // See .env.example for required variables
    // 
    // Setup Instructions:
    // 1. Copy .env.example to .env
    // 2. Get Firebase credentials from: https://console.firebase.google.com/
    // 3. Project Settings → Click on your app platform
    // 4. Copy API Key and other credentials
    // 5. Update .env file with your credentials
    // 6. Do NOT commit .env file to GitHub (it's in .gitignore)

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions is not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: EnvConfig.androidApiKey,
    appId: EnvConfig.androidAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    storageBucket: EnvConfig.storageBucket,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: EnvConfig.iosApiKey,
    appId: EnvConfig.iosAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    storageBucket: EnvConfig.storageBucket,
    iosBundleId: EnvConfig.iosBundleId,
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: EnvConfig.windowsApiKey,
    appId: EnvConfig.windowsAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    storageBucket: EnvConfig.storageBucket,
  );

  static FirebaseOptions get linux => FirebaseOptions(
    apiKey: EnvConfig.linuxApiKey,
    appId: EnvConfig.linuxAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    storageBucket: EnvConfig.storageBucket,
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: EnvConfig.macosApiKey,
    appId: EnvConfig.macosAppId,
    messagingSenderId: EnvConfig.messagingSenderId,
    projectId: EnvConfig.projectId,
    storageBucket: EnvConfig.storageBucket,
    iosBundleId: EnvConfig.iosBundleId,
  );
}

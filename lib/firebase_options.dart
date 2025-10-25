
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBXFcJZRlD7Glx8iElPYC-wFZZdR1qNGdk',
    appId: '1:455947563830:web:b9b48f265d23c0a9737997',
    messagingSenderId: '455947563830',
    projectId: 'kenko-1',
    authDomain: 'kenko-1.firebaseapp.com',
    storageBucket: 'kenko-1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDTgN8anE_zX1Y8Q7I6GrJVQuugbiejJ58',
    appId: '1:455947563830:android:9099a7de5be62ca8737997',
    messagingSenderId: '455947563830',
    projectId: 'kenko-1',
    storageBucket: 'kenko-1.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBXFcJZRlD7Glx8iElPYC-wFZZdR1qNGdk',
    appId: '1:455947563830:web:af61e5b099d8bbbc737997',
    messagingSenderId: '455947563830',
    projectId: 'kenko-1',
    authDomain: 'kenko-1.firebaseapp.com',
    storageBucket: 'kenko-1.firebasestorage.app',
  );
}

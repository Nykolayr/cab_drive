import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyDIwrtsFhuv8R3vy4FEPgecfUsLnKwVsfA",
            authDomain: "ydrive-a35d2.firebaseapp.com",
            projectId: "ydrive-a35d2",
            storageBucket: "ydrive-a35d2.firebasestorage.app",
            messagingSenderId: "1070996805603",
            appId: "1:1070996805603:web:0248ede9b532c50eebb2d6"));
  } else {
    await Firebase.initializeApp();
  }
}

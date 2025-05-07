import 'package:dawri_app/AboutPage.dart';
import 'package:dawri_app/Halthcarepage.dart';
import 'package:dawri_app/UsersPage.dart';
import 'package:dawri_app/cafepage.dart';
import 'package:dawri_app/firebase_options.dart';
import 'package:dawri_app/owner/controlPnal.dart';
import 'package:dawri_app/owner/onwerpage.dart';
import 'package:dawri_app/resturantPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'owner/OwnerSignupPage.dart';
import 'welcome.dart';
import 'login.dart';
import 'signup.dart';
import 'home.dart';
import 'setting.dart';
import 'forgot.dart';
import 'verification.dart';
import 'newPassword.dart';
import 'FeedBackPage.dart';
import 'admin/AdminPage.dart';
import 'admin/FeedbackPageAdmin.dart';
//import 're.dart'

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background notification received: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _getToken();

  runApp(MyApp());
}

Future<void> _getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    print("FCM Token: $token");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  } else {
    print("Failed to get FCM Token");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ), //Color(0xFFF7EFE5)), // Background color for all pages
      debugShowCheckedModeBanner: false,
      title: 'Dawri App',
      initialRoute: '/onbording_screen',
      onGenerateRoute: (settings) {
        if (settings.name == '/VerifyCodeScreen') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => VerifyCodeScreen(email: args['email']!),
          );
        } else if (settings.name == '/AccountUserr') {
          final user = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => UsersPage(),
          );
        }
        //builder:
        //(context) => UserPage(user: usertest);
        return null;
      },

      routes: {
        '/onbording_screen': (context) => OnboardingScreen(),
        '/welcome': (context) => Welcome(),
        '/login': (context) => Login(),
        '/forgot': (context) => Forgot(),
        '/signup': (context) => Signup(),
        '/ownerSignup': (context) => OwnerSignupPage(),
        '/home': (context) => HomePage(),
        '/setting': (context) => setting(),
        '/feedback': (context) => FeedBackPage(),
        '/AboutPage': (context) => AboutPage(),
        '/VerifyCodeScreen': (context) => VerifyCodeScreen(email: ''),
        '/new_password': (context) => Newpassword(),
        '/cafe': (context) => CafePage(),
        '/healthcare': (context) => Halthcarepage(),
        '/restaurant': (context) => RestaurantPage(),
        '/adminHP': (context) => AdminPage(),
        '/FeedbackAdmin': (context) => FeedbackPageAdmin(),
        '/ownerHP': (context) => OwnerPage(),
        //'/QueuesP': (context) => QueuesPage(),
        //'/notifications': (context) => NotificationsPage(),
        '/Controlp': (context) => controlPanel(),
      },
    );
  }
}

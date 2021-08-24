import 'package:chat_app/provider/login_loading_provider.dart';
import 'package:chat_app/provider/signup_loading_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/resources/firebase_repository.dart';
import 'package:chat_app/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginLoadingProvider()),
        ChangeNotifierProvider(create: (_) => SignupLoadingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter UI Challenge',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ),
        home: FirebaseRepository().getCurrentUser() == null
            ? OnboardingScreen()
            : HomeScreen(),
      ),
    );
  }
}

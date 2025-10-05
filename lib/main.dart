import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stock_register/firebase_options.dart';
import 'package:stock_register/providers/home_provider.dart';
import 'package:stock_register/providers/user_provider.dart';
import 'package:stock_register/screens/forms/user_login_form.dart';
import 'package:stock_register/screens/forms/user_signup_form.dart';
import 'package:stock_register/screens/splash_screen.dart';
import 'package:stock_register/utils/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
        ],
        child: const MyApp(),
      ),
    );
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'baloo',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      routes: {
        Routes.userLoginForm: (_) => UserLoginForm(),
        Routes.userSignupForm: (_) => UserSignupForm(),
      },
      home: SplashScreen(),
    );
  }
}

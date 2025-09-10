import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:polac_hub/pages/dashboard.dart';
import 'package:polac_hub/pages/forgot_page.dart';
import 'package:polac_hub/pages/login.dart';
import 'package:polac_hub/pages/sign_up.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PolacHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black54,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 57, 136, 98),
        ),
        primaryColor: Colors.greenAccent,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SignUp(),
          transition: Transition.rightToLeft, 
          transitionDuration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),

        GetPage(
          name: '/signup',
          page: () => const SignUp(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),

        GetPage(
          name: '/login',
          page: () => const Login(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),

        GetPage(
          name: '/forgot',
          page: () => const Forgot(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),

        GetPage(
          name: '/Dashboard',
          page: () => const Dashboard(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
      ],
    );
  }
}

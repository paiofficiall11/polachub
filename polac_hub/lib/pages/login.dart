import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:polac_hub/controllers/AppwriteController.dart';
import 'package:polac_hub/ui/button.dart';
import 'package:polac_hub/ui/primary_header.dart';
import 'package:polac_hub/ui/secondary_header.dart';
import 'package:polac_hub/ui/smallText.dart';
import "../ui/logoNormal.dart";

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Get the controller instance
  late final AppwriteController _controller;
  
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Text editing controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AppwriteController());
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Logo(),
                const SizedBox(height: 30),
                const PrimaryHeader(text: "Welcome back,"),
                const SizedBox(height: 8),
                const SecondaryHeader(
                  text: "Lets Sign you back in.",
                ),
                const SizedBox(height: 37),
               
                // Email TextField with validation
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(
                      FontAwesome.newspaper,
                      size: 16,
                      color: Colors.greenAccent,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 35,
                ),
                const SizedBox(height: 16),
                
                // Password TextField with validation
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(
                      FontAwesome.lock_solid,
                      size: 16,
                      color: Colors.greenAccent,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.greenAccent,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  maxLength: 35,
                ),
               
                const SizedBox(height: 17),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/forgot");
                        },
                        child: const Smalltext(text: "Forgot Password?"),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Login Button with Obx for loading state
                Obx(() => Button(
                  onTap: _controller.isLoading ? null : _handleLogin,
                  text: "Login",
                  height: 55,
                  width: Get.width,
                  color: const Color.fromARGB(255, 51, 119, 86),
                  loading: _controller.isLoading,
                )),

                const SizedBox(height: 170),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Get.toNamed("/signup");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Smalltext(text: "No Account Yet? "),
                        const Smalltext(
                          text: "Sign Up",
                          
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle login process
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with login
      await _controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}
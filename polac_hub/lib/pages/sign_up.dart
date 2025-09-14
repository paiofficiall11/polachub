import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import '../controllers/AppwriteController.dart';
import 'package:polac_hub/ui/button.dart';
import 'package:polac_hub/ui/primary_header.dart';
import 'package:polac_hub/ui/secondary_header.dart';
import 'package:polac_hub/ui/smallText.dart';
import "../ui/logoNormal.dart";

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Get the controller instance
  late final AppwriteController _controller;

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text editing controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _courseController;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(AppwriteController());
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _courseController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Logo(),
                const SizedBox(height: 20),
                const PrimaryHeader(text: "Let's Sign you up"),
                const SizedBox(height: 10),
                const SecondaryHeader(
                  text:
                      "Get all the latest updates, become a member of the Polac community.",
                ),
                const SizedBox(height: 30),

                // Name TextField
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Name",
                    prefixIcon: const Icon(
                      FontAwesome.address_card,
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
                  keyboardType: TextInputType.name,

                  maxLength: 35,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _courseController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please add your course';
                    }
                    if (value.trim().length < 2) {
                      return 'Course must be at least 3 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Course",
                    prefixIcon: const Icon(
                      FontAwesome.address_card,
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
                  keyboardType: TextInputType.name,

                  maxLength: 15,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Email TextField
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
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
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Password TextField
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
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
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Phone TextField
                TextFormField(
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Simple phone validation (you can make this more complex)
                    if (value.trim().length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Phone No.",
                    prefixIcon: const Icon(
                      FontAwesome.phone_solid,
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
                  keyboardType: TextInputType.phone,
                  maxLength: 35,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Get.toNamed("/forgot");
                    },
                    child: const Smalltext(text: "Forgot Password?"),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign Up Button with Obx for loading state
                Obx(
                  () => Button(
                    onTap: _controller.isLoading ? null : _handleSignUp,
                    text: "Sign Up",
                    height: 55,
                    width: Get.width * 0.9,
                    color: const Color.fromARGB(255, 51, 119, 86),
                    loading: _controller.isLoading,
                  ),
                ),
                const SizedBox(height: 40),

                // Already have account link
                InkWell(
                  onTap: () {
                    Get.toNamed("/login");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Smalltext(text: "Already have an account? "),
                      const Smalltext(text: "Sign In"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle sign up process
  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with sign up
      await _controller.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        course: _courseController.text
            .trim(), // You might want to add a course field or set a default
      );
    }
  }
}

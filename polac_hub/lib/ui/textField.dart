import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Textfield extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final Icon? icon;

  const Textfield({
    super.key,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.maxLength,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: Get.width,
        height: 68,
        child: TextField(
          
  style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 17,
          ),
          maxLength: maxLength,
          keyboardType: keyboardType,
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelStyle: GoogleFonts.montserrat(
              color: const Color.fromARGB(255, 73, 167, 121),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: icon,
            ),
            labelText: hintText,
            hintText: hintText,
            counterStyle: GoogleFonts.montserrat(
              color: Colors.greenAccent,
              fontSize: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 69, 163, 118),
                width: 1.7,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

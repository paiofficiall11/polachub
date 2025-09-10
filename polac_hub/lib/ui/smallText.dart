import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Smalltext extends StatelessWidget {
 final String text;
 const Smalltext({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w300,
          color: const Color.fromARGB(255, 169, 245, 201),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Bodytext extends StatelessWidget {
 final String text;
 const Bodytext({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: const Color.fromARGB(255, 241, 245, 243),
        ),
      ),
    );
  }
}

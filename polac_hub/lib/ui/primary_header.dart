import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryHeader extends StatelessWidget {
 final String text;
 const PrimaryHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color.fromARGB(255, 48, 165, 97),
          ),
        ),
      ),
    );
  }
}

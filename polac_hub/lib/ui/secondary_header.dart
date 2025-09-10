import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecondaryHeader extends StatelessWidget {
  final String text;

  const SecondaryHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 18.3,
          fontWeight: FontWeight.w400,
          color: const Color.fromARGB(255, 97, 126, 109),
        ),
      ),
    );
  }
}

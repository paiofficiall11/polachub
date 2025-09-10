import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileUI extends StatelessWidget {
   ProfileUI({super.key,required this.initials});
 String initials;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: const Color.fromARGB(172, 97, 218, 159),
      radius: 17,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

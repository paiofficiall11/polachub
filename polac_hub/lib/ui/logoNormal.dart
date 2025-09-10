import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6),
      child: Text("polacHub",style: GoogleFonts.orbitron(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color:  Colors.greenAccent,
      ),),
    );
  }
}
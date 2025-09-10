import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:polac_hub/ui/button.dart';
import 'package:polac_hub/ui/primary_header.dart';
import 'package:polac_hub/ui/secondary_header.dart';

class ExamsPage extends StatelessWidget {
  const ExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            const SizedBox(height: 50),
            _ExamsCard(),
            const SizedBox(height: 50),
            _PastQuestions(),
          ],
        ),
      ),
    );
  }
}

class _ExamsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: const Color.fromARGB(113, 18, 44, 31),
        border: Border.all(
          color: Colors.greenAccent.withOpacity(0.7),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(HeroIcons.academic_cap, color: Colors.greenAccent, size: 36),
          const SizedBox(height: 15),
          PrimaryHeader(text: "Mock test"),
          const SizedBox(height: 8),
          Text(
            "Begin academic testing now, from the comfort of your home.",
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Button(
            onTap: () {},
            text: "Start Test Now!",
            width: Get.width,
            height: 50,
          ),
          const SizedBox(height: 19),
        ],
      ),
    );
  }
}

class _PastQuestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 17),
        PrimaryHeader(
          text: "Past questions.",
        ),
        const SizedBox(height: 24),
        _PQItem("REGULAR COURSE 1 PQ", '2 MB download.'),
        _PQItem("REGULAR COURSE 2 PQ", '2 MB download.'),
        _PQItem("REGULAR COURSE 3 PQ", '2 MB download.'),
        _PQItem("REGULAR COURSE 4 PQ", '2 MB download.'),
        _PQItem("REGULAR COURSE 5 PQ", '2 MB download.'),
        const SizedBox(height: 24),
      ],
    );
  }
}

Widget _PQItem(String title, String sub) {
  return Padding(
    padding: const EdgeInsets.all(7.0),
    child: ListTile(
      leading: const Icon(
        HeroIcons.document,
        size: 20,
        color: Color.fromARGB(255, 102, 233, 169),
      ),
      title: Text(title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          )),
      subtitle: Text(sub,
          style: const TextStyle(
            color: Colors.white70,
          )),
      trailing: const Icon(
        HeroIcons.arrow_down_circle,
        size: 22,
        color: Color.fromARGB(255, 102, 233, 169),
      ),
    ),
  );
}

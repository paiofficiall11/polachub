import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Backbutton extends StatelessWidget {
    final IconData icon;

    const Backbutton({super.key, required this.icon});

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            width: 55,
            height: 55,
            child: Material(
                color: const Color.fromARGB(255, 13, 240, 130),
                shape: const CircleBorder(),
                child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Get.back(),
                    child: Center(
                        child: Icon(icon, color: Colors.white, size: 30, ),
                    ),
                ),
            ),
        );
    }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:polac_hub/ui/button.dart';
import 'package:polac_hub/ui/primary_header.dart';
import 'package:polac_hub/ui/secondary_header.dart';
import 'package:polac_hub/ui/smallText.dart';
import 'package:polac_hub/ui/textField.dart';
import "../ui/logoNormal.dart";

class Forgot extends StatelessWidget {
  const Forgot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Logo(),
              SizedBox(height: 30),
              PrimaryHeader(text: "Forgot Password?,"),
              SizedBox(height: 8),
              SecondaryHeader(
                text:
                    "Lets recover your account.",
              ),
              SizedBox(height: 37),
             
         
              Textfield(
                hintText: "Email",
                keyboardType: TextInputType.emailAddress,
                maxLength: 35,
                icon: Icon(
                  FontAwesome.newspaper,
                   size: 16,
                  color: Colors.greenAccent,

                ),
              ),

              SizedBox(height: 30),
              Button(
                onTap: () {},
                text: "Continue",
                height: 55,
                width: Get.width,
                color: const Color.fromARGB(255, 51, 119, 86),
              ),

              SizedBox(height: 170),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                  Get.toNamed("/");
                },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Smalltext(text: "No Account Yet? "),
                      Smalltext(text: "Sign Up"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

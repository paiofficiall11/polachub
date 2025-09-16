import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:polac_hub/pages/exams_page.dart';
import 'package:polac_hub/pages/homepage.dart';
import 'package:polac_hub/pages/explore_page.dart';

import 'package:polac_hub/ui/logoNormal.dart';
import 'package:polac_hub/ui/profileUi.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ExplorePage(),
    const ExamsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      toolbarHeight: 80,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Padding(
        padding: const EdgeInsets.all(15.3),
        child: const Logo(),
      ),
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Row(
          children: [
            
             IconButton(
                  icon: const Icon(HeroIcons.bell,
                      size: 27, color: Colors.greenAccent),
                  onPressed: () {
                    // Handle notification tap
                  },
                ),
          ],
        ),
      ),
             
      leadingWidth: 40,
      actions: [
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: Row(

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             
              
              
              const SizedBox(width: 8),
               ProfileUI(initials: "AM"),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation:0,
        backgroundColor: Colors.transparent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(HeroIcons.home_modern,size: 25,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(HeroIcons.magnifying_glass_circle,size: 25,),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(HeroIcons.academic_cap,size: 25,),
            label: 'Exams',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.greenAccent,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold,color:Colors.greenAccent),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal,color:Colors.white),
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

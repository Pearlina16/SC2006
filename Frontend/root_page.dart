import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lab4_frontend/activities_page.dart';
import 'package:lab4_frontend/home_page.dart';
import 'package:lab4_frontend/profile_page.dart';
import 'package:lab4_frontend/rewards_page.dart';
import 'package:lab4_frontend/search_page.dart';
import 'package:google_fonts/google_fonts.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key, required this.params});

  final LatLng params;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  int currentPage = 0;
  // List<Widget> pages = const [
  //   HomePage(data: LatLng(1.3483, 103.6831)),
  //   SearchPage(),
  //   RewardsPage(),
  //   ActivitesPage(),
  //   ProfilePage()
  // ];
  @override
  Widget build(BuildContext context) {

    final params = widget.params;
    final double lat = params.latitude;
    final double long = params.longitude;

    List<Widget> pages = [
    HomePage(data: LatLng(lat, long)),
    const SearchPage(),
    const RewardsPage(),
    const ActivitesPage(),
    const ProfilePage()
  ];
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'WATTWAY',
            style: GoogleFonts.squadaOne(
              textStyle: const TextStyle(
                fontSize: 30,
                color: Colors.black,
                //color: Color.fromARGB(255, 2, 127, 106),
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
              ),
              ),
              ),
      ),
      body: pages[currentPage],
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     debugPrint('Floating Action Button');
      //   },
      //   child: const Icon(Icons.add),
      // ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'Rewards'),
          NavigationDestination(icon: Icon(Icons.local_activity_sharp), label: 'Activites'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (int index){
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}


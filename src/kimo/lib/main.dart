import 'package:flutter/material.dart';
import 'package:kimo/firebase_options.dart';
import 'package:kimo/screens/home_tab.dart';
import 'package:kimo/widgets/navigation_widgets.dart';
import 'package:kimo/screens/wishlist_tab.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/screens/messages_tab.dart';
import 'package:kimo/screens/trips_tab.dart';
import 'package:kimo/screens/account_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kimo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 22, 158, 255)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedTab = 0;
  User ?currentUser;
  List<Widget> tabs = [];
  Future<Position> ?geolocation;
  void _onChangedTab(int newTab) {
    setState(() {
      _selectedTab = newTab;
    });
  }


  Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    currentUser = user;
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  if (geolocation == null) {
      geolocation = determinePosition();
  }
    if (tabs.length == 0) {
    tabs = [HomeTab(geolocation: geolocation!, user: currentUser,), WishlistTab(user: currentUser,), MessagesTab(user: currentUser,), TripsTab(user: currentUser,), AccountTab(user: currentUser,)];}
    return Scaffold(
      body: SafeArea(
        
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: tabs[_selectedTab]),
            Container(
              decoration: BoxDecoration(boxShadow: [BoxShadow(color: greySelected, blurRadius: 10, spreadRadius: 10)], color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    
                    GestureDetector(onTap: () {_onChangedTab(0);}, child: CustomNavigationDestination(selected: _selectedTab == 0, svgPathSelected: "assets/icons/navbar-home-selected.svg" , svgPath: "assets/icons/navbar-home.svg", label: "HOME",)),
                    GestureDetector(onTap: () {_onChangedTab(1);}, child: CustomNavigationDestination(selected: _selectedTab == 1, svgPathSelected: "assets/icons/navbar-wishlist-selected.svg" , svgPath: "assets/icons/navbar-wishlist.svg", label: "WISHLIST",)),
                    GestureDetector(onTap: () {_onChangedTab(2);}, child: CustomNavigationDestination(selected: _selectedTab == 2, svgPathSelected: "assets/icons/navbar-messages-selected.svg" , svgPath: "assets/icons/navbar-messages.svg", label: "MESSAGES",)),
                    GestureDetector(onTap: () {_onChangedTab(3);}, child: CustomNavigationDestination(selected: _selectedTab == 3, svgPathSelected: "assets/icons/navbar-trips-selected.svg" , svgPath: "assets/icons/navbar-trips.svg", label: "TRIPS",)),
                    GestureDetector(onTap: () {_onChangedTab(4);}, child: CustomNavigationDestination(selected: _selectedTab == 4, svgPathSelected: "assets/icons/navbar-profile-selected.svg" , svgPath: "assets/icons/navbar-profile.svg", label: "ACCOUNT",)),
                    ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


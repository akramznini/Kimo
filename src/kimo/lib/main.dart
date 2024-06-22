import 'package:flutter/material.dart';
import 'package:kimo/screens/home_tab.dart';
import 'package:kimo/widgets/navigation_widgets.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const Color greySelected = Color.fromARGB(255, 228, 228, 228);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kimo',
      theme: ThemeData(
        
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

  void _onChangedTab(int newTab) {
    setState(() {
      _selectedTab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    List<Widget> tabs = [HomeTab(), Text("1"), Text("2"), Text("3"), Text("4")];
    return Scaffold(
      body: SafeArea(
        
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: tabs[_selectedTab]),
            Container(
              decoration: BoxDecoration(boxShadow: [BoxShadow(color: MyApp.greySelected, blurRadius: 10, spreadRadius: 10)], color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    
                    GestureDetector(onTap: () {_onChangedTab(0);}, child: CustomNavigationDestination(selected: _selectedTab == 0, svgPathSelected: "assets/icons/navbar-home-selected.svg" , svgPath: "assets/icons/navbar-home.svg", label: "HOME",)),
                    GestureDetector(onTap: () {_onChangedTab(1);}, child: CustomNavigationDestination(selected: _selectedTab == 1, svgPathSelected: "assets/icons/navbar-wishlist-selected.svg" , svgPath: "assets/icons/navbar-wishlist.svg", label: "WISHLIST",)),
                    GestureDetector(onTap: () {_onChangedTab(2);}, child: CustomNavigationDestination(selected: _selectedTab == 2, svgPathSelected: "assets/icons/navbar-messages-selected.svg" , svgPath: "assets/icons/navbar-messages.svg", label: "MESSAGES",)),
                    GestureDetector(onTap: () {_onChangedTab(3);}, child: CustomNavigationDestination(selected: _selectedTab == 3, svgPathSelected: "assets/icons/navbar-trips.svg" , svgPath: "assets/icons/navbar-trips.svg", label: "TRIPS",)),
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


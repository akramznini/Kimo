import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kimo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 22, 158, 255)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedTab = 0;

  void _onChangedTab(int newTab) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _selectedTab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color greySelected = Color.fromARGB(255, 228, 228, 228);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                CarPreviewContainer(),
                CarPreviewContainer(),
                CarPreviewContainer(),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  
                  GestureDetector(onTap: () {_onChangedTab(0);}, child: NavigationDestination(selected: _selectedTab == 0, svgPathSelected: "assets/icons/navbar-home-selected.svg" , svgPath: "assets/icons/navbar-home.svg", label: "HOME",)),
                  GestureDetector(onTap: () {_onChangedTab(1);}, child: NavigationDestination(selected: _selectedTab == 1, svgPathSelected: "assets/icons/navbar-wishlist-selected.svg" , svgPath: "assets/icons/navbar-wishlist.svg", label: "WISHLIST",)),
                  GestureDetector(onTap: () {_onChangedTab(2);}, child: NavigationDestination(selected: _selectedTab == 2, svgPathSelected: "assets/icons/navbar-messages-selected.svg" , svgPath: "assets/icons/navbar-messages.svg", label: "MESSAGES",)),
                  GestureDetector(onTap: () {_onChangedTab(3);}, child: NavigationDestination(selected: _selectedTab == 3, svgPathSelected: "assets/icons/navbar-trips.svg" , svgPath: "assets/icons/navbar-trips.svg", label: "TRIPS",)),
                  GestureDetector(onTap: () {_onChangedTab(4);}, child: NavigationDestination(selected: _selectedTab == 4, svgPathSelected: "assets/icons/navbar-profile-selected.svg" , svgPath: "assets/icons/navbar-profile.svg", label: "ACCOUNT",)),
                  ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarPreviewContainer extends StatelessWidget {
  const CarPreviewContainer({
    super.key,  });



  @override
  Widget build(BuildContext context) {
    Image carImage = Image.asset('assets/images/car-volkswagen.jpg', height: 120, width: 160, fit: BoxFit.cover,);
    String carName = "Volkswagen Beetle";
    return IntrinsicWidth(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(22)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              carImage,
              CarInfoContainer(carName: carName, rating: 4.6, nbReviews: 122,)
            ],),
          ),
        ),
      ),
    );
  }
}

class CarInfoContainer extends StatelessWidget {
  const CarInfoContainer({
    super.key,
    required this.carName,
    required this.rating,
    required this.nbReviews
  });

  final String carName;
  final double rating;
  final int nbReviews;
  
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle lightRoboto = GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w300, color: Color.fromARGB(255, 84, 84, 84));
    return Padding(
      padding: const EdgeInsets.only(top:4, bottom:4, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(carName, style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),),
          Row(
            children: [
              Text(rating.toString(), style: lightRoboto),
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2),
                child: Icon(Icons.star, color: theme.primaryColor, size: 12),
              ),
              Text("(${nbReviews.toString()} reviews)", style: lightRoboto,)
            ],
          )
        ],
      ),
    );
  }
}

class NavigationDestination extends StatelessWidget {
  final bool selected;
  final String svgPath;
  final String label;
  final String svgPathSelected;
  const NavigationDestination({
    super.key,
    required this.selected,
    required this.svgPath,
    required this.label,
    required this.svgPathSelected
  });

  @override
  Widget build(BuildContext context) {
    final Color greySelected = Color.fromARGB(255, 228, 228, 228);
    return Container(child: Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, left: 8, right: 8),
      child: Column(children: <Widget>[SvgPicture.asset(selected ? svgPathSelected : svgPath, height: 35, width: 35,), Text(label, style: GoogleFonts.roboto(fontSize: 8, fontWeight: FontWeight.bold)),]),
    ), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: selected? greySelected : null),);
  }
}


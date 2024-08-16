import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/screens/sign_in_page.dart';
import 'package:kimo/screens/sign_in_page2.dart';
import 'package:kimo/screens/sign_up_page.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kimo/utils/helper_functions.dart';
import 'package:kimo/widgets/widgets.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({
    super.key,
    required this.user
  });
  final User ?user;
  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  void showSignInPage(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {return SignInPage3();}));
  }
  late bool isSignedIn;
  @override
  Widget build(BuildContext context) {
    isSignedIn = (widget.user != null);
    print("user signed:  $isSignedIn");
    Widget signedOutPage = Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12, top: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Account", style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),),
          Text("Log in to start planning your next trip.", style: GoogleFonts.roboto(),),
          Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 16),
            child: Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage())
                  );*/
                  showSignInPage();
                }, 
                child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Text("Log in", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),),
                                  ), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
            ),
          ),
          Row(
            children: [
              Text("Don't have an account?", style: GoogleFonts.roboto(),),
              SizedBox(width: 6,),
              GestureDetector(onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpPage()));} ,child: Text("Sign up", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, textStyle: TextStyle(decoration: TextDecoration.underline)),)),
            ],
          )
        ],
      ),
    );

    return isSignedIn ? Column(
      children: [
        ElevatedButton(onPressed: () async {
        await FirebaseAuth.instance.signOut();
        setState(() {
          isSignedIn = false;
        });
        }, child: Text("set info")),
        Text("UID: ${widget.user?.uid}"),
        Text("displayName: ${widget.user?.displayName}"),
        Text("photoURL: ${widget.user?.photoURL}"),
      ],
    ) : signedOutPage;
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/screens/sign_in_page.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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
  void showSignInBottomSheet(){
showModalBottomSheet(context: context, isScrollControlled: true,builder: (BuildContext context){
                    return FractionallySizedBox(heightFactor: 0.85,child: SignInPage());
                  });
  }
  
  @override
  Widget build(BuildContext context) {
    
    bool isSignedIn = (widget.user != null);
    print(isSignedIn);
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
                  showSignInBottomSheet();
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
              GestureDetector(onTap: (){showSignInBottomSheet();} ,child: Text("Sign up", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, textStyle: TextStyle(decoration: TextDecoration.underline)),)),
            ],
          )
        ],
      ),
    );

    return isSignedIn ? Column(
      children: [
        ElevatedButton(onPressed: () async {
        print("button pressed");
         await widget.user?.updateDisplayName("Akram Znini");
         FirebaseFirestore db = FirebaseFirestore.instance;
         await db.collection("users").get().then((event) {
          for (var doc in event.docs) {
            print("${doc.id} => ${doc.data()}");
                                      }
                                                          });
        final car = <String, dynamic>{
          "model" : "Picassou"
        };
        db.collection("cars").add(car);
        }, child: Text("set info")),
        Text("UID: ${widget.user?.uid}"),
        Text("displayName: ${widget.user?.displayName}"),
        Text("photoURL: ${widget.user?.photoURL}")
      ],
    ) : signedOutPage;
  }
}
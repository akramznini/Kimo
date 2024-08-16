import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:kimo/main.dart';
import 'package:kimo/widgets/buttons.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Stack(
            children: [
              SignInScreen(
                providers: [
                  EmailAuthProvider(), // new
                ],
              ),
              Positioned(child: CustomButtonWhite(iconSize: 20, icon:Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},), top: 15, left: 15,)
            ],
          );
        }
        return const MyHomePage();
      },
    );
  }
}
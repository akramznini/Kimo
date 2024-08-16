import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/main.dart';
import 'package:kimo/screens/search_results_page.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/widgets.dart';


class PasswordResetPage extends StatelessWidget {
  PasswordResetPage({
    super.key,
  });
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomButtonWhite(iconSize: 20, icon:Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},),
                )
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Container(
                    width: 240,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabTitle(title: "Reset Password", size: 24,),
                                      SizedBox(height: 40),
                          
                          Container(width: 240, child: CustomTextFormField(label: Text("Email"), controller: _emailController, keyboardType: TextInputType.emailAddress, hintText: 'example@domain.com', validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your email';
      }
      // Regular expression for validating an email address
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
      return null;
        },)),
                          
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(onPressed: () async {
                    if (_formKey.currentState!.validate()) {
        try {
          await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailController.text,
          );
          // Notify user that the reset email has been sent
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password reset email sent')),
          );
          Navigator.of(context).pop();
        } on FirebaseAuthException catch (e) {
          // Handle errors
          String errorMessage;
          if (e.code == 'user-not-found') {
            errorMessage = 'No user found for that email.';
          } else {
            errorMessage = 'An error occurred. Please try again.';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
                  }, child: Container(height: 20, width: 120, child: Center(child: Text("Reset Password", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
                  SizedBox(height: 100,)
                ]
                
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/main.dart';
import 'package:kimo/screens/password_reset_page.dart';
import 'package:kimo/screens/search_results_page.dart';
import 'package:kimo/screens/sign_up_page.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/widgets.dart';


class SignInPage3 extends StatelessWidget {
  SignInPage3({
    super.key,
  });
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        TabTitle(title: "Sign In", size: 24,),
                                    SizedBox(height: 40),
                        Row(
                          children: [
                            Text("Don't have an account?", style: lightRoboto,),
                            SizedBox(width: 10,),
                            GestureDetector(child: Text("Sign Up", style: robotoRegularPrimary,), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpPage())),)
                          ],
                        ), 
                        SizedBox(height: 20,),
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
                        SizedBox(height: 20,),
                        Container(width: 240, child: CustomTextFormField(label: Text("Password"), obscureText: true, controller: _passwordController, validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    // Regular expression to check the password requirements
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
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
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Successfully logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()), // Replace HomePage with your home page
        );
      } on FirebaseAuthException catch (e) {
        // Handle login errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your email or password is incorrect.")),
        );
      }
                  }
                }, child: Container(height: 20, width: 120, child: Center(child: Text("SIGN IN", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
                SizedBox(height: 20,),
                GestureDetector(child: Text("Forgot Password", style: robotoRegularPrimary,), onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) => PasswordResetPage()));},),
                SizedBox(height: 100,)
              ]
              
            ),
          ),
          
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/main.dart';
import 'package:kimo/screens/password_reset_page.dart';
import 'package:kimo/screens/search_results_page.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/widgets.dart';


class SignUpPage extends StatefulWidget {
  SignUpPage({
    super.key,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _passwordConfirmationController = TextEditingController();

  final _firstNameController = TextEditingController();

  final _lastNameController = TextEditingController();

  final _phoneNumberController = TextEditingController();

  final _dobController = TextEditingController();

  late DateTime dateOfBirth;

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
                        TabTitle(title: "Register", size: 24,),
                                    SizedBox(height: 40), 
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Container(width: 100, child: CustomTextFormField(label: Text("First Name"), controller: _firstNameController, 
                            validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                     }
                                    return null;
                                      },),),
                            SizedBox(width: 40,),
                            Container(width: 100, child: CustomTextFormField(label: Text("Last Name"), controller: _lastNameController, 
                            validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                     }
                                    return null;
                                      },),),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Container(width: 100, child: CustomTextFormField(label: Text("Phone Number"), controller: _phoneNumberController, keyboardType: TextInputType.phone,
                            validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Regular expression to validate the phone number
                  final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },),),
                            SizedBox(width: 40,),
                            InkWell(
                              onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _dobController.text = date.toLocal().toString().split(' ')[0];
                    });
                    
                  }
                },
                              child: IgnorePointer(
                                child: Container(width: 100, child: CustomTextFormField(label: Text("Date of Birth"), controller: _dobController,
                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter your date of birth';
                                                  }
                                                  return null;
                                                },),),
                              ),
                            ),
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
                        SizedBox(height: 20,),
                        
                        Container(width: 240, child: CustomTextFormField(label: Text("Re-enter password"), obscureText: true, controller: _passwordConfirmationController, validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please re-enter your password';
                              }

    // Regular expression to check the password requirements
                              if (value != _passwordController.text) {
                                return "Passwords don't match";
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
                      UserCredential userCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text);

                      // Store additional user info in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .add({
                        'UID': userCredential.user!.uid,
                        'first_name': _firstNameController.text,
                        'last_name': _lastNameController.text,
                        'phone_number': _phoneNumberController.text,
                        'date_of_birth': DateTime.parse(_dobController.text),
                        'email': _emailController.text,
                        'nb_reviews': 0,
                        "nb_trips": 0,
                        "rating": 0,
                        "profile_picture_url": "https://firebasestorage.googleapis.com/v0/b/kimo-3f95e.appspot.com/o/profile_pictures%2Fprofile-circle-svgrepo-com.png?alt=media&token=0d61672e-31c2-4416-8ac6-4c6144f5bb85",
                        "wishlist": []
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Your account was successfully created! Welcome to Kimo!")),
        );
                      // Navigate to home page or show success message
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    }
                    catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("There was a problem during registration. Please try again.")),
        );
                    }
                  }
                  
                }, child: Container(height: 20, width: 120, child: Center(child: Text("REGISTER", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
                SizedBox(height: 100,)
              ]
              
            ),
          ),
          
        ],
      ),
    );
  }
}
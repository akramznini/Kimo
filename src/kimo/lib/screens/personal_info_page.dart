import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/user_data.dart';
import 'package:kimo/main.dart';
import 'package:kimo/screens/password_reset_page.dart';
import 'package:kimo/screens/search_results_page.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/widgets.dart';


class PersonalInfoPage extends StatefulWidget {
  PersonalInfoPage({
    super.key,
    required this.userData
  });
  final UserData userData;
  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _firstNameController = TextEditingController();

  final _lastNameController = TextEditingController();

  final _phoneNumberController = TextEditingController();

  final _dobController = TextEditingController();

  late DateTime dateOfBirth;

  String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text; // Return empty string if input is empty
  }

  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController.text = widget.userData.email;
    _firstNameController.text = widget.userData.firstName;
    _lastNameController.text = widget.userData.lastName;
    _phoneNumberController.text = widget.userData.phoneNumber;
    _dobController.text = widget.userData.dateOfBirth.toLocal().toString().split(' ')[0];
  }
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
                          TabTitle(title: "Edit Personal Info", size: 24,),
                          SizedBox(height: 12,),
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
                          SizedBox(height: 10,),
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
                          SizedBox(height: 10,),
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
                          SizedBox(height: 10,),
                        
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                                        title: Text('Confirm Changes', style: robotoLargerBlack,),
                                        content: Text("Do you want to apply the changes?"),
                                        actions: [
                                          TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Cancel", style: robotoLargePrimary,),),
                                          TextButton(onPressed: () async {
                                            try {
                        // Store additional user info in Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userData.docId)
                            .update({
                          'first_name': capitalizeFirstLetter(_firstNameController.text),
                          'last_name': capitalizeFirstLetter(_lastNameController.text),
                          'phone_number': _phoneNumberController.text,
                          'date_of_birth': DateTime.parse(_dobController.text),
                          'email': _emailController.text,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Info changed successfully!")),
          );
                        // Navigate to home page or show success message
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      }
                      catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("There was a problem while applying changes.")),
          );
                      }
                                            Navigator.popUntil(context, (route) => route.isFirst);
                                          }, child: Text("Apply", style: robotoLargePrimary)),
                                        ],
                                      );
                      });
                      
                    }
                    
                  }, child: Container(height: 20, width: 120, child: Center(child: Text("APPLY", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
                  
                ]
                
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
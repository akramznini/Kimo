import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kimo/classes/user_data.dart';
import 'package:kimo/main.dart';
import 'package:kimo/screens/search_results_page.dart';
import 'package:kimo/utils/theme_values.dart';
import 'package:kimo/widgets/buttons.dart';
import 'package:kimo/widgets/widgets.dart';


class SecuritySettingsPage extends StatefulWidget {
  SecuritySettingsPage({
    super.key,
    required this.userData
  });
  final UserData userData;

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();

  final _passwordConfirmationController = TextEditingController();

  final _oldPasswordController = TextEditingController();

  Future<bool> reauthenticateUser(String email, String password) async {
  try {
    // Get the currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user is signed in.');
      return false;
    }

    // Create a credential using the provided email and password
    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

    // Re-authenticate the user
    await user.reauthenticateWithCredential(credential);
    return true;
  } on FirebaseAuthException catch (e) {
    print(e);
    return false;
  }
}

  Future<void> changePassword(String newPassword) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('No user is signed in.');
    return;
  }

  try {
    // Update the password
    await user.updatePassword(newPassword);
    print('Password changed successfully.');
  } on FirebaseAuthException catch (e) {
    print('Failed to change password: $e');
  }
}

  void updatePasswordProcess(String email, String currentPassword, String newPassword) async {
  bool reauthenticated = await reauthenticateUser(email, currentPassword);

  if (reauthenticated) {
    await changePassword(newPassword);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Wrong password.")),
          );
  }
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
                          TabTitle(title: "Change Password", size: 24,),
                                      SizedBox(height: 40),
                          
        Container(width: 240, child: CustomTextFormField(label: Text("Current password"), obscureText: true, controller: _oldPasswordController, validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
      
      // Regular expression to check the password requirements
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                  }
      
                                return null;
                                },)),
        SizedBox(height: 10,),
                          Container(width: 240, child: CustomTextFormField(label: Text("New password"), obscureText: true, controller: _passwordController, validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
      
      // Regular expression to check the password requirements
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                  }
      
                                return null;
                                },)),
                          SizedBox(height: 10,),
                          
                          Container(width: 240, child: CustomTextFormField(label: Text("Re-enter new password"), obscureText: true, controller: _passwordConfirmationController, validator: (value) {
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
                    updatePasswordProcess(widget.userData.email, _oldPasswordController.text, _passwordController.text);
      }
                  }, child: Container(height: 20, width: 120, child: Center(child: Text("Change Password", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
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
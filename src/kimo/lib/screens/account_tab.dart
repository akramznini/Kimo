import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kimo/classes/user_data.dart';
import 'package:kimo/main.dart';
import 'package:kimo/screens/personal_info_page.dart';
import 'package:kimo/screens/security_settings_page.dart';
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
    required this.user,
    required this.goToTab
  });
  final void Function(int) goToTab;
  final User ?user;
  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final ImagePicker _picker = ImagePicker();
  late String imgUrl;
  late Future<UserData> userDataFuture;
  late UserData userData;
  var db = FirebaseFirestore.instance;
  late bool isSignedIn;
  Future<UserData> fetchUserData() async {

    var querySnapshot = await db.collection("users").where("UID", isEqualTo: widget.user!.uid).get();
    UserData userData = UserData.fromFirestore(querySnapshot.docs.first);
    return userData;
    
    
  }

  Future<XFile?> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    return pickedImage;
  }
  Future<void> _uploadImage(File imageFile) async {
    try {
      // Create a reference to the Firebase Storage bucket
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child('profile_pictures/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = ref.putFile(imageFile);

      // Get the download URL
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      userData.profilePictureUrl = downloadUrl;
      await db.collection("users").doc(userData.docId).update(userData.toFirestore());
      setState(() {
        imgUrl = downloadUrl;
      });

      print('File uploaded successfully. Download URL: $imgUrl');
    } on FirebaseException catch (e) {
      print('Failed to upload image: $e');
    }
  }
  void showSignInPage(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {return SignInPage3();}));
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSignedIn = widget.user != null;
    if (widget.user != null) {
      userDataFuture = fetchUserData();
    }
    
  }
  
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
                child: Text("SIGN IN", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),),
                                  ), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),),
            ),
          ),
          Row(
            children: [
              Text("Don't have an account?", style: GoogleFonts.roboto(),),
              SizedBox(width: 6,),
              GestureDetector(onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpPage()));} ,child: Text("Register", style: robotoRegularBoldPrimary,)),
            ],
          )
        ],
      ),
    );
    return isSignedIn ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          TabTitle(title: "Account"),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(future: userDataFuture, builder: (context, snapshot) {
                if (snapshot.hasData) {
                  userData = snapshot.data!;
                  imgUrl = userData.profilePictureUrl;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                        ElevatedButton(onPressed: () {}, child: Container(height: 20, width: 115, child: Center(child: Text("Switch to host mode", style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: onPrimary),)
                      ],),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          ClipRRect(
                                                borderRadius: BorderRadius.circular(20),
                                                child: Image.network(imgUrl, width: 60, height: 60, fit: BoxFit.cover,),),
                          SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text("${userData.firstName} ${userData.lastName}", style: boldRobotoBlackRegular,),
                            GestureDetector(onTap: () async {
                              XFile? _image = await _pickImage();
                              if (_image != null) {
                                _uploadImage(File(_image!.path));
                              }
                    
                            }, child: Text("Edit profile picture", style: robotoRegularBoldPrimary,),)
                          ],),
                    
                        ],
                      ),
                      SizedBox(height: 20,),
                      Expanded(child: GestureDetector(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) {return PersonalInfoPage(userData: userData);}));}, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: greySelected, width: 0.5), boxShadow: [BoxShadow(blurRadius: 2, spreadRadius: 0, color: Color.fromARGB(136, 158, 158, 158), offset: Offset(0, 4))], color: Colors.white), height: 60, child: Stack(children: [Positioned(child: Text("Personal Info", style: boldRobotoBlackRegular,), top: 8, left: 8,)],),))),
                      SizedBox(height: 20,),
                      Expanded(child: GestureDetector(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) {return SecuritySettingsPage(userData: userData);}));}, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: greySelected, width: 0.5), boxShadow: [BoxShadow(blurRadius: 2, spreadRadius: 0, color: Color.fromARGB(136, 158, 158, 158), offset: Offset(0, 4))], color: Colors.white), height: 60, child: Stack(children: [Positioned(child: Text("Login & Security", style: boldRobotoBlackRegular,), top: 8, left: 8,)],),))),
                      SizedBox(height: 20,),
                      Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: greySelected, width: 0.5), boxShadow: [BoxShadow(blurRadius: 2, spreadRadius: 0, color: Color.fromARGB(136, 158, 158, 158), offset: Offset(0, 4))], color: Colors.white), height: 60, child: Stack(children: [Positioned(child: Text("Payments", style: boldRobotoBlackRegular,), top: 8, left: 8,)],),)),
                      SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                           ElevatedButton(onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  setState(() {
                                    isSignedIn = false;
                                  });
                                  }, child: Container(height: 20, width: 50, child: Center(child: Text("Log out", style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),))), style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 181, 45, 36)),)
                        ],
                      )
                    ],),
                  );
                }
                else {
                  return CenteredCircularProgressIndicator();
                }
              },),
            )),

        ],) : signedOutPage;
  }
}


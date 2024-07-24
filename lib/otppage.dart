// import 'dart:html';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/LoginPage.dart';

// class OTPScreen extends StatelessWidget {
//   const OTPScreen({super.key});

//   @override
//   Widget build(BuildContext context)=>Scaffold(
//     body:StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//        builder: (context,snapshot){
//         if(snapshot.hasData){
//           return VerifyEmail();
//         }else{
//           return OTPScreen();
//         }
//        }));
// }
 

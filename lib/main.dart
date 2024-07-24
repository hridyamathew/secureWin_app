import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_application_1/LoginPage.dart';
import 'package:flutter_application_1/SignupPage.dart';
import 'package:flutter_application_1/VerifyEmail.dart';
import 'package:flutter_application_1/appopeningpage.dart';
import 'package:flutter_application_1/lottery_service.dart';
import 'package:flutter_application_1/buyer_page.dart';
import 'package:flutter_application_1/expired_tickets_page.dart';
import 'package:flutter_application_1/buyer_profile_page.dart';
import 'package:flutter_application_1/firebase_core/firebase_core.dart';
import 'package:flutter_application_1/lottery_service.dart';
import 'package:flutter_application_1/otppage.dart';
import 'package:flutter_application_1/sellerProfilepage.dart';
import 'firebase_options.dart';
//import 'package:flutter_application_1/LoginPage.dart' ;
// import 'package:flutter_application_1/SignupPage.dart' as signup;
import 'package:flutter_application_1/seller_page.dart';
//import 'package:flutter_application_1/buyer_page.dart' ;
//import 'package:flutter_application_1/expired_tickets_page.dart' as expired_tickets;
//import 'package:flutter_application_1/buyer_profile_page.dart' as buyer_profile;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AppOpeningPage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/seller': (context) => SellerPage(
              username: '',
            ),
        '/buyer': (context) => BuyerPage(),
        '/verifyEmail': (context) => VerifyEmailPage(
              name: '',
              email: '',
              district: '',
              mobile: '',
              userType: '',
              dob: DateTime(1990, 1, 1),
            ),
        '/expiredTickets': (context) => ExpiredTicketsPage(),
        '/buyerProfile': (context) => BuyerProfilePage(),
        '/SellerProfilePage': (context) => SellerProfilePage(
              userId: '',
            ),
      },
    );
  }
}

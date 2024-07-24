import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  final String name;
  final String email;
  final String district;
  final String mobile;
  final String userType;
  final String? agencyNumber;
  final DateTime dob;

  VerifyEmailPage({
    required this.name,
    required this.email,
    required this.district,
    required this.mobile,
    required this.userType,
    this.agencyNumber,
    required this.dob,
  });

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isEmailVerified = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (_) => _checkEmailVerified());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          setState(() {
            _isEmailVerified = true;
          });

          // Store user data in Firestore after email verification
          await _storeUserDataInFirestore(
            widget.name,
            widget.email,
            widget.district,
            widget.mobile,
            widget.userType,
            widget.agencyNumber,
            widget.dob,
          );

          // Navigate to the login page
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        print('Email verification sent!');
      }
    } catch (e) {
      print('Error resending email verification: $e');
    }
  }

  Future<void> _storeUserDataInFirestore(
    String name,
    String email,
    String district,
    String mobile,
    String userType,
    String? agencyNumber,
    DateTime dob,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        Timestamp dobTimestamp = Timestamp.fromDate(dob);

        Map<String, dynamic> userData = {
          'name': name,
          'email': email,
          'district': district,
          'mobile': mobile,
          'userType': userType,
          'dob': dobTimestamp,
        };

        if (userType == 'Seller') {
          userData['agencyNumber'] = agencyNumber;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
      } else {
        print('User email not verified or user is null');
      }
    } catch (e) {
      print('Error storing user data in Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        //style: TextStyle(color: Colors.white),

        backgroundColor: Color.fromARGB(255, 0, 0, 0),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromRGBO(4, 0, 75, 1), Color(0xffB760D5)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'A verification email has been sent to your email address. Please verify your email before continuing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              _isEmailVerified
                  ? Text(
                      'Email verified!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : CircularProgressIndicator(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _resendVerificationEmail,
                    child: Text('Resend Email'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 24, 200, 118),
                    ),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

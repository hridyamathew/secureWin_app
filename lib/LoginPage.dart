import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'Forgotpassword.dart';
import 'buyer_page.dart';
import 'seller_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  // Function for user login
  userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get the user document from Firestore
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if the user document exists and has a userType field
      if (userDoc.exists && userDoc.data()!.containsKey('userType')) {
        String userType = userDoc.data()!['userType'];

        // Check user type and navigate accordingly
        if (userType == 'Seller') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SellerPage(
                        username: '',
                      )));
        } else if (userType == 'Buyer') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => BuyerPage()));
        } else {
          // Handle other user types
        }
      } else {
        // User document does not exist or does not contain userType field
        // Handle accordingly
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = "Account not found";
        } else if (e.code == 'wrong-password') {
          _errorMessage = "Wrong password";
        } else {
          _errorMessage = "An error occurred: ${e.message}";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 0, 20),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 1, 0, 20),
                Color.fromARGB(255, 40, 40, 40),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login to your account!',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40.0),
                Card(
                  color: Colors.grey[900],
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            controller: _emailController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon:
                                  Icon(Icons.email, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(Icons.lock, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          if (_errorMessage.isNotEmpty)
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                              ),
                            ),
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _errorMessage = '';
                                });
                                userLogin();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0, vertical: 16.0),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPassword()));
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "Sign up",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/signup');
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

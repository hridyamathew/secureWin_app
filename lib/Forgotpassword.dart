import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _email = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent to $_email',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No user found for the email "$_email"',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 1, 0, 20),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock),
            SizedBox(width: 8),
            Text('Forgot Password', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 1, 0, 20),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('logo.png'),
            SizedBox(height: 20),
            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 9),
            Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetPassword,
              child: Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}
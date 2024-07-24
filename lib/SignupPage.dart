import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'VerifyEmail.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _agencyController = TextEditingController();
  final _dobController = TextEditingController();
  bool _passwordVisible = false;

  DateTime? _selectedDate;
  bool _showAgencyField = false;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? mobileError;
  String? nameError;
  String? dobError;
  String? _selectedUserType = 'Select';
  String? _selectedDistrict;
  String? districtError;
  String? userTypeError;
  String? agencyNumberError;

  List<String> keralaDistricts = [
    'Alappuzha',
    'Ernakulam',
    'Idukki',
    'Kannur',
    'Kasaragod',
    'Kollam',
    'Kottayam',
    'Kozhikode',
    'Malappuram',
    'Palakkad',
    'Pathanamthitta',
    'Thiruvananthapuram',
    'Thrissur',
    'Wayanad',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _agencyController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    setState(() {
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
      mobileError = null;
      nameError = null;
      dobError = null;
      districtError = null;
      userTypeError = null;
      agencyNumberError = null;
    });

    if (passwordConfirmed()) {
      if (!_isValidEmail(_emailController.text.trim())) {
        setState(() {
          emailError = 'Please enter a valid email';
        });
      } else if (!_isValidPassword(_passwordController.text.trim())) {
        setState(() {
          passwordError = 'Password must be at least 8 characters long';
        });
      } else if (_nameController.text.trim().isEmpty) {
        setState(() {
          nameError = 'Please enter your name';
        });
      } else if (!_isValidMobileNumber(_mobileController.text.trim())) {
        setState(() {
          mobileError = 'Please enter a valid mobile number';
        });
      } else if (_selectedDate == null) {
        setState(() {
          dobError = 'Please select your date of birth';
        });
      } else if (_selectedDistrict == null) {
        setState(() {
          districtError = 'Please select your district';
        });
      } else if (_selectedUserType == 'Select') {
        setState(() {
          userTypeError = 'Please select your user type';
        });
      } else if (_selectedUserType == 'Seller' &&
          _agencyController.text.trim().isEmpty) {
        setState(() {
          agencyNumberError = 'Please enter your agency number';
        });
      } else {
        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          await userCredential.user!.sendEmailVerification();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyEmailPage(
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                district: _selectedDistrict!,
                mobile: _mobileController.text.trim(),
                userType: _selectedUserType!,
                agencyNumber: _selectedUserType == 'Seller'
                    ? _agencyController.text.trim()
                    : null,
                dob: _selectedDate!,
              ),
            ),
          );

          print('Email verification sent!');
        } catch (error) {
          print('Error signing up: $error');
          var errorMessage = 'Failed to sign up. Please try again later.';
          if (error is FirebaseAuthException) {
            errorMessage = error.message ?? errorMessage;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
            ),
          );
        }
      }
    } else {
      setState(() {
        confirmPasswordError = 'Passwords do not match';
      });
    }
  }

  bool passwordConfirmed() {
    return _passwordController.text.trim() ==
        _confirmPasswordController.text.trim();
  }

  bool _isValidEmail(String value) {
    final pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool _isValidPassword(String value) {
    return value.length >= 8;
  }

  bool _isValidMobileNumber(String value) {
    final pattern = r'^[0-9]{10}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        final formatter = DateFormat('yyyy-MM-dd');
        final formattedDate = formatter.format(picked);
        _dobController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 30.0), // Adjust top padding as needed
                  child: Text(
                    'Create your Account!',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Card(
                  color: Colors.grey[900],
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Name field
                        TextField(
                          controller: _nameController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Enter your name',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorText: nameError,
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // Email field
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorText: emailError,
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // Password field
                        TextField(
                          controller: _passwordController,
                          style: TextStyle(color: Colors.white),
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            errorText: passwordError,
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // Confirm Password field
                        TextField(
                          controller: _confirmPasswordController,
                          style: TextStyle(color: Colors.white),
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Confirm your password',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            errorText: confirmPasswordError,
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        // Date of Birth field
                        TextField(
                          controller: _dobController,
                          style: TextStyle(color: Colors.white),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Select your date of birth',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorText: dobError,
                            errorStyle: TextStyle(color: Colors.redAccent),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // Mobile Number field
                        TextField(
                          controller: _mobileController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Enter your mobile number',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorText: mobileError,
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // District dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedDistrict,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDistrict = newValue;
                            });
                          },
                          items: keralaDistricts
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'District',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Select District',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorText: districtError,
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                          // Add dropdownColor property with desired color
                          dropdownColor: Colors.grey[900],
                        ),
                        SizedBox(height: 20.0),

                        // User Type dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedUserType,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedUserType = newValue!;
                              if (_selectedUserType == 'Seller') {
                                _showAgencyField = true;
                              } else {
                                _showAgencyField = false;
                              }
                            });
                          },
                          items: <String>['Select', 'Seller', 'Buyer']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  color: value == 'Select'
                                      ? Colors.white54
                                      : Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'User Type',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Select User Type',
                            hintStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            errorText: userTypeError,
                            errorStyle: TextStyle(color: Colors.redAccent),
                          ),
                          // Add dropdownColor property with desired color
                          dropdownColor: Colors.grey[900],
                        ),
                        SizedBox(height: 20.0),

                        // Agency Number field (visible if user type is Seller)
                        if (_showAgencyField)
                          TextField(
                            controller: _agencyController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Agency Number',
                              labelStyle: TextStyle(color: Colors.white70),
                              hintText: 'Enter your agency number',
                              hintStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorText: agencyNumberError,
                              errorStyle: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        SizedBox(height: 30.0),

                        // Sign Up button
                        ElevatedButton(
                          onPressed: signup,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40.0, vertical: 16.0),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/login');
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

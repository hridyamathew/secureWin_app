import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'LoginPage.dart';
import 'sellerResultsPage.dart';
import 'seller_page.dart';

class SellerProfilePage extends StatefulWidget {
  final String userId;

  const SellerProfilePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _SellerProfilePageState createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  int _selectedIndex = 2;
  String username = '';
  String district = '';
  String phoneNumber = '';
  String agencyNo = '';
  String email = '';

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userId.isNotEmpty) {
      _fetchUserData(widget.userId);
    } else {
      print('Invalid userId');
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        setState(() {
          username = userData?['name'] ?? '';
          district = userData?['district'] ?? '';
          phoneNumber = userData?['mobile'] ?? '';
          agencyNo = userData?['agencyNumber'] ?? '';
          email = userData?['email'] ?? '';
        });
      } else {
        print('User document does not exist.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the login page after successful logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF04004B), Color(0xffB760D5)],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  color: Colors.white,
                  onPressed: _logoutUser,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const CircleAvatar(
                          radius: 60,
                          child: Icon(
                            Icons.person,
                            size: 110,
                          )),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          elevation: 4,
                          child: SizedBox(
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProfileField(
                                      Icons.person, "Username", username),
                                  const SizedBox(height: 12),
                                  _buildProfileField(
                                      Icons.location_on, "Agency No", agencyNo),
                                  const SizedBox(height: 12),
                                  _buildProfileField(
                                      Icons.location_on, "district", district),
                                  const SizedBox(height: 12),
                                  _buildProfileField(
                                      Icons.phone, "Phone Number", phoneNumber),
                                  const SizedBox(height: 12),
                                  _buildProfileField(
                                      Icons.assignment_ind, "email", email),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _showChangePasswordDialog(context);
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                const Color(0xFF04004B)),
                            padding:
                                MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20)),
                          ),
                          child: const Text(
                            'Change Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            CurvedNavigationBar(
              items: const <Widget>[
                Icon(Icons.confirmation_number, color: Colors.white),
                Icon(Icons.assignment, color: Colors.white),
                Icon(Icons.person, color: Colors.white),
              ],
              color: const Color(0xFF04004B),
              backgroundColor: Colors.transparent,
              buttonBackgroundColor: Colors.blueAccent,
              animationDuration: const Duration(milliseconds: 50),
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SellerPage(username: '')),
                    );
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SellerResultsPage()),
                    );
                    break;
                  case 2:
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SellerProfilePage(userId: currentUser.uid),
                        ),
                      );
                    } else {
                      print('User is not authenticated');
                    }
                    break;
                }
              },
              index: _selectedIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color.fromARGB(255, 142, 139, 139),
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 113, 149, 164),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              TextField(
                obscureText: true,
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
              ),
              TextField(
                obscureText: true,
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _updatePassword(context);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF04004B)),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updatePassword(BuildContext context) {
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (newPassword.length < 6) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Password must be at least 6 characters long.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content:
                const Text('New password and confirm password do not match.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    String currentPassword = _currentPasswordController.text;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);

      user.reauthenticateWithCredential(credential).then((_) {
        user.updatePassword(newPassword).then((_) {
          _showSuccessDialog(context);
        }).catchError((error) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text('Error updating password: $error'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        });
      }).catchError((error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Error authenticating user: $error'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle,
                color: Color.fromARGB(255, 11, 164, 16),
                size: 50,
              ),
              SizedBox(height: 10),
              Text("Password changed!!!"),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(const Color(0xFF04004B)),
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

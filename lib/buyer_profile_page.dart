import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BuyerProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileBody(),
    );
  }
}

class ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else if (snapshot.hasError) {
          return _buildErrorDisplay(snapshot.error.toString());
        } else {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildProfileContent(context, userData);
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      decoration: _buildGradientDecoration(),
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _buildErrorDisplay(String error) {
    return Container(
      decoration: _buildGradientDecoration(),
      child: Center(
          child: Text('Error: $error', style: TextStyle(color: Colors.white))),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'Unknown';
    final email = userData['email'] ?? 'Unknown';
    final mobile = userData['mobile'] ?? 'Unknown';
    final dateOfBirth = userData['dob'] as Timestamp?;
    final location = userData['district'] ?? 'Unknown';

    String dob = dateOfBirth != null
        ? DateFormat('dd/MM/yyyy').format(dateOfBirth.toDate())
        : 'Unknown';

    return Container(
      decoration: _buildGradientDecoration(),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileImage(),
                    SizedBox(height: 24),
                    _buildProfileCard(name, email, mobile, dob, location),
                    SizedBox(height: 24),
                    _buildChangePasswordButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF04004B), Color(0xFFB760D5)],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text("Profile", style: TextStyle(color: Colors.white)),
      floating: true,
    );
  }

  Widget _buildProfileImage() {
    return const CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.person,
          size: 110,
        ));
  }

  Widget _buildProfileCard(
      String name, String email, String mobile, String dob, String location) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileField(Icons.person, "Name", name),
            _buildProfileField(Icons.email, "Email", email),
            _buildProfileField(Icons.phone, "Mobile", mobile),
            _buildProfileField(Icons.cake, "Date of Birth", dob),
            _buildProfileField(Icons.location_on, "Location", location),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF04004B), size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 4),
                Text(value,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showChangePasswordDialog(context),
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xFF04004B),
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text('Change Password', style: TextStyle(fontSize: 16)),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                // Check if new password and confirm password match
                if (newPassword == confirmPassword) {
                  // Implement your logic here to change password
                  bool success = await updatePasswordInDatabase(
                      currentPassword, newPassword);
                  if (success) {
                    Navigator.of(context).pop();
                    _showSuccessDialog(context);
                  } else {
                    // Handle password update failure
                    // For example, show an error message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Failed to update password. Please try again.'),
                    ));
                  }
                } else {
                  // Passwords do not match
                  // Show an error message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('New password and confirm password do not match.'),
                  ));
                }
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF04004B)),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: const Color.fromARGB(255, 11, 164, 16),
                size: 50,
              ),
              SizedBox(height: 10),
              Text("Password changed!!!"),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF04004B)),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> updatePasswordInDatabase(
      String currentPassword, String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Reauthenticate the user with their current password
        AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(credential);

        // If reauthentication is successful, update the password
        await user.updatePassword(newPassword);
        return true;
      } else {
        // Handle case where no user is signed in
        print("No user is currently signed in.");
        return false;
      }
    } catch (error) {
      // Handle specific error cases
      print("Failed to update password: $error");
      if (error is FirebaseAuthException) {
        if (error.code == 'requires-recent-login') {
          print("User needs to re-authenticate.");
          // Handle the case where the user needs to re-authenticate
        } else if (error.code == 'weak-password') {
          print("The provided password is too weak.");
          // Handle the case where the new password is too weak
        } else {
          print("An unexpected error occurred: ${error.message}");
          // Handle other specific error cases
        }
      } else {
        print("An unexpected error occurred: $error");
        // Handle unexpected errors
      }
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'LoginPage.dart' ;


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppOpeningPage(),
    );
  }
}

class AppOpeningPage extends StatefulWidget {
  @override
  _AppOpeningPageState createState() => _AppOpeningPageState();
}

class _AppOpeningPageState extends State<AppOpeningPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Start animation
    _controller.forward();

    // Redirect to login page after animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 1, 0, 20), // Set background color to white
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/logo.png',
            width: 300, // Adjust size as needed
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}



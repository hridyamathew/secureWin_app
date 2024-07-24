import 'package:flutter/material.dart';
import 'seller_page.dart';

class TickIconPage extends StatefulWidget {
  const TickIconPage({super.key});

  @override
  _TickIconPageState createState() => _TickIconPageState();
}

class _TickIconPageState extends State<TickIconPage> {
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Status'),
      ),
      body: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          height: _isAnimated ? MediaQuery.of(context).size.height : 0,
          width: _isAnimated ? MediaQuery.of(context).size.width : 0,
          color: Colors.green.withOpacity(0.8),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isAnimated ? 1.0 : 0.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ticket Sold!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the first page of the SellerPage class

                      // Replace '/' with the route name of the first page of the SellerPage class
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SellerPage(
                            username: '',
                          ),
                        ),
                      );
                    },
                    child: const Text('Return to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/sellerProfilepage.dart';
import 'package:flutter_application_1/seller_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SellerResultsPage extends StatefulWidget {
  const SellerResultsPage({Key? key}) : super(key: key);

  @override
  State<SellerResultsPage> createState() => _SellerResultsPageState();
}

class _SellerResultsPageState extends State<SellerResultsPage> {
  int _selectedIndex = 1;
  final TextEditingController _ticketController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _result = '';
  Future<void> _checkLotteryResult() async {
    final ticketNumber = _ticketController.text.trim();
    if (ticketNumber.isEmpty) {
      setState(() {
        _result = 'Please enter a ticket number.';
      });
      return;
    }

    setState(() {
      _result = 'Checking...';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://66859d08b3f57b06dd4d51a0.mockapi.io/api/lotteryResults'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> allResults = json.decode(response.body);
        final matchingTicket = allResults.firstWhere(
          (result) => result['ticketNumber'] == ticketNumber,
          orElse: () => null,
        );

        setState(() {
          if (matchingTicket != null) {
            if (matchingTicket['status'] == 'win') {
              _result =
                  'Congratulations! You won ${matchingTicket['prize']} rupees.';
            } else {
              _result = 'Sorry, your ticket did not win.';
            }
          } else {
            _result =
                'Ticket not found. Please check the number and try again.';
          }
        });
      } else {
        setState(() {
          _result = 'Failed to check result. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _result =
            'An error occurred. Please check your internet connection and try again.';
      });
      print('Error: $e'); // For debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lottery Results'),
        backgroundColor: const Color(0xFF04004B),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Kerala Lottery Checker',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ticketController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Ticket Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkLotteryResult,
                    child: const Text('Check Result'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF04004B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _result,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
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
                    builder: (context) => const SellerPage(username: '')),
              );
              break;
            case 1:
              // Already on SellerResultsPage, no need to navigate
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
    );
  }
}

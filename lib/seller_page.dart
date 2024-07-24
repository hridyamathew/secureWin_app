import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/AvailableTicket.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/LotteryDetailPage.dart';
import 'package:flutter_application_1/sellerProfilepage.dart';
import 'package:flutter_application_1/seller_page.dart';

import 'sellerResultsPage.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key, required String username});

  @override
  _SellerPageState createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final ScrollController _bumperLotteryController = ScrollController();
  final Map<String, Color> lotteryColors = const {
    'WIN-WIN': Color.fromARGB(255, 6, 23, 53),
    'STHREE SAKTHI': Color.fromARGB(255, 83, 118, 180),
    'FIFTY-FIFTY': Color.fromARGB(255, 83, 118, 180),
    'KARUNYA PLUS': Color.fromARGB(255, 83, 118, 180),
    'NIRMAL': Color.fromARGB(255, 83, 118, 180),
    'KARUNYA': Color.fromARGB(255, 83, 118, 180),
    'AKSHAYA': Color.fromARGB(255, 83, 118, 180),
  };

  bool showWeeklyLotteries = true;
  bool showBumperLotteries = false;

  @override
  void initState() {
    super.initState();
    _checkUserAndCreateLotterySubcollection();
  }

  Future<void> _checkUserAndCreateLotterySubcollection() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists && userDoc.data()?['userType'] == 'Seller') {
        final lotterySubcollectionSnapshot =
            await userDoc.reference.collection('Lottery').get();
        if (lotterySubcollectionSnapshot.docs.isEmpty) {
          await _createLotterySubcollection(currentUser.uid);
        } else {
          print('Lottery subcollection already exists.');
        }
      } else {
        print('User is not registered as a seller.');
      }
    }
  }

  Future<void> _createLotterySubcollection(String userId) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final lotterySubcollection = userDocRef.collection('Lottery');

    // Add documents for each lottery type with dummy data
    final lotteryTypes = [
      'WIN-WIN',
      'STHREE SAKTHI',
      'FIFTY-FIFTY',
      'KARUNYA PLUS',
      'NIRMAL',
      'KARUNYA',
      'AKSHAYA',
    ];

    for (var lotteryType in lotteryTypes) {
      await lotterySubcollection.add({
        'Ticket_no': 'T${lotteryType}0001', // Example ticket number format
        'drew_date': Timestamp.fromDate(
            DateTime(2024, 1, 1)), // Example draw date as Timestamp
        'lotteryType': lotteryType,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls = [
      'assets/lottery1.jpg',
      'assets/lottery4.jpg',
      'assets/lottery3.jpg',
    ];

    int _selectedIndex = 0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF04004B),
              const Color(0xffB760D5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider(
                items: imageUrls.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) => ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 200.0,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  enlargeCenterPage: true,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton('Weekly', showWeeklyLotteries),
                  const SizedBox(width: 16.0),
                  _buildButton('Bumper', showBumperLotteries),
                ],
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: showWeeklyLotteries
                    ? _buildLotteryList(context, [
                        LotteryTicket('WIN-WIN', '40', '₹75 Lakhs', type: 'W'),
                        LotteryTicket('STHREE SAKTHI', '40', '₹75 Lakhs',
                            type: 'S'),
                        LotteryTicket('FIFTY-FIFTY', '40', '₹1 Crore',
                            type: 'F'),
                        LotteryTicket('KARUNYA PLUS', '40', '₹80 Lakhs',
                            type: 'p'),
                        LotteryTicket('NIRMAL', '40', '₹70 Lakhs', type: 'N'),
                        LotteryTicket('KARUNYA', '40', '₹80 Lakhs', type: 'K'),
                        LotteryTicket('AKSHAYA', '40', '₹70 Lakhs', type: 'A'),
                      ])
                    : _buildLotteryList(context, [
                        LotteryTicket(
                            'Xmas New Year Lottery', '200', '₹10 Crores',
                            drawMonth: 'January'),
                        LotteryTicket(
                            'Summer Bumper Lottery', '150', '₹5 Crores',
                            drawMonth: 'March'),
                        LotteryTicket(
                            'Vishu Bumper Lottery', '150', '₹5 Crores',
                            drawMonth: 'May'),
                        LotteryTicket(
                            'Monsoon Bumper Lottery', '150', '₹5 Crores',
                            drawMonth: 'July'),
                        LotteryTicket('Onam Bumper Lottery', '200', '₹10Crores',
                            drawMonth: 'September'),
                        LotteryTicket(
                            'Pooja Bumper Lottery', '200', '₹10 Crores',
                            drawMonth: 'November'),
                      ]),
              ),
            ],
          ),
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
            var _selectedIndex = index;
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
    );
  }

  Widget _buildButton(String text, bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          showWeeklyLotteries = text == 'Weekly';
          showBumperLotteries = text == 'Bumper';
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLotteryList(BuildContext context, List<LotteryTicket> tickets) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return _buildLotteryTicket(context, tickets[index]);
      },
    );
  }

  Widget _buildLotteryTicket(BuildContext context, LotteryTicket ticket) {
    Color cardColor =
        lotteryColors[ticket.name] ?? const Color.fromARGB(255, 224, 217, 114);
    String lotteryType = ticket.type ?? '';

    Gradient gradient;
    if (ticket.drawMonth != null) {
      // Bumper lottery ticket
      gradient = LinearGradient(
        colors: [
          Color.fromARGB(255, 34, 32, 155).withOpacity(0.8),
          Color.fromARGB(255, 43, 122, 154).withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Weekly lottery ticket
      gradient = LinearGradient(
        colors: [
          Color.fromARGB(255, 142, 33, 100).withOpacity(0.8),
          Color.fromARGB(255, 90, 59, 95).withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvailableTicketNumbersPage(),
          ),
        );
      },
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ticket.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const SizedBox(height: 8.0),
                Text(
                  'Ticket Price (Rs): ${ticket.price}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Top Prize: ${ticket.topPrize}',
                  style: const TextStyle(color: Colors.white),
                ),
                if (ticket.drawMonth != null) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    'Draw Month: ${ticket.drawMonth}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LotteryTicket {
  final String name;
  final String price;
  final String topPrize;
  final String? drawMonth;
  final String? type;

  LotteryTicket(this.name, this.price, this.topPrize,
      {this.drawMonth, this.type});
}

import 'package:flutter/material.dart';
import 'package:flutter_application_1/seller_page.dart';

class LotteryDetailPage extends StatelessWidget {
  final LotteryTicket lotteryTicket;

  const LotteryDetailPage({Key? key, required this.lotteryTicket})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6D76FF),
              Color(0xFF3333FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            lotteryTicket.name,
            style: const TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
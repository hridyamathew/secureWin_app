import 'package:flutter/material.dart';
import 'dart:math';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String? _selectedLotteryType;
  String? _selectedTicketAllocated;
  final TextEditingController _sellerEmailController = TextEditingController();
  final TextEditingController _sellerNameController = TextEditingController();

  final List<String> _lotteryTypes = ['K', 'P', 'W', 'F', 'S', 'N', 'G'];
  final List<String> _ticketAllocated = [];

  @override
  void initState() {
    super.initState();
    _generateTicketAllocated();
  }

  void _generateTicketAllocated() {
    _ticketAllocated.clear();
    int randomNumber = Random().nextInt(90000) + 10000;
    String randomLetter = String.fromCharCode(Random().nextInt(26) + 65);
    String prefix = _selectedLotteryType ?? _lotteryTypes[Random().nextInt(_lotteryTypes.length)];
    String startingTicket = '$prefix${randomNumber.toString().padLeft(5, '0')}$randomLetter';
    _ticketAllocated.add(startingTicket);

    for (int i = 1; i < 10; i++) {
      randomNumber++;
      String ticketNumber = '$prefix${randomNumber.toString().padLeft(5, '0')}$randomLetter';
      _ticketAllocated.add(ticketNumber);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Admin Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seller Email',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            TextField(
              controller: _sellerEmailController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Seller Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            TextField(
              controller: _sellerNameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Lottery Type',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            DropdownButton<String>(
              value: _selectedLotteryType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLotteryType = newValue;
                  _generateTicketAllocated();
                });
              },
              items: _lotteryTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Text(
              'Tickets Allocated',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
            DropdownButton<String>(
              value: _selectedTicketAllocated,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTicketAllocated = newValue;
                });
              },
              items: _ticketAllocated.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'LoginPage.dart';
import 'dart:convert';

class BuyerPage extends StatefulWidget {
  @override
  _BuyerPageState createState() => _BuyerPageState();
}

class _BuyerPageState extends State<BuyerPage> {
  final String _rpcUrl = 'HTTP://127.0.0.1:7545'; // Ganache RPC URL
  final String _privateKey =
      '48ad605ed0151fde2dfb5745d237f0b5b990fd239e08087104b4908d79a9f3d0';
  final String _contractAddress = '0x98ab95c45366d6D6E389bb4076de081F242Ec0dC';
  final String _mockApiUrl =
      'https://66859d08b3f57b06dd4d51a0.mockapi.io/api/lotteryResults'; // Replace with your mock API URL

  Web3Client? _client;
  Credentials? _credentials;
  DeployedContract? _contract;
  ContractFunction? _getTicketNumbersByName;
  List<dynamic>? _tickets;
  String? _userName;
  List<dynamic>? _wonTickets;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _client = Web3Client(_rpcUrl, http.Client());
      _credentials = EthPrivateKey.fromHex(_privateKey);

      String abi = await rootBundle.loadString('assets/abi.json');
      _contract = DeployedContract(ContractAbi.fromJson(abi, 'TicketRegistry'),
          EthereumAddress.fromHex(_contractAddress));
      _getTicketNumbersByName = _contract!.function('getTicketNumbersByName');

      await _fetchUserName();
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final name = userData['name'] ?? 'Unknown';

        setState(() {
          _userName = name;
        });
        print('User name: $_userName');

        if (_userName != 'Unknown') {
          await _fetchTickets();
        } else {
          print('User name not available.');
        }
      } else {
        print('No user logged in');
      }
    } catch (e) {
      print('Fetch user name error: $e');
    }
  }

  Future<void> _fetchTickets() async {
    try {
      if (_userName != null && _userName!.isNotEmpty) {
        print('Fetching tickets for: $_userName');
        final result = await _client!.call(
          contract: _contract!,
          function: _getTicketNumbersByName!,
          params: [_userName],
        );

        setState(() {
          _tickets = result[0] as List;
        });
        print('Tickets fetched: $_tickets');

        // Fetching won tickets from mock API
        await _fetchMockApiData();
      }
    } catch (e) {
      print('Fetch tickets error: $e');
    }
  }

  Future<void> _fetchMockApiData() async {
    try {
      final response = await http.get(Uri.parse(_mockApiUrl));
      if (response.statusCode == 200) {
        List<dynamic> mockData = json.decode(response.body);
        print('Mock API data fetched: $mockData');

        _wonTickets = mockData.where((ticket) {
          print('Ticket fetched from API: $ticket');
          bool isMatch = _tickets!.contains(ticket['ticketNumber']);
          print(
              'Checking ticket: ${ticket['ticketNumber']}, isMatch: $isMatch');
          return isMatch;
        }).toList();

        setState(() {
          _wonTickets = _wonTickets;
        });
        print('Won Tickets: $_wonTickets');
      } else {
        throw Exception('Failed to load mock API data');
      }
    } catch (e) {
      print('Fetch mock API data error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text("View Profile"),
                  value: "View Profile",
                ),
                PopupMenuItem(
                  child: Text("Log Out"),
                  value: "Log Out",
                ),
              ];
            },
            onSelected: (value) {
              if (value == "View Profile") {
                Navigator.pushNamed(context, '/buyerProfile');
              } else if (value == 'Log Out') {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false);
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 2, 34, 71),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Tickets Won',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 5), // Reduced height between sections
            _wonTickets == null
                ? CircularProgressIndicator()
                : _wonTickets!.isEmpty
                    ? Center(child: Text("No tickets won yet"))
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two items per row
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 2.9, // Adjust as needed
                          ),
                          itemCount: _wonTickets!.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${_wonTickets![index]['ticketNumber']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        ' ${_wonTickets![index]['prize']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            SizedBox(height: 5), // Reduced height between sections
            Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 2, 34, 71),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Purchased Tickets',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 5), // Reduced height between sections
            _tickets == null
                ? CircularProgressIndicator()
                : _tickets!.isEmpty
                    ? Center(child: Text("No tickets purchased yet"))
                    : Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Two items per row
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 2.9, // Adjust as needed
                          ),
                          itemCount: _tickets!.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    '${_tickets![index]}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

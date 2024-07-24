// import 'dart:async';
import 'dart:math';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'tick_icon_page.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

//import 'package:http/http.dart';
// import 'package:securewin/country_picker.dart';
// import 'package:securewin/custom_button.dart';
// import 'package:securewin/firebase_options.dart';
// import 'package:securewin/otp_screen.dart';
// import 'package:securewin/tick_icon_page.dart';
// import 'package:web3dart/web3dart.dart';

class AvailableTicketNumbersPage extends StatefulWidget {
  @override
  _AvailableTicketNumbersPageState createState() =>
      _AvailableTicketNumbersPageState();
}

class _AvailableTicketNumbersPageState
    extends State<AvailableTicketNumbersPage> {
  final List<String> selectedNumbers = [];
  final List<String> ticketNumbers = [];

  @override
  void initState() {
    super.initState();
    // Generate the ticket numbers
    for (int i = 0; i < 10; i++) {
      ticketNumbers.add(
          'KR-645 K${String.fromCharCode(65 + i)} ${generateRandomNumber()}');
    }
  }

  // Helper function to generate random 6-digit numbers
  String generateRandomNumber() {
    var rng = new Random();
    return rng.nextInt(999999).toString().padLeft(6, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Ticket Numbers'),
      ),
      body: ListView.builder(
        itemCount: ticketNumbers.length,
        itemBuilder: (context, index) {
          final ticketNumber = ticketNumbers[index];
          final isChecked = selectedNumbers.contains(ticketNumber);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isChecked) {
                  selectedNumbers.remove(ticketNumber);
                } else {
                  selectedNumbers.add(ticketNumber);
                }
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Card(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: isChecked ? Colors.blue.withOpacity(0.1) : Colors.white,
                child: Container(
                  width: 40.0, // 2cm
                  height: 80.0, // 4cm
                  child: ListTile(
                    title: Text(
                      ticketNumber,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    trailing: Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          if (isChecked) {
                            selectedNumbers.remove(ticketNumber);
                          } else {
                            selectedNumbers.add(ticketNumber);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: selectedNumbers.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuyerDetailsPage(
                      selectedNumbers: selectedNumbers,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.check),
            )
          : null,
    );
  }
}

class TwilioRateLimitException implements Exception {
  final String message;

  TwilioRateLimitException(this.message);
}

class BuyerDetailsPage extends StatefulWidget {
  final List<String> selectedNumbers;

  const BuyerDetailsPage({Key? key, required this.selectedNumbers})
      : super(key: key);

  @override
  _BuyerDetailsPageState createState() => _BuyerDetailsPageState();
}

class _BuyerDetailsPageState extends State<BuyerDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  late Client httpClient;
  late Web3Client ethClient;
  final myAddress = "0x07A3FC767ADC0082608F884DEd84e23E1d47bA18";
  String _name = '';
  String _phoneNumber = '';

  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client('HTTP://127.0.0.1:7545', httpClient);
  }

  Future<void> _sendOTP(String phoneNumber) async {
    try {
      // Replace with your actual Twilio credentials
      final String accountSid = 'AC3ab9addcae51f1dfe23883587e4abc97';
      final String authToken = '53a44ff33d507fdff425295a9b40de0c';
      final String serviceSid = 'VA71f3910bf79f7fb6a8b98ed8ba5f07c7';

      final response = await http.post(
        Uri.parse(
            'https://verify.twilio.com/v2/Services/$serviceSid/Verifications'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        },
        body: <String, String>{
          'To': phoneNumber,
          'Channel': 'sms',
        },
      );

      if (response.statusCode == 201) {
        print('OTP sent successfully!');
        // Generate a new OTP
        _showOTPDialog(phoneNumber);
      } else {
        _showErrorDialog('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      _showErrorDialog('Error sending OTP: $e');
    }
  }

  void _showOTPDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: _otpController,
            decoration: InputDecoration(
              hintText: 'Enter the OTP sent to $phoneNumber',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String enteredOTP = _otpController.text.trim();
                if (enteredOTP.isNotEmpty) {
                  verifyOTP(phoneNumber, enteredOTP);
                } else {
                  _showErrorDialog('Please enter the OTP.');
                }
              },
              child: const Text('Verify'),
            )
          ],
        );
      },
    );
  }

  // void _generateOTP() {
  //   var rng = Random();
  //   _generatedOTP = rng.nextInt(999999).toString().padLeft(6, '0');
  //   print('Generated OTP: $_generatedOTP');
  // }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x98ab95c45366d6D6E389bb4076de081F242Ec0dC";
    final contract = DeployedContract(
        ContractAbi.fromJson(abi, "TicketRegistry"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "48ad605ed0151fde2dfb5745d237f0b5b990fd239e08087104b4908d79a9f3d0");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        chainId: 1337);
    return result;
  }

  Future<String> storeDetails() async {
    var response = await submit(
        "storeTicketDetails", [widget.selectedNumbers, _name, _phoneNumber]);
    print("Details Stored!!");
    return response;
  }

  Future<void> sendOTPWithRetry(String phoneNumber) async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        // Attempt to send OTP
        await _sendOTP(phoneNumber);
        print('OTP sent successfully!');
        return; // Exit function if OTP sent successfully
      } catch (e) {
        if (e is TwilioRateLimitException) {
          // Handle rate-limiting error
          print(
              'Rate limit exceeded. Retrying in ${getRetryDelay(retryCount)} seconds...');
          await Future.delayed(Duration(seconds: getRetryDelay(retryCount)));
          retryCount++;
        } else {
          // Handle other errors
          print('Error sending OTP: $e');
          throw e; // Rethrow the error if not rate-limiting
        }
      }
    }

    // Handle case when max retries reached
    print('Max retry limit reached. Unable to send OTP.');
  }

  int getRetryDelay(int retryCount) {
    // Exponential backoff with random jitter
    int delaySeconds = (1 << retryCount) * 5; // 5, 10, 20, 40, ...
    return delaySeconds +
        Random().nextInt(11); // Add random jitter (0 to 10 seconds)
  }

  Future<void> verifyOTP(String phoneNumber, String enteredOTP) async {
    try {
      final String accountSid = 'AC3ab9addcae51f1dfe23883587e4abc97';
      final String authToken = '53a44ff33d507fdff425295a9b40de0c';
      final String serviceSid = 'VA71f3910bf79f7fb6a8b98ed8ba5f07c7';

      // Verify OTP using Twilio's Verify API
      final response = await http.post(
        Uri.parse(
            'https://verify.twilio.com/v2/Services/$serviceSid/VerificationCheck'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
        },
        body: <String, String>{
          'To': phoneNumber,
          'Code': enteredOTP,
        },
      );

      if (response.statusCode == 200) {
        print('OTP verification successful!');
        // Navigate to the TickIconPage upon successful OTP verification
        storeDetails();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TickIconPage(),
          ),
        );
      } else {
        print('OTP verification failed: ${response.body}');
        // Handle failure
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      // Handle error
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter Name',
                ),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter Phone Number',
                ),
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = "+91$value";
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_phoneNumber.isNotEmpty) {
                    _sendOTP(_phoneNumber);
                  } else {
                    _showErrorDialog('Phone number cannot be empty.');
                  }
                },
                child: const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

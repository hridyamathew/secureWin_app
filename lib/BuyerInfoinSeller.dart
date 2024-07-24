// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/http.dart';
// import 'package:web3dart/web3dart.dart';
// import 'dart:convert';

// class BuyerDetailsPage extends StatefulWidget {
//   final List<String> selectedNumbers;
//   BuyerDetailsPage({Key? key, required this.selectedNumbers}) : super(key: key);

//   @override
//   _BuyerDetailsPageState createState() => _BuyerDetailsPageState();
// }

// class _BuyerDetailsPageState extends State<BuyerDetailsPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   late Client httpClient;
//   late Web3Client ethClient;

//   @override
//   void initState() {
//     super.initState();
//     httpClient = Client();
//     ethClient = Web3Client('HTTP://127.0.0.1:7545', httpClient);
//   }

//   Future<DeployedContract> loadContract() async {
//     String abiCode = await rootBundle.loadString('assets/abi.json');
//     String contractAddress = "0x45Ead4b5795888ca12aB73927b2D4826b76d0b16";
//     final contract = DeployedContract(
//         ContractAbi.fromJson(jsonDecode(abiCode), "TicketRegistry"),
//         EthereumAddress.fromHex(contractAddress));
//     return contract;
//   }

//   Future<String> storeDetails(
//     DeployedContract contract, EthPrivateKey credentials) async {
//   // Combine buyer name and phone number into a single string
//   final buyerInfo = "${_nameController.text},${_phoneController.text}";

//   // Convert selected ticket numbers list to a string array (assuming you've already done this)
//   final ticketNumbersArray = widget.selectedNumbers.toList();

//   final ethFunction = contract.function("storeTicketDetails");
//   final result = await ethClient.sendTransaction(
//     credentials,
//     Transaction.callContract(
//       contract: contract,
//       function: ethFunction,
//       parameters: [ticketNumbersArray, buyerInfo],
//     ),
//     chainId: 1337,
//   );
//   return result;
// }


//   Future<void> _showConfirmationDialog() async {
//     EthPrivateKey credentials = EthPrivateKey.fromHex(
//         "48ad605ed0151fde2dfb5745d237f0b5b990fd239e08087104b4908d79a9f3d0");
//     DeployedContract contract = await loadContract();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.black,
//           title: const Text(
//             'Confirmation',
//             style: TextStyle(color: Colors.white),
//           ),
//           content: const Text(
//             'Do you want to purchase the ticket(s)?',
//             style: TextStyle(color: Colors.white),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 String result = await storeDetails(contract, credentials);
//                 print("Details Stored: $result");
//                 Navigator.of(context).pop();
//                 _showSuccessSnackBar();
//               },
//               child: const Text(
//                 'Confirm',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showSuccessSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.green,
//         content: const Text(
//           'Purchase successful!',
//           style: TextStyle(color: Colors.white),
//         ),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }



//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Buyer Details',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               const Color(0xFF04004B),
//               const Color(0xffB760D5),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.white),
//                     borderRadius: BorderRadius.circular(10.0),
//                     color: Colors.transparent,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Padding(
//                         padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
//                         child: Text(
//                           'Name',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       TextFormField(
//                         controller: _nameController,
//                         decoration: const InputDecoration(
//                           contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                           filled: true,
//                           fillColor: Colors.transparent,
//                         ),
//                         style: const TextStyle(color: Colors.white),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your name';
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//               Container(
//   decoration: BoxDecoration(
//     border: Border.all(color: Colors.white),
//     borderRadius: BorderRadius.circular(10.0),
//     color: Colors.transparent,
//   ),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Padding(
//         padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
//         child: Text(
//           'Phone Number',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       TextFormField(
//         controller: _phoneController,
//         decoration: const InputDecoration(
//           contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//           filled: true,
//           fillColor: Colors.transparent,
//         ),
//         style: const TextStyle(color: Colors.white),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Please enter your phone number';
//           } else if (value.length != 10) {
//             return 'Phone number must be exactly 10 digits';
//           }
//           return null;
//         },
//       ),
//     ],
//   ),
// ),
//                 const SizedBox(height: 16.0),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       _showConfirmationDialog();
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   child: const Text(
//                     'Sell',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 16.0),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.white),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Selected Tickets:',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16.0,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8.0),
//                         ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: widget.selectedNumbers.length,
//                           itemBuilder: (context, index) {
//                             final ticketNumber = widget.selectedNumbers[index];
//                             return Text(
//                               '- $ticketNumber',
//                               style: const TextStyle(color: Colors.white),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




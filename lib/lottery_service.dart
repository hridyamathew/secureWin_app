// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// class LotteryService {
//   Future<void> addLotteryTicket({
//     required String sellerId,
//     required String sellerName,
//     required String gmailId,
//     required String ticketNo,
//     required DateTime drawDate,
//     required String lotteryType,
//   }) async {
//     try {
//       await FirebaseFirestore.instance.collection('LotteryTickets').add({
//         'sellerId': sellerId,
//         'sellerNam': sellerName,
//         // 'gmailId': gmailId,a
//         'Ticket_no': ticketNo,
//         'drew_date': drawDate.toIso8601String(),
//         'lotteryType': lotteryType,
//       });
//       print('Lottery ticket added successfully');
//     } catch (e) {
//       print('Error adding lottery ticket: $e');
//     }
//   }
// }
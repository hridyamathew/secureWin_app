import 'package:flutter/material.dart';

class ExpiredTicketsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Mock data for expired tickets
    List<Map<String, dynamic>> expiredTickets = [
      {
        "ticketNumber": "12345",
        "resultPublishedDate": "2024-03-01",
        "won": true,
        "prize": "First Prize",
        "amount": "1000"
      },
      {
        "ticketNumber": "67890",
        "resultPublishedDate": "2024-03-15",
        "won": false
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expired Tickets',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF04004B),
      ),
      body: expiredTickets.isEmpty
          ? Center(
              child: Text("You haven't purchased yet..."),
            )
          : ListView.builder(
              itemCount: (expiredTickets.length / 2).ceil(),
              itemBuilder: (context, index) {
                final startIndex = index * 2;
                final endIndex = (index + 1) * 2;
                final ticketData = expiredTickets.sublist(
                  startIndex,
                  endIndex > expiredTickets.length
                      ? expiredTickets.length
                      : endIndex,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: IntrinsicHeight(
                    child: Wrap(
                      spacing: 16.0,
                      children: ticketData.map((ticket) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 24,
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ticket Number: ${ticket['ticketNumber']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Result Published Date: ${_formatDate(ticket['resultPublishedDate'])}',
                                  ),
                                  Text('Won: ${ticket['won'] ? 'Yes' : 'No'}'),
                                  if (ticket['won']) ...[
                                    SizedBox(height: 8),
                                    Text('Prize: ${ticket['prize']}'),
                                    Text('Amount: ${ticket['amount']}'),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }
}

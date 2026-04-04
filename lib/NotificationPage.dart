import 'package:flutter/material.dart';
import 'package:traite_manager/utils/tools.dart';

class NotificationsPage extends StatelessWidget {
  final List<Client> clientsExceeding;

  const NotificationsPage({super.key, required this.clientsExceeding});

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients dépassant le montant", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(184, 1, 64, 96),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: clientsExceeding.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Aucun client ne dépasse le montant limite",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: clientsExceeding.length,
                itemBuilder: (context, index) {
                  final client = clientsExceeding[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey[100],
                        child: Icon(
                          Icons.person,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      title: Text(
                        client.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Téléphone: ${client.phone}"),
                          Text("Montant: ${client.montantEncours} TND",
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Icon(Icons.warning_amber_rounded,
                          color: Colors.red[400]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
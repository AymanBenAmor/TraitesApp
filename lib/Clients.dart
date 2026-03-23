import 'package:flutter/material.dart';
import 'package:traite_manager/AddClient.dart';
import 'package:traite_manager/utils/tools.dart';

class EspaceClientPage extends StatefulWidget {
  const EspaceClientPage({super.key});

  @override
  State<EspaceClientPage> createState() => _EspaceClientPageState();
}

class _EspaceClientPageState extends State<EspaceClientPage> {
  bool _isHovering = false; // For tooltip visibility

  // Sample client list
  final List<Client> clients = [
    Client(
      name: "John Doe",
      phone: 20353648,
      rib: "1323235135165645656",
      montantEncours: 5555,
    ),
    Client(
      name: "Jane Smith",
      phone: 20353649,
      rib: "1323235135165645666",
      montantEncours: 4200,
    ),
    Client(
      name: "Alice Johnson",
      phone: 20353650,
      rib: "1323235135165645677",
      montantEncours: 3000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Espace Client",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(184, 1, 64, 96),
        iconTheme: const IconThemeData(color: Colors.white), // white back arrow
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: clients.isEmpty
            ? const Center(
                child: Text(
                  "Aucun client pour le moment",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ClientListView(clients: clients),
      ),

      // Floating Action Button with fixed tooltip above
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tooltip above button
          Positioned(
            right: 70,
            bottom: 30, // distance above button
            child: AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(184, 1, 64, 96),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Ajouter un client",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            right: 0,
            bottom: 20,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovering = true),
              onExit: (_) => setState(() => _isHovering = false),
              child: FloatingActionButton(
                backgroundColor: const Color.fromARGB(184, 1, 64, 96),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddClientPage()),
                  );
                },
                child: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
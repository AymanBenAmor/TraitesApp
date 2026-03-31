
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
  List<Client> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadClients();
  }

  /// Load clients from CSV
  Future<void> loadClients() async {
    setState(() => isLoading = true);
    final data = await loadClientsFromCSV();
    setState(() {
      clients = data;
      isLoading = false;
    });
  }

  /// Callback to refresh the list after deleting a client
  void refreshClients() {
    loadClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Espace Client",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(184, 1, 64, 96),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : clients.isEmpty
                ? const Center(
                    child: Text(
                      "Aucun client pour le moment",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ClientListView(
                    clients: clients,
                    onRefresh: refreshClients, // Pass the callback
                  ),
      ),
      floatingActionButton: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tooltip above button
          Positioned(
            right: 70,
            bottom: 30,
            child: AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                onPressed: () async {
                  // Navigate to AddClientPage and wait for a result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddClientPage()),
                  );

                  // If AddClientPage returned true, reload clients
                  if (result == true) {
                    loadClients();
                  }
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
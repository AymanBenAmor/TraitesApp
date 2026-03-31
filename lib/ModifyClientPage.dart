import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:traite_manager/utils/tools.dart';

class ModifyClientPage extends StatefulWidget {
  final Client client;
  final VoidCallback onModified; // callback to refresh parent

  const ModifyClientPage({super.key, required this.client, required this.onModified});

  @override
  State<ModifyClientPage> createState() => _ModifyClientPageState();
}

class _ModifyClientPageState extends State<ModifyClientPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController ribController;
  late TextEditingController montantController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.client.name);
    phoneController = TextEditingController(text: widget.client.phone.toString());
    ribController = TextEditingController(text: widget.client.rib);
    montantController = TextEditingController(text: widget.client.montantEncours.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    ribController.dispose();
    montantController.dispose();
    super.dispose();
  }

  Future<void> updateClientInCSV() async {
    try {
      final Directory docDir = await getApplicationDocumentsDirectory();
      final Directory pathDir = Directory('${docDir.path}/TraiteManager/Clients');
      final File file = File('${pathDir.path}/clients.csv');

      if (!await file.exists()) return;

      final List<String> lines = await file.readAsLines();
      if (lines.isEmpty) return;

      // Keep header
      final header = lines.first;
      final dataLines = lines.length > 1 ? lines.sublist(1) : [];

      // Replace the client row
      final updatedLines = dataLines.map((line) {
        final parts = line.split(',');
        final rib = parts[2].trim();
        if (rib == widget.client.rib) {
          // update this row
          return "${nameController.text},${phoneController.text},${ribController.text},${montantController.text}";
        }
        return line;
      }).toList();

      // Write back header + updated rows
      await file.writeAsString("$header\n${updatedLines.join('\n')}\n", flush: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Client modifié avec succès!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      widget.onModified(); // refresh parent
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating client: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modifier Client")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Téléphone"),
            ),
            TextField(
              controller: ribController,
              decoration: const InputDecoration(labelText: "RIB"),
            ),
            TextField(
              controller: montantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Montant"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateClientInCSV,
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
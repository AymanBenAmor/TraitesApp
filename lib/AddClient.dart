import 'package:flutter/material.dart';
import 'package:traitenova/utils/tools.dart';

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ribController = TextEditingController();


  // List of clients in memory
  List<Map<String, String>> clients = [];

  final _formKey = GlobalKey<FormState>();

  /// Add client to list and save in CSV
Future<void> addClient() async {
  final newClient = {
    "name": _nameController.text.toLowerCase(),
    "phone": _phoneController.text,
    "rib": _ribController.text,
  };

  bool clientAdded = await saveClientToCSV(context, newClient);

  if (clientAdded) {
    Navigator.pop(context, true); // 🔥 THIS LINE FIXES EVERYTHING
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ajouter un Client",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Center(
              child: Text(
                "Formulaire d'ajout de client",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 51, 92),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  buildInputField("Nom", _nameController, hint: "Entrer le nom"),
                  buildInputField(
                    "Téléphone",
                    _phoneController,
                    fieldType: FieldType.phone,
                    hint: "Entrer le téléphone",
                  ),
                  buildInputField(
                    "RIB",
                    _ribController,
                    fieldType: FieldType.rib,
                    hint: "Entrer le RIB",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(184, 1, 64, 96),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addClient();
                }
              },
              child: const Text("Ajouter"),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
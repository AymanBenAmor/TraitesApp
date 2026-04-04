import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class NouvelleTraitePage extends StatefulWidget {
  const NouvelleTraitePage({super.key});

  @override
  State<NouvelleTraitePage> createState() => _NouvelleTraitePageState();
}

class _NouvelleTraitePageState extends State<NouvelleTraitePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController? _autocompleteController;

  final numeroController = TextEditingController();
  final clientController = TextEditingController();
  final ribController = TextEditingController();
  final sourceController = TextEditingController();
  final montantController = TextEditingController();
  final destinationController = TextEditingController();
  final commentaireController = TextEditingController();

  DateTime? dateEcheance;
  final DateTime dateReception = DateTime.now();

  String etat = "";
  bool retour = false;

  List<Map<String, String>> clients = [];

  @override
  void initState() {
    super.initState();
    loadClientsFromCSV();
  }

  // Cross-platform CSV loader
  Future<void> loadClientsFromCSV() async {
    

    final Directory docDir = await getApplicationDocumentsDirectory();
    final File file = File('${docDir.path}/TraiteManager/Clients/clients.csv');
    print("Looking for CSV at: ${file.path}");

    if (await file.exists()) {
      
      final csvString = await file.readAsString();
      final csvTable = CsvToListConverter().convert(csvString, eol: '\n');

      final headers = csvTable[0].map((e) => e.toString()).toList();
      final data = csvTable.skip(1);

      setState(() {
        clients = data.map((row) {
          final map = <String, String>{};
          for (int i = 0; i < headers.length; i++) {
            map[headers[i]] = row[i].toString();
          }
          return map;
        }).toList();
      });
    } else {
      debugPrint("CSV file not found: ${file.path}");
    }
  }

  List<String> get clientNames => clients.map((c) => c['Name']!).toList();

  Future<void> choisirDateEcheance() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => dateEcheance = picked);
    }
  }


void sauvegarder() async {
  if (_formKey.currentState!.validate() && etat.isNotEmpty && dateEcheance != null) {
    final traite = {
      "numero": numeroController.text,
      "client": clientController.text,
      "rib": ribController.text,
      "source": sourceController.text,
      "date_echeance": "${dateEcheance!.day}/${dateEcheance!.month}/${dateEcheance!.year}",
      "date_reception": "${dateReception.day}/${dateReception.month}/${dateReception.year}",
      "montant": montantController.text,
      "destination": destinationController.text,
      "etat": etat,
      "retour": retour.toString(),
      "commentaire": commentaireController.text,
    };

    try {
      final Directory docDir = await getApplicationDocumentsDirectory();
      final Directory traiteDir = Directory('${docDir.path}/TraiteManager/Traites');

      if (!await traiteDir.exists()) {
        await traiteDir.create(recursive: true);
      }

      final File csvFile = File('${traiteDir.path}/Traites.csv');

      // Write headers if file does not exist
      if (!await csvFile.exists()) {
        final headers = traite.keys.toList();
        await csvFile.writeAsString(
          headers.join(',') + '\n',
          flush: true,
        );
      }

      // Append the new row, adding quotes only if necessary
      String escapeCsv(String value) {
        if (value.contains(',') || value.contains('\n')) {
          return '"${value.replaceAll('"', '""')}"';
        }
        return value;
      }

      final row = traite.values.map((e) => escapeCsv(e.toString())).join(',');
      await csvFile.writeAsString(row + '\n', mode: FileMode.append, flush: true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Traite sauvegardée !")),
      );

      // Clear the form
      numeroController.clear();
      clientController.clear();
       _autocompleteController?.clear(); // <-- clear Autocomplete field
      ribController.clear();
      sourceController.clear();
      montantController.clear();
      destinationController.clear();
      commentaireController.clear();
      setState(() {
        dateEcheance = null;
        etat = "";
        retour = false;
      });

    } catch (e) {
      debugPrint("Erreur lors de la sauvegarde: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la sauvegarde")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Veuillez remplir tous les champs requis")),
    );
  }
}

  Widget buildCard({required Widget child, Color? color}) {
    return Card(
      color: color ?? Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Nouvelle Traite", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(184, 1, 64, 96),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Numéro, Client, Source
            buildCard(
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  TextFormField(
                    controller: numeroController,
                    decoration: const InputDecoration(
                      labelText: "Numéro",
                      prefixIcon: Icon(Icons.confirmation_number, color: Colors.indigo),
                    ),
                    validator: (v) => v!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 12),
Autocomplete<String>(
  optionsBuilder: (textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return clientNames;
    }
    return clientNames.where((client) =>
        client.toLowerCase().contains(textEditingValue.text.toLowerCase()));
  },
  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
    _autocompleteController = controller; // <-- store the internal controller
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      decoration: const InputDecoration(
        labelText: "Client",
        prefixIcon: Icon(Icons.person, color: Colors.indigo),
      ),
      validator: (v) => v!.isEmpty ? "Champ requis" : null,
    );
  },
  onSelected: (selection) {
    clientController.text = selection;
    final selectedClient = clients.firstWhere((c) => c['Name'] == selection);
    ribController.text = selectedClient['RIB'] ?? '';
  },
),

                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: ribController,
                    decoration: const InputDecoration(
                      labelText: "RIB du client",
                      prefixIcon: Icon(Icons.account_balance, color: Colors.indigo),
                    ),
                    readOnly: true, // User cannot edit, only auto-filled
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: sourceController,
                    decoration: const InputDecoration(
                      labelText: "Source client",
                      prefixIcon: Icon(Icons.source, color: Colors.indigo),
                    ),
                    validator: (v) => v!.isEmpty ? "Champ requis" : null,
                  ),


                ],
              ),
            ),

            // Dates
             buildCard(
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color:Colors.indigo),
                    title: Text(dateEcheance == null
                        ? "Date d'échéance"
                        : "Échéance: ${dateEcheance!.day}/${dateEcheance!.month}/${dateEcheance!.year}"),
                    onTap: choisirDateEcheance,
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time, color:Colors.indigo),
                    title: Text(
                        "Réception: ${dateReception.day}/${dateReception.month}/${dateReception.year}"),
                  ),
                ],
              ),
            ),


            // Montant, Destination
            buildCard(
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  TextFormField(
                    controller: montantController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Montant",
                      prefixIcon: Icon(Icons.attach_money, color: Colors.indigo),
                    ),
                    validator: (v) => v!.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: destinationController,
                    decoration: const InputDecoration(
                      labelText: "Destination",
                      prefixIcon: Icon(Icons.location_on, color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),

            // État + Retour
            buildCard(
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("État", style: TextStyle(fontWeight: FontWeight.bold)),
                  RadioListTile(
                    activeColor: Colors.green,
                    title: const Text("Payé"),
                    value: "Payé",
                    groupValue: etat,
                    onChanged: (v) => setState(() => etat = v.toString()),
                  ),
                  RadioListTile(
                    activeColor: Colors.orange,
                    title: const Text("En cours"),
                    value: "En cours",
                    groupValue: etat,
                    onChanged: (v) => setState(() => etat = v.toString()),
                  ),
                  RadioListTile(
                    activeColor: Colors.red,
                    title: const Text("Impayé"),
                    value: "Impayé",
                    groupValue: etat,
                    onChanged: (v) => setState(() => etat = v.toString()),
                  ),
                  SwitchListTile(
                    activeColor: Colors.indigo,
                    title: const Text("Retour"),
                    value: retour,
                    onChanged: (v) => setState(() => retour = v),
                  ),
                ],
              ),
            ),

            // Commentaire
            buildCard(
              color: Colors.blue.shade50,
              child: TextFormField(
                controller: commentaireController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Commentaire",
                  prefixIcon: Icon(Icons.comment, color: Colors.indigo),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton.icon(
                onPressed: sauvegarder,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text("Sauvegarder", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(184, 1, 64, 96),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
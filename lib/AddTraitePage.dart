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
  Key _autocompleteKey = UniqueKey();

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

  bool isSaving = false;

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

Future<bool> traiteExiste(String numero) async {
  final Directory docDir = await getApplicationDocumentsDirectory();
  final File csvFile = File('${docDir.path}/TraiteManager/Traites/Traites.csv');

  if (!await csvFile.exists()) return false;

  final content = await csvFile.readAsString();
  final lines = content.split('\n');

  if (lines.length <= 1) return false; // no data

  final headers = lines.first.split(',');
  final numeroIndex = headers.indexOf("numero");

  if (numeroIndex == -1) return false;

  for (int i = 1; i < lines.length; i++) {
    if (lines[i].trim().isEmpty) continue;

    final cols = lines[i].split(',');

    if (cols.length > numeroIndex && cols[numeroIndex] == numero) {
      return true; // traite exists
    }
  }

  return false;
}

Future<void> sauvegarder() async {
  if (_formKey.currentState!.validate() && etat.isNotEmpty && dateEcheance != null) {

    // ✅ Client cannot be empty
    if (clientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ce client n'existe pas. Veuillez le sélectionner dans la liste.")),
      );
      setState(() {
      isSaving = false; // Start loading
    });
      return;
    }

    setState(() {
      isSaving = true; // Start loading
    });

    // ✅ Check if dateEcheance is after dateReception
    if (dateEcheance!.isBefore(dateReception) || dateEcheance!.isAtSameMomentAs(dateReception)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La date d'échéance doit être après la date de réception.")),
      );
      setState(() => isSaving = false);
      return;
    }

    // ✅ Check numeric fields
    if (int.tryParse(numeroController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le numéro de traite doit être un nombre.")),
      );
      setState(() => isSaving = false);
      return;
    }

    if (double.tryParse(montantController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le montant doit être un nombre.")),
      );
      setState(() => isSaving = false);
      return;
    }

    final traite = {
      "numero": numeroController.text,
      "client": clientController.text.trim(),
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

      if (!await traiteDir.exists()) await traiteDir.create(recursive: true);

      final File csvFile = File('${traiteDir.path}/Traites.csv');

      // Write headers if file does not exist
      if (!await csvFile.exists()) {
        final headers = traite.keys.toList();
        await csvFile.writeAsString(headers.join(',') + '\n', flush: true);
      }

      // Escape CSV values
      String escapeCsv(String value) {
        if (value.contains(',') || value.contains('\n')) {
          return '"${value.replaceAll('"', '""')}"';
        }
        return value;
      }

      // --- Check if traite number already exists ---
if (await csvFile.exists()) {
  final existingCsv = await csvFile.readAsString();
  final existingTable = CsvToListConverter().convert(existingCsv, eol: '\n');
  
  // Skip headers and check numero
  final numeroIndex = existingTable[0].indexOf('Numero');
  if (numeroIndex == -1) {
    debugPrint("Traites CSV headers invalid: ${existingTable[0]}");
  } else {
    for (var i = 1; i < existingTable.length; i++) {
      if (existingTable[i][numeroIndex].toString().trim() == numeroController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ce numéro de traite existe déjà !")),
        );
        setState(() => isSaving = false);
        return;
      }
    }
  }
}

      // Append new traite row
      final row = traite.values.map((e) => escapeCsv(e.toString())).join(',');
      await csvFile.writeAsString(row + '\n', mode: FileMode.append, flush: true);

      // --- Update client montant in clients.csv ---
      final File clientsFile = File('${docDir.path}/TraiteManager/Clients/clients.csv');
      if (await clientsFile.exists()) {
        final csvString = await clientsFile.readAsString();
        final csvTable = CsvToListConverter().convert(csvString, eol: '\n');

        // Trim headers
        final headers = csvTable[0].map((e) => e.toString().trim()).toList();
        final data = csvTable.skip(1).toList();

        final nameIndex = headers.indexOf('Name');
        final montantIndex = headers.indexOf('Montant');
        

        if (nameIndex == -1 || montantIndex == -1) {
          debugPrint("Clients CSV headers invalid: $headers");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Le fichier clients.csv est invalide.")),
          );
        } else {
          // ✅ Check if client exists in clients.csv
          bool clientFound = false;
          
          for (var i = 0; i < data.length; i++) {
            if (data[i][nameIndex].toString().trim() == clientController.text.trim()) {
              double oldMontant = double.tryParse(data[i][montantIndex].toString()) ?? 0;
              double montantToAdd = double.tryParse(montantController.text) ?? 0;
              
              if(etat != "Payé"){
                data[i][montantIndex] = (oldMontant + montantToAdd).toString();
              }
              clientFound = true;
              break;
            }
          }

          if (!clientFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Le client sélectionné n'existe pas dans clients.csv.")),
            );
            setState(() => isSaving = false);
            return;
          }

          // Rewrite clients.csv
          List<List<String>> stringData =
              data.map((row) => row.map((e) => e.toString().trim()).toList()).toList();
          final csvContent = const ListToCsvConverter().convert([headers, ...stringData]);
          await clientsFile.writeAsString(csvContent, flush: true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Le fichier clients.csv est vide ou n'existe pas.")),
        );
        setState(() => isSaving = false);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Traite sauvegardée !")),
      );


      setState(() {
        numeroController.clear();
        _autocompleteKey = UniqueKey(); // 🔥 FORCE FULL RESET
        ribController.clear();
        sourceController.clear();
        montantController.clear();
        destinationController.clear();
        commentaireController.clear();

        dateEcheance = null;
        etat = "";
        retour = false;
      });

    } catch (e) {
      debugPrint("Erreur lors de la sauvegarde: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la sauvegarde")),
      );
    } finally {
      setState(() => isSaving = false);
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
  actions: [
    IconButton(
      icon: const Icon(Icons.clear, color: Colors.white),
      tooltip: "Tout effacer",
      onPressed: () {
        // Clear the form
        _autocompleteKey = UniqueKey(); // 🔥 FORCE FULL RESET
        numeroController.clear();
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
      },
    ),
  ],
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
  key: _autocompleteKey, // ✅ VERY IMPORTANT
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
  child: SaveButton(onPressed: sauvegarder),
),
          ],
        ),
      ),
    );
  }
}

class SaveButton extends StatefulWidget {
  final Future<void> Function() onPressed; // Make it async
  const SaveButton({super.key, required this.onPressed});

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  bool isHovered = false;
  bool isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: ElevatedButton.icon(
          onPressed: isLoading
              ? null // Disable while loading
              : () async {
                  setState(() => isLoading = true);
                  try {
                    await widget.onPressed(); // Call the async sauvegarder
                  } finally {
                    setState(() => isLoading = false);
                  }
                },
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save, color: Colors.white),
          label: Text(
            isLoading ? "Sauvegarde..." : "Sauvegarder",
            style: const TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(184, 1, 64, 96),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
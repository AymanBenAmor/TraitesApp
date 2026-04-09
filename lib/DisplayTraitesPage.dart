import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class TraitesPage extends StatefulWidget {
  const TraitesPage({super.key});

  @override
  State<TraitesPage> createState() => _TraitesPageState();
}

class _TraitesPageState extends State<TraitesPage> {
  List<List<dynamic>> _traites = [];
  List<List<dynamic>> _filteredTraites = [];


  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _ribController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // Filters
  String? _filterNumero;
  String? _filterClient;
  String? _filterEtat;
  String? _filterRetour;
  String? _filterComment;
  DateTime? _filterDateEcheance;
  DateTime? _filterDateReception;
  String? _filterRib;
  String? _filterSource;
  String? _filterDestination;
  String? _filterMontant;

  final List<String> _etatOptions = ['En cours', 'Impayé', 'Payé'];
  final List<String> _retourOptions = ['Oui', 'Non'];

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/TraiteManager/Traites/traites.csv';
      final file = File(path);

      if (!await file.exists()) {
        debugPrint("CSV file does not exist at $path");
        return;
      }

      final csvContent = await file.readAsString();
      final fixedContent = csvContent.replaceAll('\r\n', '\n');

      List<List<dynamic>> rowsAsListOfValues =
          const CsvToListConverter(eol: '\n').convert(fixedContent);

      setState(() {
        _traites = rowsAsListOfValues.sublist(1); // skip header
        _filteredTraites = List.from(_traites);
      });
    } catch (e) {
      debugPrint("Error reading CSV: $e");
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTraites = _traites.where((row) {
        bool matches = true;
        if (_filterNumero != null && _filterNumero!.isNotEmpty) {
          matches = matches && row[0].toString() == _filterNumero;
        }
        if (_filterClient != null && _filterClient!.isNotEmpty) {
          matches =
              matches && row[1].toString().toLowerCase().contains(_filterClient!.toLowerCase());
        }
        if (_filterEtat != null) {
          matches = matches && row[8].toString().toLowerCase() == _filterEtat!.toLowerCase();
        }
        if (_filterRetour != null) {
          matches = matches &&
              mapRetour(row[9]).toLowerCase() == _filterRetour!.toLowerCase();
        }
        if (_filterComment != null && _filterComment!.isNotEmpty) {
          if (row.length > 10 && row[10] != null) {
            matches = matches &&
                row[10].toString().toLowerCase().contains(_filterComment!.toLowerCase());
          } else {
            matches = false;
          }
        }
        if (_filterDateEcheance != null) {
          matches = matches && row[4].toString() == _formatDate(_filterDateEcheance!);
        }
        if (_filterDateReception != null) {
          matches = matches && row[5].toString() == _formatDate(_filterDateReception!);
        }
        if (_filterRib != null && _filterRib!.isNotEmpty) {
          matches = matches &&
              row[2].toString().toLowerCase().contains(_filterRib!.toLowerCase());
        }

        if (_filterSource != null && _filterSource!.isNotEmpty) {
          matches = matches &&
              row[3].toString().toLowerCase().contains(_filterSource!.toLowerCase());
        }

        if (_filterMontant != null && _filterMontant!.isNotEmpty) {
          matches = matches &&
              row[6].toString().contains(_filterMontant!);
        }

        if (_filterDestination != null && _filterDestination!.isNotEmpty) {
          matches = matches &&
              row[7].toString().toLowerCase().contains(_filterDestination!.toLowerCase());
        }
        return matches;
      }).toList();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _etatColor(String etat) {
    switch (etat.toLowerCase()) {
      case 'en cours':
        return Colors.orange;
      case 'impayé':
        return Colors.red;
      case 'payé':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String mapRetour(dynamic value) {
    if (value.toString().toLowerCase() == 'true') return 'Oui';
    return 'Non';
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Compact text field filter
Widget _buildFilterText(
  String label,
  TextEditingController controller,
  Function(String) onChange, {
  bool numeric = false,
  double height = 40,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height,
            child: TextField(
              controller: controller,
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 45, 81)),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color.fromARGB(255, 0, 45, 81), width: 0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (v) {
                onChange(v);
                _applyFilters();
              },
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear, size: 20, color: Colors.white),
          onPressed: () {
            controller.clear();
            onChange('');
            _applyFilters();
          },
        ),
      ],
    ),
  );
}

Widget _buildFilterDropdown(
  String label,
  String? value,
  List<String> items,
  Function(String?) onChange, {
  double height = 40, // default height
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: height, // reduce height here
            child: InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12), // smaller vertical padding
                
                labelStyle: const TextStyle(color: Color.fromARGB(255, 0, 45, 81)),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 0, 45, 81), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 0, 45, 81), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 0, 45, 81), width: 2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  hint: Text('Select $label',
                      style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 0, 45, 81))),
                  items: items
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 0, 45, 81))),
                          ))
                      .toList(),
                  onChanged: (v) {
                    onChange(v);
                    _applyFilters();
                  },
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear, size: 20, color: Color.fromARGB(255, 248, 248, 248)),
          onPressed: () {
            onChange(null);
            _applyFilters();
          },
        ),
      ],
    ),
  );
}

 // Date picker filter
Widget _buildFilterDate(String label, DateTime? date, Function(DateTime?) onChange) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              backgroundColor: Colors.grey.shade100, // Button background
              foregroundColor: const Color.fromARGB(255, 0, 45, 81), // Text and icon color
              side: const BorderSide(color: Color.fromARGB(255, 0, 45, 81), width: 0), // Border color
            ),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: date ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color.fromARGB(255, 8, 0, 94), // header background
                        onPrimary: Colors.white, // header text
                        onSurface: Color.fromARGB(255, 19, 0, 85), // body text
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color.fromARGB(239, 0, 1, 86), // button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              onChange(picked);
              _applyFilters();
            },
            child: Text(
              date != null ? _formatDate(date) : label,
              style: const TextStyle(fontSize: 13.5),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear, size: 20, color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            onChange(null);
            _applyFilters();
          },
        ),
      ],
    ),
  );
}


Future<void> _deleteTraite(int index) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/TraiteManager/Traites/traites.csv';
    final file = File(path);

    // Remove the row from the list
    _traites.removeAt(index);

    // Rebuild CSV content including header
    List<List<dynamic>> csvContent = [
      ['Numero', 'Client', 'RIB', 'Source', 'Date Echéance', 'Date Réception', 'Montant', 'Destination', 'Etat', 'Retour', 'Commentaire'], // header
      ..._traites
    ];

    String csv = const ListToCsvConverter().convert(csvContent);

    // Save back to file
    await file.writeAsString(csv);

    // Update filtered list
    _applyFilters();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Traite supprimé avec succès')),
    );
  } catch (e) {
    debugPrint("Error deleting traite: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erreur lors de la suppression')),
    );
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Liste des Traites',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(184, 1, 64, 96),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Column(
      children: [
        // White separator under the AppBar
        Container(
          height: 5,
          color: Colors.white,
        ),

        // Main body
        Expanded(
          child: Row(
            children: [
              // Left panel
              Container(
                width: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(184, 1, 64, 96),
                      const Color.fromARGB(255, 138, 173, 181),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(2, 0),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16), // padding inside panel
                child: Column(
                  children: [
                    // Filters title with icon
                    Row(
                      children: const [
                        Icon(Icons.filter_list, size: 28, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Filters",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Make scrollable only the filters
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildFilterText('Numero Traite', _numeroController, (v) => _filterNumero = v, height: 50),

                            _buildFilterText('Client', _clientController, (v) => _filterClient = v, height: 50),
                            _buildFilterDropdown(
                              'Etat',
                              _filterEtat,
                              _etatOptions,
                              (v) => _filterEtat = v,
                            ),
                            _buildFilterDropdown(
                              'Retour',
                              _filterRetour,
                              _retourOptions,
                              (v) => _filterRetour = v,
                            ),
                            _buildFilterText(
                              'Commentaire',
                              _commentController,
                              (v) => _filterComment = v,
                              height: 50,
                            ),
                            _buildFilterDate(
                              'Date Échéance',
                              _filterDateEcheance,
                              (v) => _filterDateEcheance = v,
                            ),
                            _buildFilterDate(
                              'Date Réception',
                              _filterDateReception,
                              (v) => _filterDateReception = v,
                            ),
                            _buildFilterText(
                              'RIB',
                              _ribController,
                              (v) => _filterRib = v,
                              height: 50,
                            ),
                            _buildFilterText(
                              'Source',
                              _sourceController,
                              (v) => _filterSource = v,
                              height: 50,
                            ),
                            _buildFilterText(
                              'Montant',
                              _montantController,
                              (v) => _filterMontant = v,
                              numeric: true,
                              height: 50,
                            ),
                            _buildFilterText(
                              'Destination',
                              _destinationController,
                              (v) => _filterDestination = v,
                              height: 50,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                _filterNumero = null;
                                _filterClient = null;
                                _filterEtat = null;
                                _filterRetour = null;
                                _filterComment = null;
                                _filterDateEcheance = null;
                                _filterDateReception = null;
                                _filterRib = null;
                                _filterSource = null;
                                _filterDestination = null;
                                _filterMontant = null;


                                    // clear text fields
                                _numeroController.clear();
                                _clientController.clear();
                                _commentController.clear();
                                _ribController.clear();
                                _sourceController.clear();
                                _montantController.clear();
                                _destinationController.clear();

                                _applyFilters();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 78, 7, 7), // button background color
                                foregroundColor: Colors.white, // text color
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Effacer tous les filtres'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          // Right main panel
          Expanded(
            child: _traites.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _filteredTraites.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucun traite trouvé avec ces filtres',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
: ListView.builder(
  padding: const EdgeInsets.all(12),
  itemCount: _filteredTraites.length,
  itemBuilder: (context, index) {
    final row = _filteredTraites[index];
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.66,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(1.01),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.shade50,
                      const Color.fromARGB(255, 225, 232, 238)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '№ ${row[0]} - ${row[1]}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _etatColor(row[8].toString()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            row[8].toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow('RIB', row[2].toString()),
                    _infoRow('Source', row[3].toString()),
                    _infoRow('Date Échéance', row[4].toString()),
                    _infoRow('Date Réception', row[5].toString()),
                    _infoRow('Montant', row[6].toString()),
                    _infoRow('Destination', row[7].toString()),
                    _infoRow('Retour', mapRetour(row[9])),
                    if (row.length > 10 && row[10] != null && row[10] != '')
                      _infoRow('Commentaire', row[10].toString()),

                    // Delete button
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: const Text(
                                  'Voulez-vous vraiment supprimer ce traite ?'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Supprimer',
                                        style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                          if (confirm) {
                            // Find the actual index in _traites (not _filteredTraites)
                            int actualIndex =
                                _traites.indexOf(_filteredTraites[index]);
                            await _deleteTraite(actualIndex);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  },
),
          ),
        ],
          ),
        ),
      ],
    ),
  );
}
}
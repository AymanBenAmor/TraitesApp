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

  // Filters
  String? _filterNumero;
  String? _filterClient;
  String? _filterEtat;
  String? _filterRetour;
  String? _filterComment;
  DateTime? _filterDateEcheance;
  DateTime? _filterDateReception;

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
  Widget _buildFilterText(String label, String? value, Function(String) onChange, {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (v) {
                onChange(v);
                _applyFilters();
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              onChange('');
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  // Dropdown filter
  Widget _buildFilterDropdown(
      String label, String? value, List<String> items, Function(String?) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: InputDecorator(
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  hint: Text('Select $label', style: const TextStyle(fontSize: 14)),
                  items: items
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: const TextStyle(fontSize: 14)),
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
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
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
                  padding: const EdgeInsets.symmetric(vertical: 8)),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                onChange(picked);
                _applyFilters();
              },
              child: Text(date != null ? _formatDate(date) : label,
                  style: const TextStyle(fontSize: 14)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              onChange(null);
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Traites',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(184, 1, 64, 96),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Left filter panel
          Container(
            width: 300,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFilterText('Traite №', _filterNumero ?? '', (v) => _filterNumero = v, numeric: true),
                  _buildFilterText('Client', _filterClient ?? '', (v) => _filterClient = v),
                  _buildFilterDropdown('Etat', _filterEtat, _etatOptions, (v) => _filterEtat = v),
                  _buildFilterDropdown('Retour', _filterRetour, _retourOptions, (v) => _filterRetour = v),
                  _buildFilterText('Commentaire', _filterComment ?? '', (v) => _filterComment = v),
                  _buildFilterDate('Date Échéance', _filterDateEcheance, (v) => _filterDateEcheance = v),
                  _buildFilterDate('Date Réception', _filterDateReception, (v) => _filterDateReception = v),
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
                        _applyFilters();
                      },
                      child: const Text('Clear All Filters')),
                ],
              ),
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
                                      if (row.length > 10 &&
                                          row[10] != null &&
                                          row[10] != '')
                                        _infoRow('Commentaire', row[10].toString()),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}
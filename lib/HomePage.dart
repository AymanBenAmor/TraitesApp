import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:traitenova/AddTraitePage.dart';
import 'package:traitenova/Clients.dart';
import 'package:traitenova/DisplayTraitesPage.dart';
import 'package:traitenova/NotificationPage.dart';
import 'package:traitenova/main.dart';
import 'package:traitenova/utils/SecurityTools.dart';
import 'package:traitenova/utils/tools.dart';
import 'package:traitenova/utils/clock_utilities.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  String _currentTime = "";
  ClockHelper? _clockHelper;
  int _notifsNumber = 0; // example notification count
  List<Client> clientsExceedingMontant = [];
  List<Traite> traitesEnRetard = [];

  @override
  void initState() {
    super.initState();
    checkLicense(context: context); // vérification de licence
    _clockHelper = ClockHelper(onTick: (time) {
      setState(() {
        _currentTime = time;
      });
    });
    _clockHelper!.startClock();
    _loadClients();
    
  }

  Future<void> _loadClients() async {
    final clients = await checkClientsMontant();
    final traites = await checkTraitementsEnRetard();

  


    setState(() {
      clientsExceedingMontant = clients;
      traitesEnRetard = traites;

      _notifsNumber = clients.length + traites.length;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _clockHelper?.stopClock();
    super.dispose();
  }

  // Called when coming back to this page
  @override
  void didPopNext() {
    _loadClients(); // refresh client notifications
  }

  DateTime parseDate(String input) {
  final parts = input.split('/');

  final day = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final year = int.parse(parts[2]);

  return DateTime(year, month, day);
}

Future<List<Traite>> loadTraitements() async {
  final Directory docDir = await getApplicationDocumentsDirectory();
  final File file =
      File('${docDir.path}/TraiteManager/Traites/traites.csv');

  if (!await file.exists()) return [];

  final csvString = await file.readAsString();
  final csvTable =
      const CsvToListConverter().convert(csvString, eol: '\n');

  final List<Traite> traites = [];

  for (int i = 1; i < csvTable.length; i++) {
    final row = csvTable[i];

    traites.add(
      Traite(
        numero: row[0].toString(),
        client: row[1].toString(),
        etat: row[8].toString(),
        dateEcheance: parseDate(row[4].toString()),
        montant: double.tryParse(row[6].toString()) ?? 0,
      ),
    );
  }

  

  return traites;
}


Future<List<Traite>> checkTraitementsEnRetard() async {
  final all = await loadTraitements();
  
  final now = DateTime.now();
  
  return all.where((t) {
    final isEnCours = t.etat.trim().toLowerCase() == "en cours";
    final isOverdue = t.dateEcheance.isBefore(now);
    
    return isEnCours && isOverdue;
  }).toList();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        elevation: 4,
        title: const Text(
          "Gestion des Traites Bancaires",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 237, 237, 237),
          ),
        ),
        actions: [

          // 🔄 Sync button
          IconButton(
            icon: const Icon(
              Icons.sync,
              color: Color.fromARGB(255, 237, 237, 237),
            ),
            onPressed: () {
              // print("Sync clicked");
              // TODO: add sync logic (API / database refresh)
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
      onPressed: () {
        
        // Navigate to NotificationsPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationsPage(
              clientsExceeding: clientsExceedingMontant,
              traitesEnRetard: traitesEnRetard,
            ),
          ),
        );
      },
              ),

              // Only show badge if _notifsNumber > 0
              if (_notifsNumber > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(0.8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      "$_notifsNumber", // number of notifications
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 10), // spacing

          // ⏱ Time display
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _currentTime.toString().substring(0, 11),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 237, 237, 237),
                ),
              ),
            ),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 👋 Section bienvenue
            const Text(
              "Bienvenue",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Gérez vos traites bancaires efficacement",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 60),

            // 📦 Section Cartes
            Expanded(
              
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80), // padding X-axis
              child: GridView.count(
                crossAxisCount: 3,            // 3 cartes par ligne
                crossAxisSpacing: 100,         // espacement horizontal entre cartes
                mainAxisSpacing: 100,          // espacement vertical entre cartes
                childAspectRatio: 1,       // ratio largeur/hauteur pour cartes plus petites
                children: [

                  buildCard(Icons.add, "Créer une Traite", () {
                   
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NouvelleTraitePage()));
                  }, color: const Color.fromARGB(184, 1, 64, 96)), // bleu-gris clair

                  buildCard(Icons.list, "Voir les Traites", () {
                    // print("Voir les Traites tapped");
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TraitesPage()));
                  }, color: const Color.fromARGB(184, 1, 64, 96)), // bleu-gris moyen

                  buildCard(Icons.person, "Espace Client", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EspaceClientPage()));
                  }, color: const Color.fromARGB(184, 1, 64, 96)), // bleu-gris foncé

                ],
              ),
            )
            ),
          ],
        ),
      ),
    );
  }
}


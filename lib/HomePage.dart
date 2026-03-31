import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:traite_manager/Clients.dart';
import 'package:traite_manager/NotificationPage.dart';
import 'package:traite_manager/main.dart';
import 'package:traite_manager/utils/SecurityTools.dart';
import 'package:traite_manager/utils/tools.dart';
import 'package:traite_manager/utils/clock_utilities.dart';

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
    setState(() {
      clientsExceedingMontant = clients;
      _notifsNumber = clients.length; // update notification count
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
              print("Sync clicked");
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
                    print("Créer une Traite tapped");
                  }, color: const Color.fromARGB(184, 1, 64, 96)), // bleu-gris clair

                  buildCard(Icons.list, "Voir les Traites", () {
                    print("Voir les Traites tapped");
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


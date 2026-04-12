import 'package:flutter/material.dart';
import 'package:traitenova/utils/tools.dart';

class NotificationsPage extends StatelessWidget {
  final List<Client> clientsExceeding;
  final List<Traite> traitesEnRetard;

  const NotificationsPage({
    super.key,
    required this.clientsExceeding,
    required this.traitesEnRetard,
  });

  Future<int> _getLimit() async {
    return await loadMontantLimit();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getLimit(),
      builder: (context, snapshot) {
        final limit = snapshot.data ?? 0;

        final hasNotifications =
            clientsExceeding.isNotEmpty || traitesEnRetard.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Notifications",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color.fromARGB(184, 1, 64, 96),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),
            child: !hasNotifications
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 90,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Aucune notification",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      // ================= TRAITES EN RETARD =================
                      if (traitesEnRetard.isNotEmpty) ...[
                        const Text(
                          "⏰ Traites en retard",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...traitesEnRetard.map(
                          (t) => Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.redAccent,
                                child: Icon(Icons.schedule, color: Colors.white),
                              ),
                              title: Text("Traite #${t.numero}"),
                              subtitle: Text(
                                "Client: ${t.client}\nÉchéance: ${t.dateEcheance.toString().substring(0, 10)}",
                              ),
                              trailing: const Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],

                      // ================= CLIENTS EXCEEDING =================
                      if (clientsExceeding.isNotEmpty) ...[
                        Text(
                          "🔵 Clients dépassant $limit TND",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        ...clientsExceeding.map(
                          (client) => Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromARGB(184, 1, 64, 96),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(client.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text("Téléphone: ${client.phone}"),
                                  Text(
                                    "Montant: ${client.montantEncours} TND",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.warning,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }
}
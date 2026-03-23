import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 🚨 Show license error dialog
void showBlocked(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("License Error"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            exit(0);
          },
          child: const Text("Exit"),
        ),
      ],
    ),
  );
}

/// 🎴 Reusable card widget
Widget buildCard(IconData icon, String title, VoidCallback onTap, {Color? color}) {
  return _HoverCardWidget(
    icon: icon,
    title: title,
    onTap: onTap,
    color: color ?? Colors.blueGrey,
  );
}

class _HoverCardWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _HoverCardWidget({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  State<_HoverCardWidget> createState() => _HoverCardWidgetState();
}

class _HoverCardWidgetState extends State<_HoverCardWidget> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: widget.color,
      end: widget.color.withOpacity(0.85),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        _controller.reverse();
        setState(() => _isHovered = false);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.center, // center pivot
            child: Container(
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(_isHovered ? 25 : 20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.35 : 0.2),
                    blurRadius: _isHovered ? 15 : 10,
                    offset: Offset(0, _isHovered ? 8 : 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(_isHovered ? 25 : 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, size: _isHovered ? 65 : 60, color: Colors.white),
                    const SizedBox(height: 25),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _isHovered ? 17 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


enum FieldType { text, phone, number, rib }

Widget buildInputField(
  String label,
  TextEditingController controller, {
  FieldType fieldType = FieldType.text,  // 🔹 new enum
  String hint = "",
  double width = 800,
}) {
  return SizedBox(
    width: width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 51, 92),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextFormField(
            controller: controller,
            keyboardType: fieldType == FieldType.number || fieldType == FieldType.rib
                ? TextInputType.number
                : fieldType == FieldType.phone
                    ? TextInputType.phone
                    : TextInputType.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Ce champ est obligatoire";
              }

              switch (fieldType) {
                case FieldType.phone:
                  if (!RegExp(r'^[0-9]{8,15}$').hasMatch(value)) {
                    return "Numéro invalide";
                  }
                  break;
                case FieldType.number:
                  if (double.tryParse(value) == null) {
                    return "Valeur numérique invalide";
                  }
                  break;
                case FieldType.rib:
                  if (!RegExp(r'^[0-9]{20}$').hasMatch(value)) {
                    return "Le RIB doit contenir exactement 20 chiffres";
                  }
                  break;
                default:
                  break;
              }

              return null;
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );
}



class Client {
  String name;
  int phone;
  String rib;
  double montantEncours;

  Client({
    required this.name,
    required this.phone,
    required this.rib,
    required this.montantEncours,
  });
}

/// Reusable ListView for clients
class ClientListView extends StatelessWidget {
  final List<Client> clients;
  const ClientListView({super.key, required this.clients});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, index) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 300.0, vertical: 4.0),
          child: ClientCard(client: clients[index]),
        );
      },
    );
  }
}

/// Reusable Card widget for a single client
class ClientCard extends StatelessWidget {
  final Client client;
  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 225, 232, 238),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: ListTile(
        title: Text(client.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Téléphone: ${client.phone}",
                style: const TextStyle(fontSize: 15)),
            Text("RIB: ${client.rib}", style: const TextStyle(fontSize: 15)),
            Text("Montant encours: ${client.montantEncours}",
                style: const TextStyle(fontSize: 15)),
          ],
        ),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => print("Modifier client: ${client.name}"),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => print("Supprimer client: ${client.name}"),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/// Save client to CSV in Documents/TraiteManager/Clients/clients.csv
Future<bool> saveClientToCSV(
    BuildContext context, Map<String, String> client) async {
  try {
    // Get Documents folder
    final Directory docDir = await getApplicationDocumentsDirectory();
    final Directory pathDir = Directory('${docDir.path}/TraiteManager/Clients');

    // Create folder if not exists
    if (!await pathDir.exists()) {
      await pathDir.create(recursive: true);
    }

    final File file = File('${pathDir.path}/clients.csv');

    // If file doesn't exist, create and add header
    if (!await file.exists()) {
      await file.writeAsString("Name,Phone,RIB,Montant\n",
          mode: FileMode.write, flush: true);
    }

    // Read existing rows
    final List<String> lines = await file.readAsLines();

    // Check if the client already exists (by name or RIB)
    bool exists = lines.any((line) {
      if (line.startsWith("Name")) return false; // skip header
      final parts = line.split(',');
      final name = parts[0].trim();
      final rib = parts[2].trim();
      return name == client['name'] || rib == client['rib'];
    });

    if (exists) {
      // Show SnackBar if client exists
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Client already exists!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    // Append new client row
    final row = "${client['name']},${client['phone']},${client['rib']},0\n";
    await file.writeAsString(row, mode: FileMode.append, flush: true);

    // Show SnackBar for success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Client saved successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    return true;
  } catch (e) {
    // Show SnackBar for error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error saving client: $e"),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    return false;
  }
}

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart'; // add crypto: ^3.0.2 in pubspec.yaml

Future<String> getMacAddress() async {
  try {
    if (Platform.isWindows) {
      ProcessResult result = await Process.run('getmac', []);
      if (result.exitCode == 0) {
        String output = result.stdout.toString();
        RegExp reg = RegExp(r'([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}');
        Match? match = reg.firstMatch(output);
        if (match != null) {
          return match.group(0)!.toUpperCase(); // keep F0-9E-4A-CF-26-BE
        }
      }
    }
  } catch (e) {
    print("Error getting MAC: $e");
  }
  return "";
}

String normalizeMac(String mac) {
  // Remove all '-' and ':' and convert to uppercase
  return mac.replaceAll('-', '').replaceAll(':', '').toUpperCase();
}

String hashMac(String mac, String secretKey) {
  mac = normalizeMac(mac);
  var bytes = utf8.encode(mac + secretKey);
  var digest = sha512.convert(bytes);
  return digest.toString();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool authorized = false;
  final String binFilePath = r".\Setup\SerialNumber.bin"; // change to your file path
  final String secretKey = "kjqshkdjshkdjhkuqhfkqdjhfkdhfkqdufhkdqjf"; // same key used to generate the hash

  @override
  void initState() {
    super.initState();
    checkLicense();
  }

  Future<void> checkLicense() async {
    try {
      // 1️⃣ Get MAC
      String mac = await getMacAddress();
      if (mac.isEmpty) {
        showBlocked("Unable to get MAC address.");
        return;
      }

      // 2️⃣ Hash MAC with secret key
      String macHash = hashMac(mac, secretKey);
      

      // 3️⃣ Read serial hash from bin file
      if (!File(binFilePath).existsSync()) {
        showBlocked("License file not found!");
        return;
      }

      String serialHash = await File(binFilePath).readAsString();
      serialHash = serialHash.trim(); // remove extra whitespace
      print("MAC: $mac"); // for debugging, remove in production
      print("MAC Hash: $macHash"); // for debugging, remove in production
      print("Serial Hash: $serialHash"); // for debugging, remove in production

      // 4️⃣ Compare
      if (macHash == serialHash) {
        setState(() {
          authorized = true;
        });
      } else {
        showBlocked("You do not have a valid license to use this application.\n Please contact administrator to obtain a valid license.\n\n Admin E-mail: aymen.benamor@ensi-uma.tn\n Admin Phone: +216 54 393 769");
      }
    } catch (e) {
      showBlocked("Error: $e");
    }
  }

  void showBlocked(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // cannot dismiss
      builder: (context) => AlertDialog(
        title: const Text("License Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              exit(0); // close the app
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!authorized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print("App is authorized!");
          },
          child: const Text("Click Me"),
        ),
      ),
    );
  }
}
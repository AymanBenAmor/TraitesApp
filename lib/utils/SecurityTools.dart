import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'tools.dart'; // for showBlocked

/// ------------------------
/// ✅ LICENSE CHECK FUNCTION
/// ------------------------
/// 
  final String binFilePath = r".\Setup\SerialNumber.bin"; // change to your file path
  final String secretKey = "kjqshkdjshkdjhkuqhfkqdjhfkdhfkqdufhkdqjf"; // same key used to generate the hash

Future<void> checkLicense({
  required BuildContext context,
}) async {
  try {
    // 1️⃣ Get MAC
    String mac = "";
    try {
      if (Platform.isWindows) {
        ProcessResult result = await Process.run('getmac', []);
        if (result.exitCode == 0) {
          String output = result.stdout.toString();
          RegExp reg = RegExp(r'([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}');
          Match? match = reg.firstMatch(output);
          if (match != null) {
            mac = match.group(0)!.toUpperCase();
          } else {
            throw Exception("MAC address not found.");
          }
        } else {
          throw Exception("Failed to get MAC address.");
        }
      } else {
        throw Exception("Unsupported platform for license check.");
      }
    } catch (e) {
      throw Exception("Error getting MAC: $e");
    }

    // 2️⃣ Hash MAC
    String normalizedMac = mac.replaceAll('-', '').replaceAll(':', '').toUpperCase();
    var bytes = utf8.encode(normalizedMac + secretKey);
    var digest = sha512.convert(bytes);
    String macHash = digest.toString();

    // 3️⃣ Read serial hash from file
    if (!File(binFilePath).existsSync()) {
      throw Exception("License file not found!");
    }
    String serialHash = await File(binFilePath).readAsString();
    serialHash = serialHash.trim();

    // 4️⃣ Compare
    if (macHash != serialHash) {
      throw Exception(
          "You do not have a valid license to use this application.\n"
          "Please contact administrator to obtain a valid license.\n\n"
          "Admin E-mail: aymen.benamor@ensi-uma.tn\n"
          "Admin Phone: +216 54 393 769");
    }

  } catch (e) {
    // Show the blocked dialog and exit
    showBlocked(context, e.toString());
  }
}
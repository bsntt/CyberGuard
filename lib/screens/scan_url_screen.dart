import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'URL Scanner',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const ScanUrlScreen(),
    );
  }
}

class ScanUrlScreen extends StatefulWidget {
  const ScanUrlScreen({super.key});

  @override
  State<ScanUrlScreen> createState() => _ScanUrlScreenState();
}

class _ScanUrlScreenState extends State<ScanUrlScreen> {
  static const String googleApiKey =
      "API KEYES";

  final TextEditingController _urlController = TextEditingController();

  bool scanned = false;
  bool isSafe = true;
  double score = 0.0;
  String message = "";

  Future<void> scanUrl() async {
    String url = _urlController.text.trim();

    if (url.isEmpty) return;

    Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) {
      setState(() {
        scanned = true;
        isSafe = false;
        score = 0.1;
        message = "❌ Invalid URL format.";
      });
      return;
    }

    final apiUrl =
        "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$googleApiKey";

    final requestBody = {
      "client": {
        "clientId": "url-scanner-app",
        "clientVersion": "1.0"
      },
      "threatInfo": {
        "threatTypes": [
          "MALWARE",
          "SOCIAL_ENGINEERING",
          "UNWANTED_SOFTWARE",
          "POTENTIALLY_HARMFUL_APPLICATION"
        ],
        "platformTypes": ["ANY_PLATFORM"],
        "threatEntryTypes": ["URL"],
        "threatEntries": [
          {"url": url}
        ]
      }
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      setState(() {
        scanned = true;

        if (data.containsKey("matches")) {
          isSafe = false;
          score = 0.25;
          message =
          "⚠️ Dangerous URL Detected!\nThreat: ${data["matches"][0]["threatType"]}";
        } else {
          isSafe = true;
          score = 0.95;
          message = "✅ URL is SAFE.";
        }
      });
    } catch (e) {
      setState(() {
        scanned = true;
        isSafe = false;
        score = 0.1;
        message = "❌ Error scanning URL. Check internet connection.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white, // Arrow color
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
        title: const Text("URL Scanner"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple, // Match button color
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: "https://example.com",
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: scanUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "SCAN URL",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (scanned)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSafe
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        isSafe ? Icons.check_circle : Icons.warning,
                        color: isSafe ? Colors.green : Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSafe ? "SAFE" : "UNSAFE",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isSafe ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Score: ${(score * 100).toInt()}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: score,
                        color: isSafe ? Colors.green : Colors.red,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

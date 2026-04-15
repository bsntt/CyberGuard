import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_tutorial.dart';
import 'manage_users.dart';
import 'manage_tips.dart';
import 'add_quiz_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Text(
                "CyberGuard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ✅ Manage Tutorials Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageTutorialScreen(),
                    ),
                  );
                },
                child: _adminCard(
                  title: "Manage Tutorials",
                  colors: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
              ),
              const SizedBox(height: 25),

              // ✅ Manage Quiz Button
              GestureDetector(
                onTap: () async {
                  await _showSelectTutorialDialog(context);
                },
                child: _adminCard(
                  title: "Manage Quiz",
                  colors: const [Color(0xFFFFB347), Color(0xFFFFCC33)],
                ),
              ),
              const SizedBox(height: 25),

              // ✅ Manage Tips Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageTipsScreen(),
                    ),
                  );
                },
                child: _adminCard(
                  title: "Manage Tips",
                  colors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                ),
              ),
              const SizedBox(height: 25),

              // ✅ Manage Users Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageUsersScreen(),
                    ),
                  );
                },
                child: _adminCard(
                  title: "Manage Users",
                  colors: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Admin Card Widget
  Widget _adminCard({
    required String title,
    required List<Color> colors,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      shadowColor: Colors.black54,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Show tutorial selection dialog for Manage Quiz
  Future<void> _showSelectTutorialDialog(BuildContext context) async {
    try {
      // Fetch tutorials from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('tutorials')
          .orderBy('timestamp', descending: true)
          .get();

      final tutorials = snapshot.docs;

      if (tutorials.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No tutorials found")),
        );
        return;
      }

      // Show AlertDialog with list of tutorials
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Select Tutorial for Quiz"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tutorials.length,
                itemBuilder: (context, index) {
                  final tutorial = tutorials[index];
                  final title = tutorial['title'] ?? 'Untitled Tutorial';
                  return ListTile(
                    title: Text(title),
                    onTap: () {
                      Navigator.pop(context); // close dialog
                      // ✅ Navigate to AddQuizScreen (no tutorialId)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddQuizScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Firestore error handling
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}

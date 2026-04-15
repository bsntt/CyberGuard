import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialDetailScreen extends StatelessWidget {
  final String tutorialId;
  final String title;

  TutorialDetailScreen({
    super.key,
    required this.tutorialId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('tutorials')
              .doc(tutorialId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("Description not found"));
            }

            final data = snapshot.data!;
            final description =
                data['description'] ?? 'No description available';

            return SingleChildScrollView(
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

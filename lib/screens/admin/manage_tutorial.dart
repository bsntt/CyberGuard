import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_quiz_screen.dart';
import '../play_quiz.dart';

class ManageTutorialScreen extends StatelessWidget {
  const ManageTutorialScreen({super.key});

  static const List<String> categories = [
    "Password",
    "Phishing",
    "Device Security",
    "Social Media"
  ];

  Future<String> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'user';

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.exists ? (doc.data()?['role'] ?? 'user') : 'user';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutorials"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tutorials')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No tutorials found"));
            }

            final tutorials = snapshot.data!.docs;

            return FutureBuilder<String>(
              future: getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final isAdmin = roleSnapshot.data == 'admin';

                return ListView.builder(
                  itemCount: tutorials.length,
                  itemBuilder: (context, index) {
                    final tutorial = tutorials[index];
                    final title = tutorial['title'] ?? '';
                    final description = tutorial['description'] ?? '';
                    final category = tutorial['category'] ?? 'General';

                    return Card(
                      elevation: 6,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "$description\nCategory: $category",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          isThreeLine: true,
                          trailing: isAdmin
                              ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white),
                            onSelected: (value) {
                              if (value == 'addQuiz') {
                                // ✅ Fixed: no tutorialId parameter
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const AddQuizScreen()),
                                );
                              } else if (value == 'edit') {
                                _showEditDialog(context, tutorial);
                              } else if (value == 'delete') {
                                _deleteTutorial(context, tutorial.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                  value: 'addQuiz', child: Text("Add Quiz")),
                              PopupMenuItem(
                                  value: 'edit', child: Text("Edit")),
                              PopupMenuItem(
                                  value: 'delete', child: Text("Delete")),
                            ],
                          )
                              : ElevatedButton(
                            onPressed: () {
                              // ✅ Fixed: pass category instead of tutorialId
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => PlayQuizScreen(
                                        category: category)),
                              );
                            },
                            child: const Text("Play Quiz"),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FutureBuilder<String>(
        future: getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.data == 'admin') {
            return FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: () => _showAddDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Add Tutorial Dialog
  void _showAddDialog(BuildContext context) {
    final title = TextEditingController();
    final desc = TextEditingController();
    String selectedCategory = categories[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Add Tutorial"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: "Title")),
                  TextField(
                      controller: desc,
                      decoration:
                      const InputDecoration(labelText: "Description")),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: categories
                        .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (title.text.isEmpty || desc.text.isEmpty) return;
                  await FirebaseFirestore.instance.collection('tutorials').add({
                    'title': title.text,
                    'description': desc.text,
                    'category': selectedCategory,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  // Edit Tutorial Dialog
  void _showEditDialog(BuildContext context, DocumentSnapshot tutorial) {
    final title = TextEditingController(text: tutorial['title']);
    final desc = TextEditingController(text: tutorial['description']);
    String currentCat = tutorial['category'] ?? categories[0];
    if (!categories.contains(currentCat)) currentCat = categories[0];
    String selectedCategory = currentCat;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Tutorial"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: title,
                      decoration: const InputDecoration(labelText: "Title")),
                  TextField(
                      controller: desc,
                      decoration:
                      const InputDecoration(labelText: "Description")),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: "Category"),
                    items: categories
                        .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => selectedCategory = val!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('tutorials')
                      .doc(tutorial.id)
                      .update({
                    'title': title.text,
                    'description': desc.text,
                    'category': selectedCategory,
                  });
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteTutorial(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Tutorial"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('tutorials').doc(id).delete();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

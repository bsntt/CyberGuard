import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final CollectionReference tipsRef =
  FirebaseFirestore.instance.collection('tips');

  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Password",
    "Phishing",
    "Device Security",
    "Social Media"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tips"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Category Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
          ),

          // Tips List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tipsRef.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTips = snapshot.data!.docs;

                // Filter by category (trim & lowercase for safety)
                final filteredTips = selectedCategory == "All"
                    ? allTips
                    : allTips
                    .where((tip) =>
                tip['category']
                    .toString()
                    .trim()
                    .toLowerCase() ==
                    selectedCategory.toLowerCase())
                    .toList();

                if (filteredTips.isEmpty) {
                  return const Center(child: Text("No tips available"));
                }

                return ListView.builder(
                  itemCount: filteredTips.length,
                  itemBuilder: (context, index) {
                    final tip = filteredTips[index];
                    return Card(
                      margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: ListTile(
                        title: Text(tip['tip']),
                        subtitle: Text(
                          'Category: ${tip['category']}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.lightBlue,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

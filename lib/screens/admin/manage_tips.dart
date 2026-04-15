import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTipsScreen extends StatefulWidget {
  const ManageTipsScreen({super.key});

  @override
  State<ManageTipsScreen> createState() => _ManageTipsScreenState();
}

class _ManageTipsScreenState extends State<ManageTipsScreen> {
  final CollectionReference tipsRef = FirebaseFirestore.instance.collection('tips');
  final TextEditingController _tipController = TextEditingController();
  String selectedCategory = "Password"; // default category

  final List<String> categories = ["Password", "Phishing", "Device Security", "Social Media"];

  // ✅ Show Add Tip Dialog
  void _showAddTipDialog() {
    _tipController.clear();
    selectedCategory = "Password";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Tip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            TextField(
              controller: _tipController,
              decoration: const InputDecoration(labelText: 'Tip'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple), // white text for TextButton not needed, keep color
          ),
          ElevatedButton(
            onPressed: () async {
              if (_tipController.text.isEmpty) return;
              await tipsRef.add({
                'category': selectedCategory,
                'tip': _tipController.text,
                'timestamp': FieldValue.serverTimestamp(),
              });
              _tipController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add Tip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white, // white text
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Show Update Tip Dialog
  void _updateTip(String id, String category, String tip) {
    selectedCategory = category;
    _tipController.text = tip;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Tip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            TextField(controller: _tipController, decoration: const InputDecoration(labelText: 'Tip')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
          ),
          ElevatedButton(
            onPressed: () async {
              await tipsRef.doc(id).update({
                'category': selectedCategory,
                'tip': _tipController.text,
                'timestamp': FieldValue.serverTimestamp(),
              });
              _tipController.clear();
              Navigator.pop(context);
            },
            child: const Text('Update'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white, // white text
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTip(String id) async {
    await tipsRef.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Tips"),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // go back to Admin Dashboard
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _showAddTipDialog,
            child: const Text('Add Tip'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white, // white text
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tipsRef.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final tips = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tips.length,
                  itemBuilder: (context, index) {
                    final tip = tips[index];
                    return ListTile(
                      title: Text(tip['tip']),
                      subtitle: Text('Category: ${tip['category']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _updateTip(tip.id, tip['category'], tip['tip']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTip(tip.id),
                          ),
                        ],
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

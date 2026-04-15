import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final questionController = TextEditingController();
  final option1Controller = TextEditingController();
  final option2Controller = TextEditingController();
  final option3Controller = TextEditingController();
  final option4Controller = TextEditingController();

  // Admin selects the category
  String selectedCategory = 'Password';
  final categories = ["Password", "Phishing", "Device Security", "Social Media"];

  // Admin selects the correct option
  String correctAnswer = 'Option 1';

  void _saveQuiz() async {
    final question = questionController.text.trim();
    final options = [
      option1Controller.text.trim(),
      option2Controller.text.trim(),
      option3Controller.text.trim(),
      option4Controller.text.trim(),
    ];

    if (question.isEmpty || options.any((o) => o.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('quizzes').add({
      'category': selectedCategory,
      'question': question,
      'options': options,
      'answer': options[int.parse(correctAnswer.split(' ').last) - 1],
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz saved successfully!')),
    );

    questionController.clear();
    option1Controller.clear();
    option2Controller.clear();
    option3Controller.clear();
    option4Controller.clear();
    setState(() {
      correctAnswer = 'Option 1';
      selectedCategory = categories.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Quiz Question (Admin)'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Category selection
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => selectedCategory = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),

              // Question
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              const SizedBox(height: 12),

              // Options
              TextField(controller: option1Controller, decoration: const InputDecoration(labelText: 'Option 1')),
              TextField(controller: option2Controller, decoration: const InputDecoration(labelText: 'Option 2')),
              TextField(controller: option3Controller, decoration: const InputDecoration(labelText: 'Option 3')),
              TextField(controller: option4Controller, decoration: const InputDecoration(labelText: 'Option 4')),
              const SizedBox(height: 12),

              // Correct answer
              DropdownButtonFormField<String>(
                value: correctAnswer,
                items: const [
                  DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
                  DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
                  DropdownMenuItem(value: 'Option 3', child: Text('Option 3')),
                  DropdownMenuItem(value: 'Option 4', child: Text('Option 4')),
                ],
                onChanged: (v) => setState(() => correctAnswer = v!),
                decoration: const InputDecoration(labelText: 'Correct Answer'),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveQuiz,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.all(14)),
                child: const Text('Save Quiz', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

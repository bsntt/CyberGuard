import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayQuizScreen extends StatefulWidget {
  final String category; // Receive category from HomeScreen

  const PlayQuizScreen({super.key, required this.category});

  @override
  State<PlayQuizScreen> createState() => _PlayQuizScreenState();
}

class _PlayQuizScreenState extends State<PlayQuizScreen> {
  List<Map<String, dynamic>> quizQuestions = [];
  int currentIndex = 0;
  int score = 0;
  bool isLoading = true;
  bool answered = false;
  String selectedAnswer = '';

  @override
  void initState() {
    super.initState();
    _fetchQuizQuestions();
  }

  // 🔹 Fetch quiz questions from Firestore based on category
  Future<void> _fetchQuizQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('category', isEqualTo: widget.category)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No quiz questions found for this category.")),
        );
      }

      setState(() {
        quizQuestions = snapshot.docs
            .map((doc) => {
          'question': doc['question'],
          'options': List<String>.from(doc['options']),
          'answer': doc['answer'],
        })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching quiz: $e")),
      );
    }
  }

  void _checkAnswer(String answer) {
    if (answered) return; // prevent multiple clicks
    setState(() {
      answered = true;
      selectedAnswer = answer;
      if (answer == quizQuestions[currentIndex]['answer']) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    if (currentIndex < quizQuestions.length - 1) {
      setState(() {
        currentIndex++;
        answered = false;
        selectedAnswer = '';
      });
    } else {
      _showScoreDialog();
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed"),
        content: Text("Your score: $score / ${quizQuestions.length}"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to HomeScreen
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: Text("No questions available")),
      );
    }

    final question = quizQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.category} Quiz"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Question
            Text(
              "Q${currentIndex + 1}: ${question['question']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Options
            ...question['options'].map<Widget>((option) {
              Color optionColor = Colors.blueGrey.shade100;
              if (answered) {
                if (option == question['answer']) {
                  optionColor = Colors.green.shade400;
                } else if (option == selectedAnswer) {
                  optionColor = Colors.red.shade400;
                }
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: optionColor,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => _checkAnswer(option),
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              );
            }).toList(),

            const Spacer(),

            // Next Button
            if (answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                ),
                onPressed: _nextQuestion,
                child: Text(
                  currentIndex < quizQuestions.length - 1 ? "Next Question" : "Finish Quiz",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> categories = [
    "Password",
    "Phishing",
    "Device Security",
    "Social Media",
  ];

  String selectedCategory = categories[0];

  @override
  Widget build(BuildContext context) {
    Widget menuButton({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      required Color color,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: const Color(0xFF6A11CB)),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CyberGuard",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF52C1C5),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 🔹 GRID MENU
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      menuButton(
                        icon: Icons.qr_code_scanner,
                        label: "Scan URL",
                        color: const Color(0xFFFFC0CB),
                        onTap: () =>
                            Navigator.pushNamed(context, '/scan-url'),
                      ),
                      menuButton(
                        icon: Icons.book,
                        label: "Learn",
                        color: const Color(0xFFB3E5FC),
                        onTap: () =>
                            Navigator.pushNamed(context, '/learn'),
                      ),
                      menuButton(
                        icon: Icons.lightbulb,
                        label: "Tips",
                        color: const Color(0xFFFFF9C4),
                        onTap: () =>
                            Navigator.pushNamed(context, '/tips'),
                      ),
                      menuButton(
                        icon: Icons.person,
                        label: "Profile",
                        color: const Color(0xFFC8E6C9),
                        onTap: () =>
                            Navigator.pushNamed(context, '/profile'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 🔹 HORIZONTAL QUIZ CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A11CB),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // LEFT SIDE (ICON + TEXT)
                        const Icon(Icons.quiz,
                            color: Colors.white, size: 40),

                        const SizedBox(width: 16),

                        // TEXT + DROPDOWN
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Play Quiz",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Select Category",
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),

                              DropdownButton<String>(
                                value: selectedCategory,
                                dropdownColor: Colors.deepPurple,
                                iconEnabledColor: Colors.white,
                                style:
                                const TextStyle(color: Colors.white),
                                underline: Container(
                                  height: 2,
                                  color: Colors.white70,
                                ),
                                items: categories
                                    .map(
                                      (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // RIGHT SIDE BUTTON
                        SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/quiz',
                                arguments: selectedCategory,
                              );
                            },
                            child: const Text(
                              "Start Quiz",
                              style:
                              TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}] 
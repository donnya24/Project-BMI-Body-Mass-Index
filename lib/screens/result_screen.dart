import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String name;
  final String age;
  final String gender;
  final double bmi;
  final String category;
  final String recommendation;

  const ResultScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.bmi,
    required this.category,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hasil BMI',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(0, 150, 136, 1),
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 74, 229, 214),
              Color.fromARGB(255, 160, 196, 225),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.9,
                ),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Hasil BMI Anda',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildInfoRow('Nama :', name),
                        buildInfoRow('Umur :', age),
                        buildInfoRow('Jenis Kelamin :', gender),
                        const Divider(
                            height: 40, thickness: 1, color: Colors.teal),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'BMI: ${bmi.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildCategory(),
                        const SizedBox(height: 20),
                        buildRecommendation(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategory() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Kategori :',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget buildRecommendation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rekomendasi :',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          constraints: BoxConstraints(
            maxHeight: 200, // Adjust as needed
          ),
          child: SingleChildScrollView(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 16),
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }
}

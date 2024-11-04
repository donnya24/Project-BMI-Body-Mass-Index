import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'result_screen.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? selectedGender;
  final List<String> genders = ['Laki-laki', 'Perempuan'];

  void calculateAndNavigate() async {
    try {
      double height = double.parse(heightController.text);
      double weight = double.parse(weightController.text);
      double bmi = (weight / (height * height)) * 10000;

      String category;
      String recommendation;
      if (bmi < 18.5) {
        category = 'Berat Badan Kurang';
        recommendation = 'Makanan yang mungkin bisa dikonsumsi : \n'
            '1. Protein : Daging tanpa lemak, ikan, telur, produk olahan susu \n'
            '2. Karbohidrat : Nasi merah & oats \n'
            '3. Buah : Kurma & kismis \n'
            '4. Sayuran : Kentang, ubi jalar, jagung \n'
            'Saran : Pastikan untuk Mengkonumsi porsi yang lebih besar dan sering, serta konsultasikan dengan ahli gizi untuk rencana yang lebih terperinci dan sesuai !';
      } else if (bmi >= 18.5 && bmi < 24.9) {
        category = 'Berat Badan Normal';
        recommendation = 'Makanan yang mungkin bisa dikonsumsi : \n'
            '1. Protein : Ikan, ayam tanpa kulit, telur, tahu & tempe \n'
            '2. Buah : Apel, pisang, beri, jeruk \n'
            '3. Sayur-sayuran \n'
            '4. Nasi Merah \n'
            'Saran : Pertahankan Pola makan seimbang, serta beraktivitas fisik secara teratur untuk menjaga berat badan dan kesehatan yang optimal !';
      } else if (bmi >= 25 && bmi < 29.9) {
        category = 'BB Berlebihan Tingkat Ringan';
        recommendation = 'Makanan yang mungkin bisa dikonsumsi : \n'
            '1. Protein : Ayam tanpa kulit, ikan, tahu \n'
            '2. Buah : Apel, beri, jeruk \n'
            '3. Sayuran rendah karbohidrat dan kalori \n'
            'Saran : Mengatur porsi dan menjaga pola makan simbang serta olahraga yang cukup dan teratur. Dan konsultasikan dengan ahli gizi untuk mendapatkan saran yang sesuai !';
      } else {
        category = 'BB Berlebihan Tingkat Berat';
        recommendation = 'Makanan yang mungkin bisa dikonsumsi : \n'
            '1. Protein : Ayam tanpa kulit, ikan, tahu \n'
            '2. Buah : Apel, beri, jeruk \n'
            '3. Sayuran rendah karbohidrat dan kalori \n'
            'Saran : Mengatur porsi dan menjaga pola makan seimbang serta olahraga yang cukup dan teratur. Dan konsultasikan dengan ahli gizi untuk mendapatkan saran yang sesuai !';
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .add({
          'name': nameController.text,
          'age': ageController.text,
          'gender': selectedGender ?? 'Tidak Diketahui',
          'bmi': bmi,
          'category': category,
          'recommendation': recommendation,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            name: nameController.text,
            age: ageController.text,
            gender: selectedGender ?? 'Tidak Diketahui',
            bmi: bmi,
            category: category,
            recommendation: recommendation,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'BMI Calculator',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 150, 136, 1),
        elevation: 10,
        shadowColor: Colors.teal.shade200,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 178, 235, 242),
              Color.fromARGB(255, 128, 222, 234),
              Color.fromARGB(255, 77, 182, 172),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 20, vertical: screenSize.height * 0.05),
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Isi Data Anda',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                        nameController, 'Masukkan Nama Anda', false),
                    const SizedBox(height: 20),
                    _buildGenderDropdown(),
                    const SizedBox(height: 20),
                    _buildTextField(
                        heightController, 'Masukkan Tinggi Badan (cm)', true),
                    const SizedBox(height: 20),
                    _buildTextField(
                        weightController, 'Masukkan Berat Badan (kg)', true),
                    const SizedBox(height: 20),
                    _buildTextField(ageController, 'Masukkan Umur Anda', true),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: calculateAndNavigate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          backgroundColor: const Color.fromRGBO(0, 150, 136, 1),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        child: const Text(
                          'Hitung BMI Anda',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('history')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> history = snapshot.data!.docs
                .map((doc) =>
                    {'id': doc.id, ...doc.data() as Map<String, dynamic>})
                .toList();

            return BottomNavBar(history: history);
          } else {
            return BottomNavBar(history: []);
          }
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isNumber) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Pilih Jenis Kelamin',
        labelStyle: const TextStyle(color: Colors.teal),
        fillColor: Colors.teal.shade50,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal),
        ),
      ),
      value: selectedGender,
      onChanged: (value) {
        setState(() {
          selectedGender = value;
        });
      },
      items: genders.map<DropdownMenuItem<String>>((String gender) {
        Icon genderIcon;
        Color iconColor;

        if (gender == 'Laki-laki') {
          genderIcon = const Icon(Icons.male, color: Colors.blue);
          iconColor = Colors.blue;
        } else {
          genderIcon = const Icon(Icons.female, color: Colors.pink);
          iconColor = Colors.pink;
        }

        return DropdownMenuItem<String>(
          value: gender,
          child: Row(
            children: [
              genderIcon,
              const SizedBox(width: 10),
              Text(gender, style: TextStyle(color: iconColor)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

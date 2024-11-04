import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/custom_alert_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _selectedGender = 'Laki-laki'; // Default gender selection
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Boolean variables for password visibility
  bool _isPasswordVisible = false;
  bool _isRePasswordVisible = false;

  Future<void> _signup() async {
    // Check if all fields are filled
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _retypePasswordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Missing Fields',
          message: 'Please fill in all the required fields.',
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      );
      return;
    }

    // Check if the age is a valid number
    if (int.tryParse(_ageController.text) == null) {
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Invalid Age',
          message: 'Please enter a valid age.',
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      );
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _retypePasswordController.text) {
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Password Mismatch',
          message: 'Passwords do not match. Please re-enter.',
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      );
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'gender': _selectedGender,
        'age': int.parse(_ageController.text),
        'phone': _phoneController.text,
        'address': _addressController.text,
        'email': _emailController.text,
      });

      // Show success message
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Sign Up Success',
          message: 'Your account has been created successfully.',
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
            // Navigate to LoginScreen after confirming the dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      );
    } catch (e) {
      String errorMessage =
          'An error occurred while signing up. Please try again.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email address is already in use.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            break;
          case 'weak-password':
            errorMessage =
                'Password is too weak. Please choose a stronger password.';
            break;
          default:
            errorMessage =
                'An error occurred while signing up. Please try again.';
            break;
        }
      }

      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Signup Error',
          message: errorMessage,
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      );

      print('Signup failed: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _retypePasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get the screen size
    final bool isPortrait = size.height > size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: size.height,
          ),
          child: IntrinsicHeight(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 91, 220, 153),
                    Color.fromARGB(255, 59, 157, 222)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    if (isPortrait) ...[
                      Center(
                        child: Image.asset(
                          'assets/bmi.jpg',
                          height: 150,
                          width: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                    const Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Enter Name',
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                items: [
                                  DropdownMenuItem(
                                    value: 'Laki-laki',
                                    child: Row(
                                      children: const [
                                        Icon(Icons.male, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Male'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Perempuan',
                                    child: Row(
                                      children: const [
                                        Icon(Icons.female, color: Colors.pink),
                                        SizedBox(width: 8),
                                        Text('Female'),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value!;
                                  });
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Select Gender',
                                  prefixIcon: Icon(
                                    Icons.people,
                                    color: Colors.blue,
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _ageController,
                                label: 'Enter Age',
                                icon: Icons.calendar_today,
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Enter Phone',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Enter Address',
                                icon: Icons.home,
                              ),
                              const SizedBox(height: 10),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Enter Email',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 10),
                              _buildPasswordField(
                                controller: _passwordController,
                                label: 'Enter Password 8 Digit',
                                isVisible: _isPasswordVisible,
                                toggleVisibility: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              _buildPasswordField(
                                controller: _retypePasswordController,
                                label: 'Re-type Password 8 Digit',
                                isVisible: _isRePasswordVisible,
                                toggleVisibility: () {
                                  setState(() {
                                    _isRePasswordVisible =
                                        !_isRePasswordVisible;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 42, 168, 171),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Already have an account? Login',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 16, 130, 236),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

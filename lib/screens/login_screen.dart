import 'package:apps_bmi/screens/bmi_calculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/custom_alert_dialog.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Added for password visibility

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const BMICalculator()),
      );
    } catch (e) {
      String errorMessage =
          'An error occurred while logging in. Please try again.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            break;
          case 'user-disabled':
            errorMessage = 'This user has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'User not found. Please sign up.';
            break;
          case 'wrong-password':
            errorMessage = 'Invalid password. Please try again.';
            break;
          default:
            errorMessage =
                'An error occurred while logging in. Please try again.';
            break;
        }
      }

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Login Error',
          message: errorMessage,
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      );

      print('Login failed: $e');
    }
  }

  // Function to send password reset email
  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Error',
          message: 'Please enter your email address.',
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      await FirebaseAuth.instance.signOut(); // Log the user out
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Reset Password',
          message:
              'A password reset link has been sent to your email. Please check your email and log in again.',
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const LoginScreen()), // Redirect to Login Screen
            );
          },
        ),
      );
    } catch (e) {
      print('Failed to send password reset email: $e');
      showDialog(
        context: context,
        builder: (context) => CustomAlertDialog(
          title: 'Error',
          message: 'Failed to send reset link. Please try again.',
          onConfirmed: () {
            Navigator.pop(context); // Close the dialog
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    'assets/bmi.jpg',
                    height: 150,
                    width: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'BMI Calculator',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Color.fromARGB(255, 16, 130, 236),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Enter Email',
                            prefixIcon: const Icon(Icons.email),
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Enter Password',
                            prefixIcon: const Icon(Icons.lock),
                            hintText: 'Enter your password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible =
                                      !_isPasswordVisible; // Toggle visibility
                                });
                              },
                            ),
                          ),
                          obscureText:
                              !_isPasswordVisible, // Control the visibility here
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 42, 168, 171),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white, // Ubah warna teks menjadi putih
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()),
                            );
                          },
                          child: const Text(
                            'Don\'t have an account? Sign up',
                            style: TextStyle(
                              color: Color.fromARGB(255, 16, 130, 236),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _resetPassword, // Call reset password function
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color.fromARGB(255, 16, 130, 236),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

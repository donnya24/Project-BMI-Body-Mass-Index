import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print('Failed to fetch user data: $e');
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        // Delete the user account
        await user.delete();
        // Navigate to login screen after account deletion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      print('Failed to delete account: $e');
      // Show error message or feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
              color: Colors.white), // Set the title text color to white
        ),
        backgroundColor:
            const Color.fromRGBO(0, 150, 136, 1), // Match the app bar color
        elevation: 5,
        iconTheme: const IconThemeData(
            color: Colors.white), // Set the back arrow color to white
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 74, 229, 214),
              Color.fromARGB(255, 160, 196, 225),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: userData == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20), // User Info Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${userData!['name'] ?? ''}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildUserInfoRow(Icons.person,
                                'Gender: ${userData!['gender'] ?? ''}'),
                            _buildUserInfoRow(
                                Icons.cake, 'Age: ${userData!['age'] ?? ''}'),
                            _buildUserInfoRow(Icons.phone,
                                'Phone: ${userData!['phone'] ?? ''}'),
                            _buildUserInfoRow(Icons.home,
                                'Address: ${userData!['address'] ?? ''}'),
                            _buildUserInfoRow(Icons.email,
                                'Email: ${userData!['email'] ?? ''}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 40, 127, 234)),
                      ),
                    ),
                    const SizedBox(height: 20), // Spacer for the delete button
                    ElevatedButton(
                      onPressed: () async {
                        // Show confirmation dialog before deleting account
                        bool confirm = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm Account Deletion'),
                              content: const Text(
                                  'Are you sure you want to delete your account? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        // If user confirmed, delete account
                        if (confirm) {
                          await _deleteAccount();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 255, 0, 0), // Red color for delete button
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Helper method to build user info row with icon
  Widget _buildUserInfoRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 42, 168, 171)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(
                  fontSize: 18), // Increased font size for better readability
            ),
          ),
        ],
      ),
    );
  }
}

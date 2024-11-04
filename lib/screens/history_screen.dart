import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> history;

  const HistoryScreen({super.key, required this.history});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];
  late List<bool> selectedItems;
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('history')
        .get();

    final List<Map<String, dynamic>> documents = result.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() {
      history = documents;
      selectedItems = List<bool>.filled(history.length, false);
    });
  }

  Future<void> deleteSelectedItems() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    List<String> documentIdsToDelete = [];

    for (int index = 0; index < history.length; index++) {
      if (selectedItems[index]) {
        documentIdsToDelete.add(history[index]['id']);
      }
    }

    if (documentIdsToDelete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ada item yang dapat dihapus'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      for (String id in documentIdsToDelete) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('history')
            .doc(id)
            .delete();
      }

      setState(() {
        history.removeWhere((item) => documentIdsToDelete.contains(item['id']));
        selectedItems = List<bool>.filled(history.length, false);
        selectAll = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item terpilih berhasil dihapus'),
          backgroundColor: const Color.fromARGB(255, 30, 34, 55),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus item: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void toggleSelectAll(bool? value) {
    setState(() {
      selectAll = value ?? false;
      selectedItems = List<bool>.filled(history.length, selectAll);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 9, 117, 106),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Switch(
            value: selectAll,
            onChanged: toggleSelectAll,
            activeColor: const Color.fromARGB(255, 167, 255, 67),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: deleteSelectedItems,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 178, 235, 242),
              Color.fromARGB(255, 128, 222, 234),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: history.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      for (int index = 0; index < history.length; index++)
                        Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              'Nama: ${history[index]['name']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(Icons.cake,
                                    'Umur: ${history[index]['age']}'),
                                _buildInfoRow(Icons.fitness_center,
                                    'BMI: ${history[index]['bmi'].toStringAsFixed(2)}'),
                                _buildInfoRow(Icons.category,
                                    'Kategori: ${history[index]['category']}'),
                                _buildInfoRow(Icons.thumb_up,
                                    'Rekomendasi: ${history[index]['recommendation']}'),
                              ],
                            ),
                            trailing: Checkbox(
                              value: selectedItems[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedItems[index] = value ?? false;
                                  selectAll =
                                      selectedItems.every((element) => element);
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history,
                        size: 100, color: const Color.fromARGB(255, 0, 0, 0)),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada riwayat hasil.',
                      style: TextStyle(
                          fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

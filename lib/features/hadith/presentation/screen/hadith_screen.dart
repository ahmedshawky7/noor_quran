import 'package:flutter/material.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    // In production, load from database using a cubit
    return Scaffold(
      appBar: AppBar(title: const Text('Hadith Collection')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Hadith ${index+1}: The Messenger of Allah (peace be upon him) said...'),
            ),
          );
        },
      ),
    );
  }
}
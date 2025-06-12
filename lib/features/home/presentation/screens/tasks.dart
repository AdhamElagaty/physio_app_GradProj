import 'package:flutter/material.dart';
import 'package:gradproject/core/utils/styles/colors.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: AppColors.teal,
      ),
      body: const Center(
        child: Text(
          'Your Tasks Go Here!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

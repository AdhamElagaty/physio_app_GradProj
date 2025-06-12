import 'package:flutter/material.dart';
import 'package:gradproject/core/utils/styles/colors.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: AppColors.teal,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Chat!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

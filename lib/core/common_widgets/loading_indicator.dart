import 'package:flutter/material.dart';

class CenteredLoadingIndicator extends StatelessWidget {
  final String? message;
  const CenteredLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyLarge),
          ]
        ],
      ),
    );
  }
}